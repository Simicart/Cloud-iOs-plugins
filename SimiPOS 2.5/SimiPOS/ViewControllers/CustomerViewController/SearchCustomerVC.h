//
//  SearchCustomerVC.h
//  SimiPOS
//
//  Created by mac on 3/3/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchCustomerVC : UIViewController<UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *listPopover;
@property (strong, nonatomic) UITableView *itemTableView;

@end
