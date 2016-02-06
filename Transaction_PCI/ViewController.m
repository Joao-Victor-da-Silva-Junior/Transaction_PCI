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
    self.transactionView.mainDictionary = [Model returnDictionaryUsingCells:YES
                                                                 parameters:4
                                                                    bitWord:32
                                                                    command:3
                                                               digitAddress:1
                                                                 accessTime:30
                                                              andViewAccess:@"1-1-2-4"];
    
    self.transactionView.firstLaunch = YES;
    self.modeTextRepresentation.stringValue = @"Число слов:";
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)reDraw:(id)sender {
    
    self.transactionView.mainDictionary = [Model returnDictionaryUsingCells:_switchModeControl.selectedSegment ? YES : NO
                                                                 parameters:_lettersNumber.floatValue
                                                                    bitWord:_bitWord.integerValue
                                                                    command:_chosenCommand.selectedTag
                                                               digitAddress:_addressDigitControl.selectedSegment
                                                                 accessTime:_accessTime.integerValue
                                                              andViewAccess:_viewAccessTime.stringValue];
    
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

@end
