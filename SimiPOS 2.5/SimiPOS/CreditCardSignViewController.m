//
//  CreditCardSignViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Configuration.h"
#import "Utilities.h"

#import "CreditCardSignViewController.h"
#import "MSGrayButton.h"
#import "Price.h"
#import "Quote.h"
#import "Payment.h"
#import "Invoice.h"

@interface CreditCardSignViewController()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@end

@implementation CreditCardSignViewController
@synthesize signView;
@synthesize animation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1]];
    
    // Total Label
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(312, 36, 400, 48)];
    NSNumber *ccTotal = [NSNumber numberWithDouble:([[[Quote sharedQuote] getGrandTotal] doubleValue] - [Quote sharedQuote].cashIn)];
    if ([ccTotal doubleValue] < 0.0) {
        ccTotal = [NSNumber numberWithInteger:0];
    }
    totalLabel.text = [Price format:ccTotal];
    totalLabel.font = [UIFont boldSystemFontOfSize:44];
    totalLabel.textAlignment = NSTextAlignmentCenter;
    [totalLabel setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    [self.view addSubview:totalLabel];
    
    // Sign Label
    UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(312, 140, 400, 40)];
    signLabel.text = NSLocalizedString(@"Sign below", nil);
    signLabel.textColor = [UIColor lightGrayColor];
    signLabel.font = [UIFont systemFontOfSize:24];
    signLabel.textAlignment = NSTextAlignmentCenter;
    [signLabel setBackgroundColor:totalLabel.backgroundColor];
    [self.view addSubview:signLabel];
    
	// Init Sign View
    UIView *signBackground = [[UIView alloc] initWithFrame:CGRectMake(100, 120, 824, 468)];
    [signBackground setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.04]];
    self.signView = [[MSPaintView alloc] initWithFrame:signBackground.bounds];
    [self.signView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0]];
    [signBackground addSubview:self.signView];
    [self.view addSubview:signBackground];
    
    // Term and conditions
    UILabel *conditionLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 588, 824, 40)];
    conditionLabel.textAlignment = NSTextAlignmentCenter;
    conditionLabel.textColor = [UIColor lightGrayColor];
    conditionLabel.font = [UIFont systemFontOfSize:16];
    [conditionLabel setBackgroundColor:totalLabel.backgroundColor];
    [self.view addSubview:conditionLabel];
    
    Payment *payment = [Quote sharedQuote].payment;
    conditionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"I agree to pay %@ according to my card issuer agreement, for %@ card ending with %@.", nil), totalLabel.text, [payment cardType], [payment last4Digit]];
    
    // Signature Form Buttons
    UIButton *clearButton = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
    clearButton.frame = CGRectMake(100, 645, 280, 65);
    clearButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:clearButton];
    [clearButton setTitle:NSLocalizedString(@"Clear Signature", nil) forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearSignature) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [submitButton setBackgroundImage:[[UIImage imageNamed:@"btn_checkout.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[[UIImage imageNamed:@"btn_checkout_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    submitButton.frame = CGRectMake(644, 645, 280, 65);
    submitButton.titleLabel.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:submitButton];
    [submitButton setTitle:NSLocalizedString(@"Submit Signature", nil) forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitSignature) forControlEvents:UIControlEventTouchUpInside];
}

- (void)clearSignature
{
    [self.signView clear];
}

- (void)submitSignature
{
    // Submit animation
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        animation.frame = self.view.bounds;
        animation.color = [UIColor grayColor];
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    }
    [self.view addSubview:animation];
    [animation startAnimating];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(submitSignatureThread) object:nil] start];
}

- (void)submitSignatureThread
{
    // Storage signature to iPad
    // NSString *orderId = [[Quote sharedQuote].order getId];
    // UIGraphicsBeginImageContext(self.signView.bounds.size);
    UIGraphicsBeginImageContextWithOptions(self.signView.bounds.size, NO, 0.5);
    [self.signView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *signImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *signImageData = UIImagePNGRepresentation(signImage);
    // [signImageData writeToFile:[self imagePath:orderId] atomically:YES];
    
    // Submit signature to store
    id requestFailure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id requestSuccess = [[NSNotificationCenter defaultCenter] addObserverForName:@"InvoiceAddSignSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Back to Checkout Page
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    Invoice *invoice = [Invoice new];
    [invoice setValue:[[Quote sharedQuote].order objectForKey:@"invoice"] forKey:@"increment_id"];
    [invoice addSignature:signImageData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:requestFailure];
    [[NSNotificationCenter defaultCenter] removeObserver:requestSuccess];
    [animation stopAnimating];
    [animation removeFromSuperview];
}

- (NSString *)imagePath:(NSString *)orderId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *imageDirectory = [documentDirectory stringByAppendingPathComponent:[[Configuration globalConfig] objectForKey:@"username"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirectory]) {
        // Create directory
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [[imageDirectory stringByAppendingPathComponent:orderId] stringByAppendingPathExtension:@"png"];
}

@end
