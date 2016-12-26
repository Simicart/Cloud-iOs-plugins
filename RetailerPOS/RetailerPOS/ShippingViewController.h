//
//  ShippingViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/19/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Shipping.h"
//#import "ShippingCollection.h"

@interface ShippingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UIControl *headerView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIButton *headerButton;

- (IBAction)toggleShippingForm;
- (IBAction)editShippingAddress;

@property (nonatomic) BOOL isShowContent;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UITableView *shippingMethods;

- (CGSize)reloadContentSize;
@property (strong, nonatomic) NSArray *collection;

@end
