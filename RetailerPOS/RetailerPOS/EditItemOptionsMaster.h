//
//  EditItemOptionsMaster.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/7/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ProductOptionsMaster.h"
#import "MSFramework.h"
#import "EditItemViewController.h"
#import "EditItemOptions.h"

@interface EditItemOptionsMaster : ProductOptionsMaster

@property (strong, nonatomic) UIButton *backButtonView;
- (UIButton *)backButton;
- (IBAction)backToEditItem;

@end
