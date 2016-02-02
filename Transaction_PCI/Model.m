
#import "Model.h"
#import "NSString+CommandEqual.h"

@implementation Model

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mainDictionary = [NSMutableDictionary dictionary];
        _mainDictionary[@"Scale"] = @60.f;
        _mainDictionary[@"Frame End"] = @660.f;
    }
    return self;
}

+ (NSMutableDictionary *) returnRandomValues {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    return dictionary;
}

+ (NSMutableDictionary *) returnDictionaryUsingCells:(BOOL) isCells
                                         parameters:(NSInteger) param
                                            bitWord:(NSInteger) bitWord
                                             command:(NSInteger) cmd
                                        digitAddress:(NSInteger) digAdr
                                          accessTime:(NSInteger) access
                                       andViewAccess:(NSString *) view  {
    
    NSMutableArray* (^returnNewArray) (NSString *, NSInteger) = ^(NSString *array, NSInteger access) {
        NSMutableArray *newArray = [NSMutableArray array];
        NSInteger delay;
        while (![array isEqualToString:@""]) {
            delay = ceilf((CGFloat) [array integerValue] * access/30);
            [newArray addObject:[NSNumber numberWithInteger:delay]];
            if ([array length] != 1) {
                array = [array substringFromIndex:2];
            } else {
                array = [array substringFromIndex:1];
            }
        }
        return newArray;
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    dictionary[@"Bit Word"] = [NSString returnBitWordFrom:bitWord];
    dictionary[@"Command"] = [NSString returnCommandFrom:cmd];
    dictionary[@"Access"] = returnNewArray(view, access);
    //dictionary[@"Num of Blocks"] = [NSNumber numberWithInteger:param];
    CGFloat tactCount;
    if (isCells) {
        dictionary[@"Num of Blocks"] = [NSNumber numberWithInteger:param];
        
    } else {
        tactCount = ceilf((CGFloat)param * 1000/30);
        dictionary[@"Scale"] = [NSNumber numberWithFloat:(CGFloat)960/tactCount];
        dictionary[@"Num of Blocks"] = [NSNumber numberWithInteger:tactCount - 5];
    }
    
    return dictionary;
}

@end
