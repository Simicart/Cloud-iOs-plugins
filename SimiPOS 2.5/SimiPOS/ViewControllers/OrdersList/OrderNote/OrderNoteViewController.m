//
//  OrderNoteViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 4/27/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "OrderNoteViewController.h"
#import "MSFramework.h"

//Ravi
#import "CommentModel.h"
//End

@implementation OrderNoteViewController
@synthesize order, editViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textInput.text = nil;
}

- (CGSize)reloadContentSize
{
    if (self.textInput) {
        self.textInput.text = nil;
        [self.textInput becomeFirstResponder];
    }
    //self.contentSizeForViewInPopover = CGSizeMake(320, 240);
    //return self.contentSizeForViewInPopover;
    
    self.preferredContentSize = CGSizeMake(320, 240);
    return self.preferredContentSize;
}

- (void)textViewDidChange:(UITextView *)textView
{
    // Don't save any
}

- (void)saveOrderComment
{
    if ([MSValidator isEmptyString:self.textInput.text]) {
        [self.notePopover dismissPopoverAnimated:YES];
        return;
    }
    if (self.animation == nil) {
        self.animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.animation.frame = self.textInput.frame;
        [self.view addSubview:self.animation];
    }
    [self.animation startAnimating];
    [self.saveButton setEnabled:NO];
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveOrderCommentThread) object:nil] start];
}

- (void)saveOrderCommentThread
{
    //Ravi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddCommentOrder:) name:@"DidAddCommentOrder" object:nil];
    CommentModel *commentModel = [CommentModel new];
    [commentModel addCommentOrder:[self.order valueForKey:@"id"] withComment:self.textInput.text];
    
    return;
    //End
    
    
    
    
    id requestFailt = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id requestSuccess = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderCommentSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.notePopover performSelectorOnMainThread:@selector(dismissPopoverAnimated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        // Reload order data
        [self.editViewController loadOrder];
    }];
    
    [self.order comment:self.textInput.text];
    
    [self.animation stopAnimating];
    [self.saveButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:requestFailt];
    [[NSNotificationCenter defaultCenter] removeObserver:requestSuccess];
}

//Ravi
- (void)didAddCommentOrder: (NSNotification*)noti{
    [self.animation stopAnimating];
    [self.saveButton setEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didAddCommentOrder - %@",respone.data);
        [self.notePopover performSelectorOnMainThread:@selector(dismissPopoverAnimated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
        [self.editViewController loadOrder];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderCommentSuccess" object:nil];
    }else{

        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[respone.message objectAtIndex:0]];
    }
}
//End

@end
