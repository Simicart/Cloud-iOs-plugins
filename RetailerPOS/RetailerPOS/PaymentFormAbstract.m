//
//  PaymentFormAbstract.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/28/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "PaymentFormAbstract.h"
#import "MSBackButton.h"
#import "Quote.h"

@implementation PaymentFormAbstract
@synthesize checkout;
@synthesize method;
@synthesize form;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Initial payment form, background
    self.view.backgroundColor = [UIColor whiteColor];
    self.form = [MSForm new];
    CGRect formFrame = self.navigationController.view.bounds;
    self.form.frame = formFrame;
    [self.view addSubview:form];
    [self.form loadFormData:[Quote sharedQuote].payment];
    
    // Add Payment Form Toolbar Here
    [self.navigationController setNavigationBarHidden:NO];
    
    MSBackButton *backBtn = [MSBackButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn addTarget:self action:@selector(backToPaymentMethods) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.title = [self.method objectForKey:@"title"];
}

- (void)backToPaymentMethods
{
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updatePaymentData
{
    Payment *payment = [Quote sharedQuote].payment;
    [payment removeAllObjects];
    [payment addEntriesFromDictionary:self.form.formData];
    [payment setValue:[self.method getId] forKey:@"method"];
}

@end
