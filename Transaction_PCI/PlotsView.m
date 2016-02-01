
#import "PlotsView.h"

@implementation PlotsView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    [[NSColor redColor] set];
    [self drawHelpersLine];
    
    [_arrayOfEightBits sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSPoint point1 = [obj1 pointValue];
        NSPoint point2 = [obj2 pointValue];
        if (point1.y < point2.y) {
            return NSOrderedDescending;
        }
        if (point1.y > point2.y) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    
        [self drawPlotUsingBits:8 fromArray:_arrayOfEightBits];
        [self drawPlotUsingBits:16 fromArray:_arrayOfSixteenBits];
        [self drawPlotUsingBits:32 fromArray:_arrayOfThirtyTwoBits];
}

- (void) drawPlotUsingBits: (NSInteger) bits fromArray:(NSMutableArray *) array {
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:8], NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString * currentText;
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.lineWidth = 2.f;
    NSPoint somePoint = NSMakePoint([[array objectAtIndex:0] pointValue].x,  30 * bits *[[array objectAtIndex:0] pointValue].y/4);
    [line moveToPoint:somePoint];
    
    for (int i = 1; i < [array count]; i++) {
        
        somePoint = NSMakePoint([[array objectAtIndex:i] pointValue].x, 30 * bits *[[array objectAtIndex:i] pointValue].y/4);
        [line lineToPoint:somePoint];
        currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.3f", [[array objectAtIndex:i] pointValue].y]
                                                      attributes:attributes];
        [currentText drawAtPoint:NSMakePoint([[array objectAtIndex:i] pointValue].x - 5, 0)];
    }
    
    [[NSColor redColor] set];
    [line stroke];
}

- (void) drawHelpersLine {
    CGFloat dash[] = {5.f, 5.f};
    NSBezierPath *line = [NSBezierPath bezierPath];
    NSInteger step = self.bounds.size.width/10;
    [[NSColor blackColor] set];
    [line setLineWidth:1.f];
    [line setLineDash:dash
                count:2
                phase:1];
    for (int i = 0; i < 9; i++) {
        [line moveToPoint:NSMakePoint(step, 0)];
        [line lineToPoint:NSMakePoint(step, 240)];
        step += self.bounds.size.width/10;
    }
    [line stroke];
}

@end
