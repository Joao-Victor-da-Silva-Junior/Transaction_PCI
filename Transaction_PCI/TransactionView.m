
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
    CGFloat coefficient;     //Хлам!
    NSPoint blockParameters; //Хлам!
    NSPoint tactParameters;  //Хлам!
    NSInteger tactCount;     //Хлам!
    CGFloat dataStart;       //Хлам!
    CGFloat frameEnd;        //Хлам!
    NSInteger valueOfLines;  //Хлам!
    NSInteger numberOfAddress;//Хлам!
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
        tactCount = ceilf((CGFloat)_timeInterval * 1000/30);
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
    
    step = _scale/3;
    while (step < self.bounds.size.width) {
        
        currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", counter]
                                                      attributes:attributes];
        
        [currentText drawAtPoint:NSMakePoint(step + _scale/10, self.bounds.size.height-20)];

        [line moveToPoint:NSMakePoint(step + _scale/10, 0)];
        [line lineToPoint:NSMakePoint(step + _scale/10, self.bounds.size.height)];
        step += _scale;
        counter++;
    }
    
    [line stroke];
} //Пока что не трогать

/*- (void) setPulse {
    
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
}*/

- (void) setPulse {
    CGFloat step = 0.;
    NSInteger counter = 0;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    line.lineWidth = 1.f;
    NSPoint lowPoint = {step, lineClk};
    NSPoint highPoint = {step + _scale/2, lineClk + _scale * 2 / 3};
    
    while (counter < self.bounds.size.width) {
        [line moveToPoint:lowPoint];
        lowPoint.x += _scale/3;
        [line lineToPoint:lowPoint];
        [line lineToPoint:highPoint];
        highPoint.x += _scale/3;
        [line lineToPoint:highPoint];
        lowPoint.x += _scale * 2/3;
        [line lineToPoint:lowPoint];
        [line stroke];
        step += _scale;
        lowPoint.x = step;
        highPoint.x = step + _scale/2;
        counter += _scale;
    }
} // Меньше параметров. Зачем нам tactParameters, если есть масштаб и постоянное отношение 2:3?

/*- (void) setFrame {
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
}*/

- (void) setFrame {
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    [line setLineWidth:1.f];
    [line moveToPoint:NSMakePoint(0, lineFrame + _scale * 2/3)];
    [line lineToPoint:NSMakePoint((_scale * 2)/3 + (_scale/10), lineFrame + _scale * 2/3)];
    [line lineToPoint:NSMakePoint(_scale - (_scale/20), lineFrame)];
    [line lineToPoint:NSMakePoint(_frameEnd - (_scale/10), lineFrame)];
    [line lineToPoint:NSMakePoint(_frameEnd + (_scale/10), lineFrame + _scale * 2/3)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width, lineFrame + _scale * 2/3)];
    [line stroke];

}

- (void) setFirstDataAndCommand {
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.lineWidth = 1.f;
    CGFloat buferValue = lineCbe + _scale/3;
    
    for (int i = 0; i < valueOfLines; i++) {
        [line moveToPoint:NSMakePoint(0, buferValue)];
        [line lineToPoint:NSMakePoint(self.bounds.size.width, buferValue)];
        if (i == valueOfLines/2 - 1) {
            buferValue = lineAd + _scale/3;
        } else {
            buferValue += (lineAd - lineCbe)/2;
        }
    }
    
    [line stroke];
    buferValue = lineCbe + _scale/3;
    CGFloat step = 0;
    
    for (int j = 0; j < numberOfAddress; j++) {
        
        for (int i = 0; i < valueOfLines; i++) {
            [self drawCellWhichStartAt:NSMakePoint(_scale - _scale/6 + step, buferValue)
                             withColor:[NSColor yellowColor]
                             andLength:_scale];
            
            if (i == valueOfLines/2 - 1) {
                buferValue = lineAd + _scale/3;
            } else {
                buferValue += (lineAd - lineCbe)/2;
            }
        }
        
        step += _scale;
        buferValue = lineCbe + _scale/3;
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
        linesStep = lineCbe + _scale/3;
        positionOfDelay = (positionOfDelay != [_arrayOfDelays count] - 1) ? positionOfDelay + 1 : 0;
        
        for (int j = 0; j < valueOfLines; j++) {
            if (j < valueOfLines/2) {
                [self drawCellWhichStartAt:NSMakePoint(step - _scale, linesStep)
                                 withColor:[NSColor redColor]
                                 andLength:_scale];
                linesStep += (lineAd - lineCbe)/2;
            } else {
                [self drawCellWhichStartAt:NSMakePoint(step - _scale, linesStep)
                                 withColor:[NSColor greenColor]
                                 andLength:_scale];
                linesStep += (lineAd - lineCbe)/2;
            }
            if (j == valueOfLines/2 - 1) {
                linesStep = lineAd + _scale/3;
            }
        }
    }
    frameEnd = step - _scale;
}

- (void) setIrdy {
    
    NSInteger positionOfDelay = 0;
    NSInteger delay;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    line.lineWidth = 1.f;
    NSInteger step = dataStart;
    [line moveToPoint:NSMakePoint(0, lineIrdy + _scale * 2/3)];
    
    for (int i = 0; i < _letters; i++) {
        
        delay = [[_arrayOfDelays objectAtIndex:positionOfDelay] integerValue]/30;
        if (delay != (CGFloat)[[_arrayOfDelays objectAtIndex:positionOfDelay] integerValue]/30) {
            delay++;
        }
        step += _scale * delay;
        if (i == 0) {
            [line lineToPoint:NSMakePoint(step - _scale - _scale/10, lineIrdy + _scale * 2/3)];
            [line lineToPoint:NSMakePoint(step - _scale + _scale/10, lineIrdy)];
        }
        if (delay > 1 && i != 0) {
            
            [line lineToPoint:NSMakePoint(step - (_scale * delay + _scale/10), lineIrdy)];
            [line lineToPoint:NSMakePoint(step - (_scale * delay - _scale/10), lineIrdy + _scale * 2/3)];
            [line lineToPoint:NSMakePoint(step - _scale - _scale/10, lineIrdy + _scale * 2/3)];
            [line lineToPoint:NSMakePoint(step - _scale + _scale/10, lineIrdy)];
        }
        
        if (i == _letters - 1) {
            [line lineToPoint:NSMakePoint(step - _scale/10, lineIrdy)];
            [line lineToPoint:NSMakePoint(step + _scale/10, lineIrdy + _scale * 2/3)];
            [line lineToPoint:NSMakePoint(self.bounds.size.width, lineIrdy + _scale * 2/3)];
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
    [drawer moveToPoint:NSMakePoint(0, line + _scale *2/3)];
    [drawer lineToPoint:NSMakePoint(2 * _scale - (_scale/10), line + _scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(2 * _scale + (_scale/10), line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + _scale - _scale/10, line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + _scale + _scale/10, line + _scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(self.bounds.size.width, line + _scale * 2/3)];
    [drawer stroke];
} //Пока что не трогать

- (void) drawCellWhichStartAt:(NSPoint) point withColor:(NSColor *) color andLength:(CGFloat) length {
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:10], NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString * currentText;
    
    NSBezierPath *cellDrawer = [NSBezierPath bezierPath];
    [color set];
    cellDrawer.lineWidth = 1.f;
    [cellDrawer moveToPoint:point];
    CGFloat part = _scale/3;
    
    for (int i = 0; i < 2; i++) {
        [cellDrawer moveToPoint:point];
        [cellDrawer lineToPoint:NSMakePoint(point.x + _scale * 2/3/6, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + length - _scale *2/3/6, point.y + part)];
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
