//
//  ViewController.m
//  Курсач ЭВМ
//
//  Created by Виктор on 18.12.15.
//  Copyright © 2015 Виктор. All rights reserved.
//

#import "ViewController.h"
#import "TransactionView.h"
#import "PlotsView.h"
#import "Model.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Model *myModel = [[Model alloc] init];
    self.transactionView.scale = [myModel.mainDictionary[@"Scale"] floatValue];
    self.transactionView.frameEnd = [myModel.mainDictionary[@"Frame End"] floatValue];
    self.transactionView.firstLaunch = YES;
    self.transactionView.drawModeIs = cells;
    self.modeTextRepresentation.stringValue = @"Число слов:";
    self.transactionView.letters = 6;
    self.transactionView.bitWord = @"1100";
    self.transactionView.command = @"0110";
    self.transactionView.digitAddress = @"32";
    [self makeFullArraysForPlots];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

}

- (IBAction)reDraw:(id)sender {
    
    [self setAllTransactionCharacteristics];
    
    if (![_accessTime.stringValue isEqualToString:@""] &&
        ![_viewAccessTime.stringValue isEqualToString:@""] &&
        
        ![_bitWord.stringValue isEqualToString:@""]) {
        [self.transactionView setNeedsDisplay:YES];
    } else {
        if ([_accessTime.stringValue isEqualToString:@""]) {
            _accessTime.placeholderString = @"!!!";
        }
        if ([_viewAccessTime.stringValue isEqualToString:@""]) {
            _viewAccessTime.placeholderString = @"!!!";
        }
        if ([_bitWord.stringValue isEqualToString:@""]) {
            _bitWord.placeholderString = @"!!!";
        }
    }
}

#pragma mark - Set

- (void) setAllTransactionCharacteristics {
    self.transactionView.firstLaunch = NO;
    [self createAccessArray];
    self.transactionView.bitWord = [self createBitWord];
    self.transactionView.command = [self returnCommand];
    
    if (_switchModeControl.selectedSegment == 0) {
        self.transactionView.drawModeIs = timeInterval;
        _modeTextRepresentation.stringValue = @"Интервал, ns:";
        self.transactionView.timeInterval = [_lettersNumber.stringValue floatValue];
        NSInteger totalTactsInDelay;
        for (id delay in self.transactionView.arrayOfDelays) {
            totalTactsInDelay += ceilf((CGFloat)[delay integerValue]/30);
        }

    } else {
        self.transactionView.drawModeIs = cells;
        _modeTextRepresentation.stringValue = @"Число слов:";
        self.transactionView.letters = [_lettersNumber.stringValue floatValue];
    }
    
    self.transactionView.digitAddress = _addressDigitControl.selectedSegment ? @"64" : @"32";
}

#pragma mark - Other

- (void) createAccessArray {
    NSMutableArray *buferArray = [NSMutableArray array];
    NSString *buferString = [NSString stringWithFormat:@"%@", _viewAccessTime.stringValue];
    while (![buferString isEqualToString:@""]) {
        NSInteger delay = [buferString integerValue];
        if ([buferString length] != 1) {
            buferString = [NSString stringWithFormat:@"%@", [buferString substringFromIndex:2]];
        } else {
            buferString = [NSString stringWithFormat:@"%@", [buferString substringFromIndex:1]];
        }
        [buferArray addObject:[NSNumber numberWithInteger:delay * [_accessTime.stringValue integerValue]]];
    }
    self.transactionView.arrayOfDelays = [NSArray arrayWithArray:buferArray];
}

- (NSString *) createBitWord {
    switch ([_bitWord.stringValue integerValue]) {
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

- (NSString *) returnCommand {
    switch (_chosenCommand.selectedTag) {
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

- (void) makeFullArraysForPlots {
    self.plotView.arrayOfEightBits = [NSMutableArray array];
    self.plotView.arrayOfSixteenBits = [NSMutableArray array];
    self.plotView.arrayOfThirtyTwoBits = [NSMutableArray array];
    NSInteger step = 0;
    CGFloat value = 1;
    CGFloat lettersInNano = 30 * 32 * value/4;
    
    for (int i = 1; i < 12; i++) {
        lettersInNano = value/i;
        [self.plotView.arrayOfEightBits addObject:[NSValue valueWithPoint:NSMakePoint(step, lettersInNano)]];
        [self.plotView.arrayOfSixteenBits addObject:[NSValue valueWithPoint:NSMakePoint(step, lettersInNano)]];
        [self.plotView.arrayOfThirtyTwoBits addObject:[NSValue valueWithPoint:NSMakePoint(step, lettersInNano)]];
        step += self.plotView.bounds.size.width/10;
    }
}

@end
