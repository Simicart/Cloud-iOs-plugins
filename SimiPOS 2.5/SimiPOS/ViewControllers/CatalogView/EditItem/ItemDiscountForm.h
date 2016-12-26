//
//  ItemDiscountForm.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/11/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuoteItem.h"
#import "MSFramework.h"

@interface ItemDiscountForm : UITableViewController <UITextFieldDelegate, MSNumberPadDelegate>

@property (weak, nonatomic) QuoteItem *item;
@property (nonatomic) BOOL isShowedNumberPad;

@property (nonatomic) BOOL isFirtTimeDisplay;
@property (nonatomic) NSUInteger segmentIndex;
@property (nonatomic) long double customPrice;

- (IBAction)toggleDiscountType:(id)sender;
- (CGSize)reloadContentSize;

@property (strong, nonatomic) MSBlueButton *doneButton;
@property (strong, nonatomic) UIButton *backButton;
- (IBAction)doneEdit:(id)sender;
- (IBAction)backEdit:(id)sender;

-(void)updatePriceThread:(id)price;

@end
