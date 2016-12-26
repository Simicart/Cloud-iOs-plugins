//
//  SelectCategoryViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/23/2016.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVPullToRefresh.h"
#import "ProductCollectionViewVC.h"
#import "MRCategory.h"

@interface SelectCategoryViewController : UITableViewController <UIPopoverControllerDelegate>

@property (strong, nonatomic) ProductCollectionViewVC * productCollectionViewVC;
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) NSArray *categories;

- (CGSize)reloadContentSize;

@end
