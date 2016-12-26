//
//  QuoteNoteViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 3/17/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "QuoteNoteViewController.h"
#import "MSFramework.h"
#import "Quote.h"

//Ravi
#import "CommentModel.h"
//End

@interface QuoteNoteViewController ()
@end

@implementation QuoteNoteViewController
@synthesize notePopover, saveButton;
@synthesize textInput, animation;
//Ravi
@synthesize order,fromEditOrder;
//ENd

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.frame = CGRectMake(0, 0, 320, 240);
    
    // Label & Button
    UILabel *cmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 160, 30)];
    cmtLabel.font = [UIFont boldSystemFontOfSize:18];
    cmtLabel.text = NSLocalizedString(@"Order Comment", nil);
    [self.view addSubview:cmtLabel];
    
    saveButton = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    [saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
    saveButton.frame = CGRectMake(230, 10, 80, 39);
    saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:saveButton];
    [saveButton addTarget:self action:@selector(saveOrderComment) forControlEvents:UIControlEventTouchUpInside];
    
    // Text input
    textInput = [[UITextView alloc] initWithFrame:CGRectMake(10, 54, 300, 175)];
    textInput.font = [UIFont systemFontOfSize:16];
    textInput.delegate = self;
    textInput.layer.borderWidth = 1.0;
    textInput.layer.borderColor = [UIColor lightBorderColor].CGColor;
    [self.view addSubview:textInput];
    textInput.text = [[Quote sharedQuote] objectForKey:@"order_comment"];
    [textInput becomeFirstResponder];
}

- (CGSize)reloadContentSize
{
    if (textInput) {
        textInput.text = [[Quote sharedQuote] objectForKey:@"order_comment"];
        [textInput becomeFirstResponder];
    }
    //self.contentSizeForViewInPopover = CGSizeMake(320, 240);
    //return self.contentSizeForViewInPopover;
    
    [self setPreferredContentSize:CGSizeMake(320, 240)];
    
    return self.preferredContentSize;
}

- (void)textViewDidChange:(UITextView *)textView
{
    //Ravi
    if (fromEditOrder) {
        return;
    }
    //End
    
    if (textView.text) {
        [[Quote sharedQuote] setValue:textView.text forKey:@"order_comment"];
    } else {
        [[Quote sharedQuote] removeObjectForKey:@"order_comment"];
    }
}

- (void)saveOrderComment
{
    
    //Ravi
    if (fromEditOrder) {
        if (animation == nil) {
            animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            animation.frame = textInput.frame;
            [self.view addSubview:animation];
        }
        [animation startAnimating];
        [saveButton setEnabled:NO];
        [[[NSThread alloc] initWithTarget:self selector:@selector(saveOrderCommentThread) object:nil] start];
        
        return;
    }
    //End
    
    if ([Quote sharedQuote].order == nil
        || [MSValidator isEmptyString:[[Quote sharedQuote] objectForKey:@"order_comment"]]
    ) {
        // Dismiss popover
        [notePopover dismissPopoverAnimated:YES];
        return;
    }
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = textInput.frame;
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [saveButton setEnabled:NO];
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveOrderCommentThread) object:nil] start];
}

- (void)saveOrderCommentThread
{
    
    //Ravi
    if (fromEditOrder) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddCommentOrder:) name:@"DidAddCommentOrder" object:nil];
        CommentModel *commentModel = [CommentModel new];
        [commentModel addCommentOrder:[self.order valueForKey:@"increment_id"] withComment:textInput.text];
        
        return;
    }
    //End
    
    //Ravi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddCommentOrder:) name:@"DidAddCommentOrder" object:nil];
    CommentModel *commentModel = [CommentModel new];
    [commentModel addCommentOrder:[[Quote sharedQuote].order valueForKey:@"id"] withComment:[[Quote sharedQuote] objectForKey:@"order_comment"]];
    return;
    //End
    
    
    id requestFailt = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id requestSuccess = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderCommentSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [[Quote sharedQuote] removeObjectForKey:@"order_comment"];
        [notePopover performSelectorOnMainThread:@selector(dismissPopoverAnimated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
    }];
    
    [[Quote sharedQuote].order comment:[[Quote sharedQuote] objectForKey:@"order_comment"]];
    
    [animation stopAnimating];
    [saveButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:requestFailt];
    [[NSNotificationCenter defaultCenter] removeObserver:requestSuccess];
}

//Ravi
- (void)didAddCommentOrder: (NSNotification*)noti{
    
    //Ravi
    if (fromEditOrder) {
        [animation stopAnimating];
        [saveButton setEnabled:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
        RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
        if([respone.status isEqualToString:@"SUCCESS"]){
            DLog(@"didAddCommentOrder - %@",respone.data);
            [notePopover performSelectorOnMainThread:@selector(dismissPopoverAnimated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCommentSuccessInOrderEditViewController" object:nil];
        }else{
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[respone.message objectAtIndex:0]];
        }
        return;
    }
    //End
    
    
    
    [animation stopAnimating];
    [saveButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didAddCommentOrder - %@",respone.data);
        [[Quote sharedQuote] removeObjectForKey:@"order_comment"];
        [notePopover performSelectorOnMainThread:@selector(dismissPopoverAnimated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCommentSuccess" object:nil];
    }else{
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[respone.message objectAtIndex:0]];
    }
}
//End

@end
