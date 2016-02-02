//
//  NSString+CommandEqual.h
//  Transaction_PCI
//
//  Created by Виктор on 02.02.16.
//  Copyright © 2016 Виктор. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CommandEqual)

+ (NSString *) returnBitWordFrom:(NSInteger) p;

+ (NSString *) returnCommandFrom:(NSInteger) p;

+ (NSString *) returnDigitAddressFrom:(NSInteger) p;

@end
