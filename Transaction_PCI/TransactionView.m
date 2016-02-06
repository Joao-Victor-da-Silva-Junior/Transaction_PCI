
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
    CGFloat scale;
    CGFloat blockHeight;
    NSInteger startTact;
    NSBezierPath *mainLine;
}
@end

@implementation TransactionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    mainLine = [NSBezierPath bezierPath];
    mainLine.lineWidth = 1.f;
    
    scale = [self.mainDictionary[@"Scale"] floatValue];
    blockHeight = [self.mainDictionary[@"Block Height"] floatValue];
    startTact = [self.mainDictionary[@"Start Tact"] integerValue];

    [self setHelpersLine];
    [self setPulse];
    [self setBlockLines];
    [self setFrame];
    [self setIrdy];
    [self setTrdyOrDevSel:lineTrdy];
    [self setTrdyOrDevSel:lineDevSel];
    [mainLine stroke];
    [self setFirstDataAndCommand];
    [self setBlocks];
}

#pragma mark - Draw Methods

-(void) setHelpersLine {
    CGFloat step = 60;
    CGFloat dash[] = {15.f, 15.f};
    __block NSBezierPath *line = [NSBezierPath bezierPath];
    [line setLineWidth:1.f];
    [line setLineDash:dash
                count:2
                phase:1];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:9], NSFontAttributeName,[NSColor blackColor], NSForegroundColorAttributeName, nil];
    
    NSAttributedString * currentText;

    NSInteger counter = 1;
    void (^drawHelpersLineWithPosAndIsX)(CGFloat, BOOL) = ^(CGFloat pos, BOOL isX) {
        if (isX) {
            [line moveToPoint:NSMakePoint(0, pos)];
            [line lineToPoint:NSMakePoint(self.bounds.size.width, pos)];
        } else {
            [line moveToPoint:NSMakePoint(pos, 0)];
            [line lineToPoint:NSMakePoint(pos, self.bounds.size.height)];
        }
    };
    
    for (int i = 0; i < 7; i++) {
        drawHelpersLineWithPosAndIsX(self.bounds.size.height - step, YES);
        step += 60;
    }
    
    if ([_mainDictionary[@"Number of AD"] integerValue] == 2) {
        drawHelpersLineWithPosAndIsX(lineAd + (lineAd - lineCbe) /2, YES);
    }
    
    if ([_mainDictionary[@"Number of CBE"] integerValue] == 2) {
        drawHelpersLineWithPosAndIsX(lineCbe + (lineAd - lineCbe) /2, YES);
    }
    
    step = scale/3;
    while (step < self.bounds.size.width) {
        
        currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", counter]
                                                      attributes:attributes];
        
        [currentText drawAtPoint:NSMakePoint(step + scale / 10, self.bounds.size.height-20)];

        drawHelpersLineWithPosAndIsX(step + scale / 10,NO);
        step += scale;
        counter++;
    }
    
    [line stroke];
}

- (void) setPulse {
    CGFloat step = 0.;
    NSInteger counter = 0;
    NSPoint lowPoint = {step, lineClk};
    NSPoint highPoint = {step + scale/2, lineClk + scale * 2 / 3};
    
    while (counter < self.bounds.size.width) {
        [mainLine moveToPoint:lowPoint];
        lowPoint.x += scale/3;
        [mainLine lineToPoint:lowPoint];
        [mainLine lineToPoint:highPoint];
        highPoint.x += scale/3;
        [mainLine lineToPoint:highPoint];
        lowPoint.x += scale * 2/3;
        [mainLine lineToPoint:lowPoint];
        step += scale;
        lowPoint.x = step;
        highPoint.x = step + scale/2;
        counter += scale;
    }
}

- (void) setBlockLines {
    void (^drawLine)(NSInteger, CGFloat) = ^(NSInteger num, CGFloat yPos) {
        NSInteger step = 0;
        for (int i = 0; i < num; i++) {
            [mainLine moveToPoint:NSMakePoint(0, yPos + blockHeight/2 + step)];
            [mainLine lineToPoint:NSMakePoint(self.bounds.size.width, yPos + blockHeight/2 + step)];
            step += (lineAd - lineCbe)/ 2;
        }
    };
    drawLine([_mainDictionary[@"Number of AD"] integerValue], lineAd);
    drawLine([_mainDictionary[@"Number of CBE"] integerValue], lineCbe);
}

- (void) setFrame {
    CGFloat frameEnd = [self.mainDictionary[@"Frame End"] floatValue];
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line setLineWidth:1.f];
    [line moveToPoint:NSMakePoint(0, lineFrame + scale * 2/3)];
    [line lineToPoint:NSMakePoint((scale * 2)/3 + (scale/10), lineFrame + scale * 2/3)];
    [line lineToPoint:NSMakePoint(scale - (scale/20), lineFrame)];
    [line lineToPoint:NSMakePoint(frameEnd - (scale/10), lineFrame)];
    [line lineToPoint:NSMakePoint(frameEnd + (scale/10), lineFrame + scale * 2/3)];
    [line lineToPoint:NSMakePoint(self.bounds.size.width, lineFrame + scale * 2/3)];
    [line stroke];
}

