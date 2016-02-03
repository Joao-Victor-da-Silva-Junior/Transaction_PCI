
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
    CGFloat blockHeight;
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
    _scale = [self.mainDictionary[@"Scale"] floatValue];
    blockHeight = [self.mainDictionary[@"Block Height"] floatValue];
    
    [self setHelpersLine];
    [self setPulse];
    [self setBlockLines];
    [self setFirstDataAndCommand];
    [self setADBlocks];
    [self setCbeBlocks];
    [self setFrame];
    [self setIrdy];
    [self setTrdyOrDevSel:lineTrdy];
    [self setTrdyOrDevSel:lineDevSel];
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
    } // Горизонтальные
    
    if ([_mainDictionary[@"Number of AD"] integerValue] == 2) {
        [line moveToPoint:NSMakePoint(0, lineAd + (lineAd - lineCbe) /2)];
        [line lineToPoint:NSMakePoint(self.bounds.size.width, lineAd + (lineAd - lineCbe) /2)];
    }
    
    if ([_mainDictionary[@"Number of CBE"] integerValue] == 2) {
        [line moveToPoint:NSMakePoint(0, lineCbe + (lineAd - lineCbe) /2)];
        [line lineToPoint:NSMakePoint(self.bounds.size.width, lineCbe + (lineAd - lineCbe) /2)];
    }
    
    step = _scale/3;
    while (step < self.bounds.size.width) {
        
        currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", counter]
                                                      attributes:attributes];
        
        [currentText drawAtPoint:NSMakePoint(step + _scale / 10, self.bounds.size.height-20)];

        [line moveToPoint:NSMakePoint(step + _scale / 10, 0)];
        [line lineToPoint:NSMakePoint(step + _scale / 10, self.bounds.size.height)];
        step += _scale;
        counter++;
    } //Вертикальные
    
    [line stroke];
} //Пока что не трогать

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
}

- (void) setBlockLines {
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.lineWidth = 1.f;
    [[NSColor blackColor] set];
    [line moveToPoint:NSMakePoint(0, lineAd + blockHeight/2)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width, lineAd + blockHeight/2)];
    [line moveToPoint:NSMakePoint(0, lineCbe + blockHeight/2)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width, lineCbe + blockHeight/2)];
    [line stroke];
}

- (void) setFrame {
    CGFloat frameEnd = [self.mainDictionary[@"Frame End"] floatValue];
    NSBezierPath *line = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    [line setLineWidth:1.f];
    [line moveToPoint:NSMakePoint(0, lineFrame + _scale * 2/3)];
    [line lineToPoint:NSMakePoint((_scale * 2)/3 + (_scale/10), lineFrame + _scale * 2/3)];
    [line lineToPoint:NSMakePoint(_scale - (_scale/20), lineFrame)];
    [line lineToPoint:NSMakePoint(frameEnd - (_scale/10), lineFrame)];
    [line lineToPoint:NSMakePoint(frameEnd + (_scale/10), lineFrame + _scale * 2/3)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width, lineFrame + _scale * 2/3)];
    [line stroke];

}

- (void) setFirstDataAndCommand {
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.lineWidth = 1.f;
    NSInteger numOfDatas = [self.mainDictionary[@"Start Tact"] integerValue];
    
    for (int i = 0; i < numOfDatas - 1; i++) {
        [self drawCellWhichStartAt:NSMakePoint(_scale * (i+1) - _scale/6, lineAd + blockHeight/2)
                         withColor:[NSColor yellowColor]
                         andHeight:blockHeight];
        
        [self drawCellWhichStartAt:NSMakePoint(_scale * (i+1) - _scale/6, lineCbe + blockHeight/2)
                         withColor:[NSColor yellowColor]
                         andHeight:blockHeight];
    }
}

- (void) setADBlocks {
    NSInteger numberOfBlocks = [self.mainDictionary[@"Num of Blocks"] integerValue];
    NSMutableArray *arrayOfDelays = self.mainDictionary[@"Access"];
    NSInteger counter = [self.mainDictionary[@"Start Tact"] integerValue];
    for (int i = 0; i < numberOfBlocks; i++) {
        counter += ([[arrayOfDelays objectAtIndex:i % [arrayOfDelays count]] integerValue] - 1);
        NSLog(@"%ld", (long)[[arrayOfDelays objectAtIndex:i % [arrayOfDelays count]] integerValue]);
        [self drawCellWhichStartAt:NSMakePoint(counter * _scale - _scale/6, lineAd + blockHeight/2)
                         withColor:[NSColor redColor]
                         andHeight:blockHeight];
        counter++;
        
    }
}

