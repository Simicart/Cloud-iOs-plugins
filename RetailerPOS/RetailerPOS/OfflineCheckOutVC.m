//
//  OfflineCheckOutVC.m
//  RetailerPOS
//
//  Created by mac on 4/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "OfflineCheckOutVC.h"

#define COLOR_BORDER_BUTTON [UIColor barBackgroundColor]

@interface OfflineCheckOutVC ()

@property (weak, nonatomic) IBOutlet UILabel *totalSaleLabel;

@property (weak, nonatomic) IBOutlet UIButton *cashInButton;
@property (weak, nonatomic) IBOutlet UIButton *creditCardButton;
@property (weak, nonatomic) IBOutlet UIButton *cashOnDeliveryButton;
@property (weak, nonatomic) IBOutlet UIButton *splitPaymentsButton;

@property (weak, nonatomic) IBOutlet UIButton *addPaymentButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;


@property (weak, nonatomic) IBOutlet UIView *groupPaymentView;

@end

@implementation OfflineCheckOutVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDefault];
}

-(void)initDefault{
    
    UIView * seperateLine =[[UIView alloc] init];
    seperateLine.frame =CGRectMake(0, 0, 1, WINDOW_HEIGHT + 100);
    seperateLine.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:seperateLine];
    
    self.cashInButton.backgroundColor =COLOR_BORDER_BUTTON;
    self.creditCardButton.backgroundColor =COLOR_BORDER_BUTTON;
    self.cashOnDeliveryButton.backgroundColor =COLOR_BORDER_BUTTON;
    self.splitPaymentsButton.backgroundColor =COLOR_BORDER_BUTTON;
    self.addPaymentButton.backgroundColor =COLOR_BORDER_BUTTON;
    self.payButton.backgroundColor =COLOR_BORDER_BUTTON;
    
    
    self.cashInButton.layer.cornerRadius = 5.0;
    self.creditCardButton.layer.cornerRadius = 5.0;
    self.cashOnDeliveryButton.layer.cornerRadius = 5.0;
    self.splitPaymentsButton.layer.cornerRadius = 5.0;
    self.addPaymentButton.layer.cornerRadius = 5.0;
    self.payButton.layer.cornerRadius = 5.0;
  
    
    self.groupPaymentView.layer.cornerRadius = 10.0;
    self.groupPaymentView.layer.borderWidth = 1.0;
    self.groupPaymentView.layer.borderColor =[UIColor barBackgroundColor].CGColor;
    self.groupPaymentView.backgroundColor =[UIColor whiteColor];
}

@end
