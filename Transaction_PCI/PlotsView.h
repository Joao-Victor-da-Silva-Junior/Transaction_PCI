//
//  PlotsView.h
//  Курсач ЭВМ
//
//  Created by Виктор on 25.12.15.
//  Copyright © 2015 Виктор. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PlotsView : NSView

@property (strong, nonatomic) NSMutableArray *arrayOfEightBits;
@property (strong, nonatomic) NSMutableArray *arrayOfSixteenBits;
@property (strong, nonatomic) NSMutableArray *arrayOfThirtyTwoBits;

@end