- (void) setCbeBlocks {
    NSInteger numberOfBlocks = [self.mainDictionary[@"Num of Blocks"] integerValue];
    NSMutableArray *arrayOfDelays = self.mainDictionary[@"Access"];
    NSInteger counter = [self.mainDictionary[@"Start Tact"] integerValue];
    for (int i = 0; i < numberOfBlocks; i++) {
        counter += ([[arrayOfDelays objectAtIndex:i % [arrayOfDelays count]] integerValue] - 1);
        [self drawCellWhichStartAt:NSMakePoint(counter * _scale - _scale/6, lineCbe + blockHeight/2)
                         withColor:[NSColor greenColor]
                         andHeight:blockHeight];
        counter++;
        
    }
} //Хорошо, но код дублируется с AD.

- (void) setIrdy {
    NSBezierPath *irdyLine = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    irdyLine.lineWidth = 1.f;
    CGFloat counter = [_mainDictionary[@"Start Tact"] integerValue];
    NSInteger delay = 0;
    [irdyLine moveToPoint:NSMakePoint(0, lineIrdy + _scale * 2/3)];
    BOOL isOnUp = YES;
    for (int i = 0; i < [_mainDictionary[@"Num of Blocks"] integerValue]; i++) {
        delay = [[_mainDictionary[@"Access"] objectAtIndex:(i % [_mainDictionary[@"Access"] count]) ] integerValue];
        
        if (!isOnUp && delay != 1) {
            [irdyLine lineToPoint:NSMakePoint(counter * _scale - _scale * 1/3, lineIrdy)];
            [irdyLine lineToPoint:NSMakePoint(counter * _scale - _scale/10, lineIrdy + _scale * 2/3)];
            isOnUp = YES;
        }
        if (delay != 1) {
                counter += delay - 1;
                [irdyLine lineToPoint:NSMakePoint(counter * _scale - _scale/5, lineIrdy + _scale * 2/3)];
                [irdyLine lineToPoint:NSMakePoint(counter * _scale, lineIrdy)];
                counter ++;
                isOnUp = NO;
        } else if (isOnUp) {
            [irdyLine lineToPoint:NSMakePoint(counter * _scale - _scale/5, lineIrdy + _scale * 2/3)];
            [irdyLine lineToPoint:NSMakePoint(counter * _scale, lineIrdy)];
            isOnUp = NO;
            counter ++;
        } else {
            counter ++;
        }
    }
    [irdyLine lineToPoint:NSMakePoint(counter * _scale - _scale * 1/3, lineIrdy)];
    [irdyLine lineToPoint:NSMakePoint(counter * _scale - _scale * 1/10, lineIrdy + _scale * 2/3)];
    [irdyLine lineToPoint:NSMakePoint(self.bounds.size.width, lineIrdy + _scale * 2/3)];
    [irdyLine stroke];
}

- (void) setTrdyOrDevSel:(NSInteger) line {
    CGFloat frameEnd = [self.mainDictionary[@"Frame End"] floatValue];
    NSBezierPath *drawer = [NSBezierPath bezierPath];
    [[NSColor blackColor] set];
    drawer.lineWidth = 1.f;
    [drawer moveToPoint:NSMakePoint(0, line + _scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(2 * _scale * 9/10, line + _scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(2 * _scale, line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + _scale * 2/3, line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + _scale * 9/10, line + _scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(self.bounds.size.width, line + _scale * 2/3)];
    [drawer stroke];
} //Пока что не трогать. Нечего менять

/*- (void) drawCellWhichStartAt:(NSPoint) point withColor:(NSColor *) color andLength:(CGFloat) length {
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:10], NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString * currentText;
    
    NSBezierPath *cellDrawer = [NSBezierPath bezierPath];
    [color set];
    cellDrawer.lineWidth = 1.f;
    [cellDrawer moveToPoint:point];
    CGFloat part = _scale / 3;
    
    for (int i = 0; i < 2; i++) {
        [cellDrawer moveToPoint:point];
        [cellDrawer lineToPoint:NSMakePoint(point.x + _scale / 9, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + length - _scale / 9, point.y + part)];
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
        if (point.x == blockParameters.x - blockParameters.x / 6) {
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"1101"]
                                                          attributes:attributes];
        }
    }
    
    if (coefficient > 0.5) {
        [currentText drawInRect:NSMakeRect(point.x + length / 4, point.y - blockParameters.y / 4, length, blockParameters.y / 2)];
    }
} //Переписать*/

- (void) drawCellWhichStartAt:(NSPoint) point
                    withColor:(NSColor *) color
                    andHeight:(CGFloat) height {
    NSBezierPath *cellDrawer = [NSBezierPath bezierPath];
    [color set];
    cellDrawer.lineWidth = 1.f;
    [cellDrawer moveToPoint:point];
    CGFloat part = height/2;
    
    for (int i = 0; i < 2; i++) {
        [cellDrawer moveToPoint:point];
        [cellDrawer lineToPoint:NSMakePoint(point.x + _scale / 9, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + _scale - _scale / 9, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + _scale, point.y)];
        part *= -1;
    }
    [cellDrawer fill];
    [[NSColor blackColor] set];
    [cellDrawer stroke];
}
@end
