
#import "Model.h"
#import "NSString+CommandEqual.h"

@implementation Model

+ (NSMutableDictionary *) returnDictionaryUsingCells:(BOOL)         isCells
                                         parameters:(CGFloat)       param
                                            bitWord:(NSInteger)     bitWord
                                             command:(NSInteger)    cmd
                                        digitAddress:(NSInteger)    digAdr
                                          accessTime:(NSInteger)    access
                                       andViewAccess:(NSString *)   view  {
    
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
        }
        return sum;
    };
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    CGFloat scale = 0.f;
    CGFloat frameEnd = 0.f;
    NSInteger numberOfBlocks = 0;
    NSInteger numberOfAD = 0;
    NSInteger numberOfCbe = 0;
    NSInteger startTact = 0;
    CGFloat blockHeight = 0.f;
    NSArray *accessArray = [NSArray arrayWithArray:returnNewArray(view, access)];
    CGFloat tactCount;
    
    if (isCells) {
        scale = (CGFloat)960/(tactPerBlock*param + 4);
        numberOfBlocks = param;
    } else {
        tactCount = ceilf((CGFloat)param * 1000/30);
        scale = (CGFloat)960/tactCount;
        numberOfBlocks = tactCount/tactPerBlock;
    }
    scale = (scale > 60.f) ? 60 : scale;
    if (bitWord == 64 && digAdr == 0) {
        numberOfAD = 2;
        startTact = 3;
        blockHeight = scale * 2/5;
    } else {
        numberOfAD = 1;
        startTact = 2;
        blockHeight = scale * 2/3;
    }
    
    if (digAdr == 1) {
        numberOfAD = 2;
        numberOfCbe = 2;
        startTact = 2;
        blockHeight = scale * 2/6;
    }
    frameEnd = (CGFloat) (totalTacts(accessArray, numberOfBlocks) + (startTact - 1)) * scale;
    
    dictionary[@"Bit Word"] = [NSString returnBitWordFrom:bitWord];
    dictionary[@"Command"] = [NSString returnCommandFrom:cmd];
    dictionary[@"Frame End"] = [NSNumber numberWithFloat:frameEnd];
    dictionary[@"Num of Blocks"] = @(numberOfBlocks);
    dictionary[@"Scale"] = [NSNumber numberWithFloat:scale];
    dictionary[@"Access"] = accessArray;
    dictionary[@"Start Tact"] = @(startTact);
    dictionary[@"Number of AD"] = @(numberOfAD);
    dictionary[@"Number of CBE"] = @(numberOfCbe);
    dictionary[@"Block Height"] = [NSNumber numberWithFloat:blockHeight];
    return dictionary;
}

@end
