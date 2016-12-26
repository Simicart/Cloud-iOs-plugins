//
//  OrderEmailViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OrderEmailViewController.h"

#import "MSTextField.h"
#import "MSValidator.h"
#import "Utilities.h"

@interface OrderEmailViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@end

@implementation OrderEmailViewController
@synthesize order = _order, emailAddress;
@synthesize animation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
	// Navigation button
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelSendEmail)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", nil) style:UIBarButtonItemStyleDone target:self action:@selector(sendEmail)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    self.title = NSLocalizedString(@"Send Email", nil);
    
    // Email address
    emailAddress = [[MSTextField alloc] initWithFrame:CGRectMake(10, 20, 416, 54)];
    emailAddress.placeholder = NSLocalizedString(@"Email Address", nil);
    emailAddress.textPadding = UIEdgeInsetsMake(15, 10, 15, 10);
    emailAddress.font = [UIFont systemFontOfSize:20];
    emailAddress.backgroundColor = [UIColor whiteColor];
    emailAddress.keyboardType = UIKeyboardTypeEmailAddress;
    emailAddress.returnKeyType = UIReturnKeySend;
    emailAddress.enablesReturnKeyAutomatically = YES;
    [emailAddress.layer setBorderWidth:1.0];
    [emailAddress.layer setBorderColor:[UIColor colorWithWhite:0.88 alpha:1].CGColor];
    [self.view addSubview:emailAddress];
    emailAddress.clearButtonMode = UITextFieldViewModeWhileEditing;
    [emailAddress addTarget:self action:@selector(changeEmailAddress) forControlEvents:UIControlEventEditingChanged];
    [emailAddress addTarget:self action:@selector(doneEditEmailAddress) forControlEvents:UIControlEventEditingDidEndOnExit];
    if ([self.order objectForKey:@"customer_email"]) {
        emailAddress.text = [self.order objectForKey:@"customer_email"];
    }
    [emailAddress becomeFirstResponder];
    [self changeEmailAddress];
}

#pragma mark - text field delegate
- (void)changeEmailAddress
{
    [self.navigationItem.rightBarButtonItem setEnabled:[MSValidator validateEmail:emailAddress.text]];
}

- (void)doneEditEmailAddress
{
    if ([MSValidator validateEmail:emailAddress.text]) {
        [self sendEmail];
    }
}

#pragma mark - form actions
- (void)cancelSendEmail
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendEmail
{
    [emailAddress resignFirstResponder];
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        animation.frame = self.view.bounds;
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [[[NSThread alloc] initWithTarget:self selector:@selector(sendEmailThread) object:nil] start];
}

- (void)sendEmailThread
{
    id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"OrderSendEmailSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self dismissViewControllerAnimated:YES completion:^{
            [Utilities alert:NSLocalizedString(@"Success", nil) withMessage:NSLocalizedString(@"The order email has been sent.", nil)];
        }];
    }];
    [self.order sendEmail:emailAddress.text];
    
    [animation stopAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
}

@end
