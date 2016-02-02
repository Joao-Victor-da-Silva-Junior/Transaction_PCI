//
//  NSString+CommandEqual.m
//  Transaction_PCI
//
//  Created by Виктор on 02.02.16.
//  Copyright © 2016 Виктор. All rights reserved.
//

#import "NSString+CommandEqual.h"

@implementation NSString (CommandEqual)

+ (NSString *) returnBitWordFrom:(NSInteger) p {
    switch (p) {
        case 8:
            return @"1110";
            break;
        case 16:
            return @"1100";
            break;
        case 32:
            return @"1000";
            break;
        case 64:
            return @"0000";
        default:
            return @"false";
            break;
    }
}

+ (NSString *) returnCommandFrom:(NSInteger) p {
    switch (p) {
        case 0:
            return @"0110";
            break;
        case 1:
            return @"0111";
            break;
        case 2:
            return @"0010";
            break;
        case 3:
            return @"0011";
            break;
        default:
            return @"false";
            break;
    }
}

+ (NSString *) returnDigitAddressFrom:(NSInteger) p {
    switch (p) {
        case 0:
            return @"32";
            break;
        case 1:
            return @"64";
        default:
            return @"false";
            break;
    }
}


@end
