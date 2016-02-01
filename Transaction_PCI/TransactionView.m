
#import "TransactionView.h"

typedef enum {
    lineDevSel = 60,
    lineTrdy = 120,
    lineIrdy = 180,
    lineCbe = 240,
    lineAd = 300,
    lineFrame = 360,
    lineClk = 420
} Line;

@interface TransactionView () {
    CGFloat coefficient;
    NSPoint blockParameters;
    NSPoint tactParameters;
    NSInteger tactCount;
    CGFloat dataStart;
    CGFloat frameEnd;
    CGFloat tectHeight;
    NSInteger valueOfLines;
    NSInteger numberOfAddress;
}

@end

@implementation TransactionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    
    if (self.firstLaunch) {
        self.letters = 6;
        self.timeInterval = 0.5;
        self.arrayOfDelays = [NSArray arrayWithObjects:@90, @30, @30, @30, nil];
    }
    
    [self setValues];
    [self setHelpersLine];
    [self setPulse];
    [self setFirstDataAndCommand];
    [self setBlocks];
    [self setFrame];
    [self setIrdy];
    [self setTrdyOrDevSel:lineTrdy];
    [self setTrdyOrDevSel:lineDevSel];
}

- (void) setValues {
    NSInteger totalTactsInDelay = 0;
    for (id delay in _arrayOfDelays) {
        totalTactsInDelay += ceilf((CGFloat)[delay integerValue]/30);
    }
    
    if (_drawModeIs == timeInterval) {
        tactCount = ceilf((CGFloat)_timeInterval*1000/30);
        _letters = ceilf((CGFloat)((tactCount-4)*[_arrayOfDelays count]/totalTactsInDelay));
    } else {
        tactCount = ceilf((CGFloat) totalTactsInDelay/[_arrayOfDelays count] * _letters) + 4;
        if (tactCount < 16) {
            tactCount = 16;
        }
    }
    
    if (self.bounds.size.width/(tactCount*60) < 1) {
        coefficient = self.bounds.size.width/(tactCount*60);
    } else {
        coefficient = 1;
    }
    
    coefficient = (self.bounds.size.width/(tactCount * 60) < 1) ? self.bounds.size.width/(tactCount*60) : 1;
    dataStart = 110 * coefficient;
    
    tactParameters.x = 60 * coefficient;
    tactParameters.y = 40 * coefficient;
    blockParameters.x = tactParameters.x;
    
    if ([_digitAddress isEqualToString:@"32"]) {
        if ([_bitWord isEqualToString:@"0000"]) {
            dataStart = 170 * coefficient;
            blockParameters.y = 40 * coefficient * 0.6;
            numberOfAddress = 2;
            valueOfLines = 3;
        } else {
            blockParameters.y = 40 * coefficient;
            numberOfAddress = 1;
            valueOfLines = 2;
        }
    } else {
        blockParameters.y = 40 * coefficient*0.5;
        numberOfAddress = 1;
        valueOfLines = 4;
    }
}

#pragma mark - Draw Methods

-(void) setHelpersLine {
    CGFloat step = 60;
    CGFloat dash[] = {15.f, 15.f};
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    [line setLineWidth:1.f];
    [line setLineDash:dash
                count:2
                phase:1];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:9], NSFontAttributeName,[NSColor blackColor], NSForegroundColorAttributeName, nil];
    
    NSAttributedString * currentText;

    NSInteger counter = 1;
    
    for (int i = 0; i < 7; i++) {
        [line moveToPoint:NSMakePoint(0, self.bounds.size.height - step)];
        [line lineToPoint:NSMakePoint(self.bounds.size.width, self.bounds.size.height - step)];
        step += 60;
    }
    
    if (valueOfLines == 3) {
        [line moveToPoint:NSMakePoint(0, (lineAd - lineCbe)/2 + lineAd)];
        [line lineToPoint:NSMakePoint(self.bounds.size.width, (lineAd - lineCbe)/2 + lineAd)];
    }
    
    if (valueOfLines == 4) {
        step = 0;
        for (int i = 0; i < 2; i++) {
            [line moveToPoint:NSMakePoint(0, (lineAd - lineCbe)/2 + lineCbe + step)];
            [line lineToPoint:NSMakePoint(self.bounds.size.width, (lineAd - lineCbe)/2 + lineCbe + step)];
            step += lineAd - lineCbe;
        }
    }
    
    step = tactParameters.x/3;
    while (step < self.bounds.size.width) {
        
        currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", counter]
                                                      attributes:attributes];
        
        [currentText drawAtPoint:NSMakePoint(step + tactParameters.x/10, self.bounds.size.height-20)];

        [line moveToPoint:NSMakePoint(step + tactParameters.x/10, 0)];
        [line lineToPoint:NSMakePoint(step + tactParameters.x/10, self.bounds.size.height)];
        step += tactParameters.x;
        counter++;
    }
    
    [line stroke];
}

