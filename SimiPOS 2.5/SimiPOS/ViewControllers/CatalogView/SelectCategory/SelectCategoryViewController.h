//
//  SelectCategoryViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVPullToRefresh.h"
#import "ProductViewController.h"
#import "CategoryCollection.h"

@interface SelectCategoryViewController : UITableViewController <UIPopoverControllerDelegate>

@property (strong, nonatomic) ProductViewController *productController;
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) CategoryCollection *categories;

- (void) parseData:(NSDictionary*) respone;

- (CGSize)reloadContentSize;

@end
