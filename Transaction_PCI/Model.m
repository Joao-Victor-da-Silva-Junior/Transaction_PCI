
#import "Model.h"
#import "NSString+CommandEqual.h"

@implementation Model

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mainDictionary = [NSMutableDictionary dictionary];
        _mainDictionary[@"Scale"] = @60.f;
    }
    return self;
}

+ (NSMutableDictionary *) returnRandomValues {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    return dictionary;
}

+ (NSMutableDictionary *) returnDictionaryUsingCells:(BOOL) isCells
                                         parameters:(CGFloat) param
                                            bitWord:(NSInteger) bitWord
                                             command:(NSInteger) cmd
                                        digitAddress:(NSInteger) digAdr
                                          accessTime:(NSInteger) access
                                       andViewAccess:(NSString *) view  {
    
    __block CGFloat tactPerBlock = 0;
    
    NSMutableArray* (^returnNewArray) (NSString *, NSInteger) = ^(NSString *array, NSInteger access) {
        NSMutableArray *newArray = [NSMutableArray array];
        NSInteger delay;
        while (![array isEqualToString:@""]) {
            delay = ceilf((CGFloat) [array integerValue] * access/30);
            [newArray addObject:[NSNumber numberWithInteger:delay]];
            tactPerBlock += delay;
            if ([array length] != 1) {
                array = [array substringFromIndex:2];
            } else {
                array = [array substringFromIndex:1];
            }
        }
        tactPerBlock /= [newArray count];
        return newArray;
    };
    
    NSInteger (^totalTacts) (NSArray *, NSInteger) = ^(NSArray *array, NSInteger numOfBlocks) {
        NSInteger sum = 0;
        for (int i = 0; i < numOfBlocks; i++) {
            sum += [[array objectAtIndex:(i % [array count])] integerValue];
            NSLog(@"%ld", sum);
        }
        return sum;
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGFloat scale = 0.f;
    CGFloat frameEnd = 0.f;
    NSInteger numberOfBlocks = 0;
    NSArray *accessArray = [NSArray arrayWithArray:returnNewArray(view, access)];
    dictionary[@"Bit Word"] = [NSString returnBitWordFrom:bitWord];
    dictionary[@"Command"] = [NSString returnCommandFrom:cmd];
    NSLog(@"%.1f", tactPerBlock);
    CGFloat tactCount;
    if (isCells) {
        scale = (CGFloat)960/(tactPerBlock*param + 4);
        numberOfBlocks = param;
    } else {
        tactCount = ceilf((CGFloat)param * 1000/30);
        scale = (CGFloat)960/tactCount;
        numberOfBlocks = tactCount/tactPerBlock;
    }
    frameEnd = (CGFloat) (totalTacts(accessArray, numberOfBlocks) + 1) * scale;
    dictionary[@"Frame End"] = [NSNumber numberWithFloat:frameEnd];
    dictionary[@"Num of Blocks"] = [NSNumber numberWithInteger:numberOfBlocks];
    dictionary[@"Scale"] = [NSNumber numberWithFloat:scale];
    dictionary[@"Access"] = accessArray;
    dictionary[@"Start Tact"] = @2;
    return dictionary;
}

@end