- (void) setPulse {
    
    CGFloat step = 0;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    [line setLineWidth:1.f];
    NSPoint lowPoint = NSMakePoint(step, lineClk);
    NSPoint highPoint = NSMakePoint(step + tactParameters.x/2, lineClk + tactParameters.y);
    
    NSInteger counter = 0;
    
    while (counter < tactCount) {
        
        [line moveToPoint:lowPoint];
        lowPoint.x += tactParameters.x/3;
        [line lineToPoint:lowPoint];
        [line lineToPoint:highPoint];
        highPoint.x += tactParameters.x/3;
        [line lineToPoint:highPoint];
        lowPoint.x += tactParameters.x * 2/3;
        [line lineToPoint:lowPoint];
        [line stroke];
        step += tactParameters.x;
        lowPoint.x = step;
        highPoint.x = step + tactParameters.x/2;
        counter++;
    }
}

- (void) setFrame {
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    [line setLineWidth:1.f];
    [line moveToPoint:NSMakePoint(0, lineFrame + tactParameters.y)];
    [line lineToPoint:NSMakePoint((tactParameters.x * 2)/3 + (tactParameters.x/10), lineFrame + tactParameters.y)];
    [line lineToPoint:NSMakePoint(tactParameters.x - (tactParameters.x/20), lineFrame)];
    [line lineToPoint:NSMakePoint(frameEnd - (tactParameters.x/10), lineFrame)];
    [line lineToPoint:NSMakePoint(frameEnd + (tactParameters.x/10), lineFrame + tactParameters.y)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width, lineFrame + tactParameters.y)];
    [line stroke];
}

- (void) setFirstDataAndCommand {
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.lineWidth = 1.f;
    CGFloat buferValue = lineCbe + blockParameters.y/2;
    
    for (int i = 0; i < valueOfLines; i++) {
        [line moveToPoint:NSMakePoint(0, buferValue)];
        [line lineToPoint:NSMakePoint(self.bounds.size.width, buferValue)];
        if (i == valueOfLines/2 - 1) {
            buferValue = lineAd + blockParameters.y/2;
        } else {
            buferValue += (lineAd - lineCbe)/2;
        }
    }
    
    [line stroke];
    buferValue = lineCbe + blockParameters.y/2;
    CGFloat step = 0;
    
    for (int j = 0; j < numberOfAddress; j++) {
        
        for (int i = 0; i < valueOfLines; i++) {
            [self drawCellWhichStartAt:NSMakePoint(blockParameters.x - blockParameters.x/6 + step, buferValue)
                             withColor:[NSColor yellowColor]
                             andLength:blockParameters.x];
            
            if (i == valueOfLines/2 - 1) {
                buferValue = lineAd + blockParameters.y/2;
            } else {
                buferValue += (lineAd - lineCbe)/2;
            }
        }
        
        step += blockParameters.x;
        buferValue = lineCbe + blockParameters.y/2;
    }
}

- (void) setBlocks {
    
    CGFloat positionOfDelay = 0;
    CGFloat delay = 0;
    CGFloat step = dataStart;
    CGFloat linesStep;
    for (int i = 0; i < _letters; i++) {
        delay = ceilf((CGFloat) [[_arrayOfDelays objectAtIndex:positionOfDelay] integerValue]/30);
        step += blockParameters.x * delay;
        linesStep = lineCbe + blockParameters.y/2;
        positionOfDelay = (positionOfDelay != [_arrayOfDelays count] - 1) ? positionOfDelay + 1 : 0;
        
        for (int j = 0; j < valueOfLines; j++) {
            if (j < valueOfLines/2) {
                [self drawCellWhichStartAt:NSMakePoint(step - blockParameters.x, linesStep)
                                 withColor:[NSColor redColor]
                                 andLength:blockParameters.x];
                linesStep += (lineAd - lineCbe)/2;
            } else {
                [self drawCellWhichStartAt:NSMakePoint(step - blockParameters.x, linesStep)
                                 withColor:[NSColor greenColor]
                                 andLength:blockParameters.x];
                linesStep += (lineAd - lineCbe)/2;
            }
            if (j == valueOfLines/2 - 1) {
                linesStep = lineAd + blockParameters.y/2;
            }
        }
    }
    frameEnd = step - blockParameters.x;
}

