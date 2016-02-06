
#import <Cocoa/Cocoa.h>

@interface TransactionView : NSView

@property (assign, nonatomic) BOOL firstLaunch;
@property (strong, nonatomic) NSMutableDictionary *mainDictionary;

@end