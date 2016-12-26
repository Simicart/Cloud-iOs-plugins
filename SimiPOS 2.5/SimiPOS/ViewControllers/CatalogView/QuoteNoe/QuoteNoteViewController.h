//
//  QuoteNoteViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 3/17/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
//Ravi
#import "Order.h"
//End

@interface QuoteNoteViewController : UIViewController <UIPopoverControllerDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIPopoverController *notePopover;

- (CGSize)reloadContentSize;

@property (strong, nonatomic) UIButton *saveButton;
- (void)saveOrderComment;

@property (strong, nonatomic) UITextView *textInput;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)saveOrderCommentThread;

//Ravi
@property (strong, nonatomic) Order *order;
@property (nonatomic) BOOL fromEditOrder;
//End
@end