- (void) setIrdy {
    
    NSInteger positionOfDelay = 0;
    NSInteger delay;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    line.lineWidth = 1.f;
    NSInteger step = dataStart;
    [line moveToPoint:NSMakePoint(0, lineIrdy + tactParameters.y)];
    
    for (int i = 0; i < _letters; i++) {
        
        delay = [[_arrayOfDelays objectAtIndex:positionOfDelay] integerValue]/30;
        if (delay != (CGFloat)[[_arrayOfDelays objectAtIndex:positionOfDelay] integerValue]/30) {
            delay++;
        }
        step += blockParameters.x * delay;
        if (i == 0) {
            [line lineToPoint:NSMakePoint(step - blockParameters.x - blockParameters.x/10, lineIrdy + tactParameters.y)];
            [line lineToPoint:NSMakePoint(step - blockParameters.x + blockParameters.x/10, lineIrdy)];
        }
        if (delay > 1 && i != 0) {
            
            [line lineToPoint:NSMakePoint(step - (blockParameters.x * delay + blockParameters.x/10), lineIrdy)];
            [line lineToPoint:NSMakePoint(step - (blockParameters.x * delay - blockParameters.x/10), lineIrdy + tactParameters.y)];
            [line lineToPoint:NSMakePoint(step - blockParameters.x - blockParameters.x/10, lineIrdy + tactParameters.y)];
            [line lineToPoint:NSMakePoint(step - blockParameters.x + blockParameters.x/10, lineIrdy)];
        }
        
        if (i == _letters - 1) {
            [line lineToPoint:NSMakePoint(step - blockParameters.x/10, lineIrdy)];
            [line lineToPoint:NSMakePoint(step + blockParameters.x/10, lineIrdy + tactParameters.y)];
            [line lineToPoint:NSMakePoint(self.bounds.size.width, lineIrdy + tactParameters.y)];
        }
        
        if (positionOfDelay != [_arrayOfDelays count] - 1) {
            positionOfDelay++;
        } else {
            positionOfDelay = 0;
        }
    }
    [line stroke];
}

- (void) setTrdyOrDevSel:(NSInteger) line {
    NSBezierPath *drawer = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    drawer.lineWidth = 1.f;
    [drawer moveToPoint:NSMakePoint(0, line + tactParameters.y)];
    [drawer lineToPoint:NSMakePoint(2 * blockParameters.x - (blockParameters.x/10), line + tactParameters.y)];
    [drawer lineToPoint:NSMakePoint(2 * blockParameters.x + (blockParameters.x/10), line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + blockParameters.x - blockParameters.x/10, line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + blockParameters.x + blockParameters.x/10, line + tactParameters.y)];
    [drawer lineToPoint:NSMakePoint(self.bounds.size.width, line + tactParameters.y)];
    [drawer stroke];
}

- (void) drawCellWhichStartAt:(NSPoint) point withColor:(NSColor *) color andLength:(CGFloat) length {
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:10], NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString * currentText;
    
    NSBezierPath *cellDrawer = [NSBezierPath bezierPath];
    [color set];
    cellDrawer.lineWidth = 1.f;
    [cellDrawer moveToPoint:point];
    CGFloat part = blockParameters.y/2;
    
    for (int i = 0; i < 2; i++) {
        [cellDrawer moveToPoint:point];
        [cellDrawer lineToPoint:NSMakePoint(point.x + blockParameters.y/6, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + length - blockParameters.y/6, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + length, point.y)];
        part *= -1;
    }
    
    [cellDrawer fill];
    [[NSColor blackColor] set];
    [cellDrawer stroke];
    if (point.y == lineCbe + blockParameters.y/2) {
        if ([color isEqual:[NSColor yellowColor]]) {
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", _command]
                                                          attributes:attributes];
        } else {
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", _bitWord]
                                                          attributes:attributes];
        }
    } else {
        if ([color isEqual:[NSColor yellowColor]]) {
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Addr"]
                                                          attributes:attributes];
        } else {
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  C"]
                                                          attributes:attributes];
        }
    }
    
    if (point.y == lineCbe + blockParameters.y/2 && valueOfLines == 3) {
        if (point.x == blockParameters.x - blockParameters.x/6) {
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"1101"]
                                                          attributes:attributes];
        }
    }
    
    if (coefficient > 0.5) {
        [currentText drawInRect:NSMakeRect(point.x + length/4, point.y - blockParameters.y/4, length, blockParameters.y/2)];
    }
}

@end
