
typedef enum {
    cells,
    timeInterval
} drawMode;

#import <Cocoa/Cocoa.h>

@interface TransactionView : NSView

@property (assign, nonatomic) NSInteger letters;
@property (strong, nonatomic) NSArray *arrayOfDelays;
@property (assign, nonatomic) BOOL firstLaunch;
@property (assign, nonatomic) CGFloat timeInterval;
@property (assign, nonatomic) drawMode drawModeIs;
@property (strong, nonatomic) NSString *bitWord;
@property (strong, nonatomic) NSString *command;
@property (strong, nonatomic) NSString *digitAddress;

@end
