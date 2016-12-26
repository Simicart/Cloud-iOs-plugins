//
//  EditItemViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/5/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MSBlueButton.h"
#import "MSGrayButton.h"
#import "MSTextField.h"
#import "MSNumberPad.h"
#import "UIImageView+WebCache.h"
#import "QuoteItem.h"

#import "ItemDiscountForm.h"
#import "EditItemOptions.h"

@interface EditItemViewController : UITableViewController <UINavigationControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, MSNumberPadDelegate>
@property (strong, nonatomic) UIPopoverController *cartItemPopover;

@property (strong, nonatomic) QuoteItem *item;
@property (strong, nonatomic) NSIndexPath *itemIndexPath;
@property (strong, nonatomic) UITableView *itemTableView;

- (CGSize)reloadContentSize;
- (void)updateQuoteItem:(NSDictionary *)options;
- (void)threadUpdateQuoteItem:(NSDictionary *)options;

// Customize cell for edit item
- (UITableViewCell *)itemImageCell;
- (UITableViewCell *)qtyEditItemCell;
- (UITableViewCell *)discountItemCell;
- (UITableViewCell *)optionsItemCell;
- (UITableViewCell *)updateQtyItemCell;

- (IBAction)changeItemQty:(id)sender;
- (IBAction)decreaseItemQty:(id)sender;
- (IBAction)increaseItemQty:(id)sender;
- (void)updateItemQty:(CGFloat)qty;
- (void)threadUpdateItemQty:(id)qty;

// Sub viewcontroller
@property (nonatomic) BOOL isShowedQtyInput;

@property (strong, nonatomic) ItemDiscountForm *discountForm;
@property (nonatomic) BOOL isShowedDiscountForm;

@property (strong, nonatomic) EditItemOptions *itemOptions;
@property (nonatomic) BOOL isShowedItemOptions;

- (void)rePresentPopover:(CGSize)popoverContentSize;

@end
