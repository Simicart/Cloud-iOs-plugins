//
//  QuoteNoteViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 3/17/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuoteNoteViewController : UIViewController <UIPopoverControllerDelegate, UITextViewDelegate>
@property (strong, nonatomic) UIPopoverController *notePopover;

- (CGSize)reloadContentSize;

@property (strong, nonatomic) UIButton *saveButton;
- (void)saveOrderComment;

@property (strong, nonatomic) UITextView *textInput;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)saveOrderCommentThread;
@end
