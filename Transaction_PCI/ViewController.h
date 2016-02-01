//
//  ViewController.h
//  Курсач ЭВМ
//
//  Created by Виктор on 18.12.15.
//  Copyright © 2015 Виктор. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TransactionView, PlotsView, SecondPlotsView;
@interface ViewController : NSViewController

@property (weak, nonatomic) IBOutlet TransactionView *transactionView;
@property (weak, nonatomic) IBOutlet PlotsView *plotView;
@property (weak, nonatomic) IBOutlet SecondPlotsView *secondPlotViev;

@property (weak, nonatomic) IBOutlet NSTextField *bitWord;
@property (weak, nonatomic) IBOutlet NSTextField *accessTime;
@property (weak, nonatomic) IBOutlet NSTextField *viewAccessTime;
@property (weak, nonatomic) IBOutlet NSTextField *lettersNumber;
@property (weak, nonatomic) IBOutlet NSTextField *modeTextRepresentation;

@property (weak, nonatomic) IBOutlet NSSegmentedControl *switchModeControl;
@property (weak, nonatomic) IBOutlet NSSegmentedControl *addressDigitControl;
@property (weak, nonatomic) IBOutlet NSPopUpButton *chosenCommand;


- (IBAction)reDraw:(id)sender;

@end

