//
//  CartInformation.h
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/10/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "Quote.h"

//#import "CustomerListViewController.h"

#import "EditItemViewController.h"

@interface CartInformation : UITableViewController

@property (nonatomic) NSInteger currentPage;

@property (strong, nonatomic) Quote *quote;

-(void)startAnimation;
-(void)animationThread;
-(void)stopAnimation;
-(void)refreshShoppingCart;

-(UITableViewCell *)customerViewCell:(NSIndexPath *)indexPath;
-(UITableViewCell *)productViewCell:(NSIndexPath *)indexPath;
-(UITableViewCell *)totalsViewCell:(NSIndexPath *)indexPath;

// Edit customer/ item popover
@property (strong, nonatomic) UIPopoverController *customersPopover;
@property (strong, nonatomic) UIPopoverController *cartItemPopover;

@end
