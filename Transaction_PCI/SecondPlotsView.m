
#import "SecondPlotsView.h"

@implementation SecondPlotsView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    [self drawPlot];
}

- (void) drawPlot {
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:10], NSFontAttributeName,[NSColor blackColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString * currentText;
    
    
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    line.lineWidth = 2.f;
    CGFloat bit = 8;
    NSInteger step = 0;
    [line moveToPoint:NSMakePoint(step, 30 * bit/4)];
    for (int i = 0; i < 3; i++) {
        bit *= 2;
        step += self.bounds.size.width/2;
        [line lineToPoint:NSMakePoint(step, 30 * bit/4)];
        currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", 30 * bit]
                                                      attributes:attributes];
        [currentText drawAtPoint:NSMakePoint(0, 30 * bit/4 - 10)];
        
        currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", bit/2]
                                                      attributes:attributes];
        [currentText drawAtPoint:NSMakePoint(step - self.bounds.size.width/2, 10)];
    }
    currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.f", bit]
                                                  attributes:attributes];
    [currentText drawAtPoint:NSMakePoint(self.bounds.size.width - 15, 10)];
    [[NSColor blueColor] set];
    [line stroke];

}
@end