- (void) setFirstDataAndCommand {
    
    void (^drawBlock)(NSInteger, CGFloat) = ^(NSInteger num, CGFloat yourLine) {
        for (int j = 0; j < startTact; j++) {
            for (int i = 0; i < num; i++) {
                [self drawCellWhichStartAt:NSMakePoint((j + 1)*scale - scale/6, yourLine + blockHeight/2 + (lineAd - lineCbe)*i/2)
                                 withColor:[NSColor yellowColor]
                                 andHeight:blockHeight];
            }
        }
    };

    drawBlock([self.mainDictionary[@"Number of AD"] integerValue], lineAd);
    drawBlock([self.mainDictionary[@"Number of CBE"] integerValue], lineCbe);
}

- (void) setBlocks {
    NSInteger numberOfBlocks = [self.mainDictionary[@"Num of Blocks"] integerValue];
    NSMutableArray *arrayOfDelays = self.mainDictionary[@"Access"];
    __block NSInteger counter = startTact;
    
    void (^drawBlock)(NSInteger, CGFloat) = ^(NSInteger num, CGFloat yourLine) {
        for (int i = 0; i < num; i++) {
            [self drawCellWhichStartAt:NSMakePoint(counter * scale - scale/6, yourLine + blockHeight/2 + (lineAd - lineCbe)*i/2)
                             withColor:yourLine == lineCbe ? [NSColor redColor] : [NSColor greenColor]
                             andHeight:blockHeight];
        }
    };
    for (int i = 0; i < numberOfBlocks; i++) {
        counter += ([[arrayOfDelays objectAtIndex:i % [arrayOfDelays count]] integerValue] - 1);
        drawBlock([self.mainDictionary[@"Number of CBE"] integerValue], lineCbe);
        drawBlock([self.mainDictionary[@"Number of AD"] integerValue], lineAd);
        counter++;
    }
}

- (void) setIrdy {
    __block NSBezierPath *irdyLine = [NSBezierPath bezierPath];
    __block BOOL isOnUp = YES;
    __block CGFloat counter = startTact;
    irdyLine.lineWidth = 1.f;
    NSInteger delay = 0;
    [irdyLine moveToPoint:NSMakePoint(0, lineIrdy + scale * 2/3)];
    void (^changeSide)(void) = ^ {
        if (!isOnUp) {
            [irdyLine lineToPoint:NSMakePoint(counter * scale - scale * 1/3, lineIrdy)];
            [irdyLine lineToPoint:NSMakePoint(counter * scale - scale/10, lineIrdy + scale * 2/3)];
        } else {
            [irdyLine lineToPoint:NSMakePoint(counter * scale - scale/5, lineIrdy + scale * 2/3)];
            [irdyLine lineToPoint:NSMakePoint(counter * scale, lineIrdy)];
        }
    };
    
    for (int i = 0; i < [_mainDictionary[@"Num of Blocks"] integerValue]; i++) {
        delay = [[_mainDictionary[@"Access"] objectAtIndex:(i % [_mainDictionary[@"Access"] count]) ] integerValue];
        
        if (!isOnUp && delay != 1) {
            changeSide();
            isOnUp = YES;
        }
        if (delay != 1) {
            counter += delay - 1;
            changeSide();
            counter ++;
            isOnUp = NO;
        } else if (isOnUp) {
            changeSide();
            isOnUp = NO;
            counter ++;
        } else {
            counter ++;
        }
    }
    changeSide();
    [irdyLine lineToPoint:NSMakePoint(self.bounds.size.width, lineIrdy + scale * 2/3)];
    [irdyLine stroke];
}

- (void) setTrdyOrDevSel:(NSInteger) line {
    CGFloat frameEnd = [self.mainDictionary[@"Frame End"] floatValue];
    NSBezierPath *drawer = [NSBezierPath bezierPath];
    drawer.lineWidth = 1.f;
    [drawer moveToPoint:NSMakePoint(0, line + scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(2 * scale * 9/10, line + scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(2 * scale, line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + scale * 2/3, line)];
    [drawer lineToPoint:NSMakePoint(frameEnd + scale * 9/10, line + scale * 2/3)];
    [drawer lineToPoint:NSMakePoint(self.bounds.size.width, line + scale * 2/3)];
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
        [cellDrawer lineToPoint:NSMakePoint(point.x + scale / 9, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + scale - scale / 9, point.y + part)];
        [cellDrawer lineToPoint:NSMakePoint(point.x + scale, point.y)];
        part *= -1;
    }
    
    [cellDrawer fill];
    [[NSColor blackColor] set];
    [cellDrawer stroke];
}

@end
