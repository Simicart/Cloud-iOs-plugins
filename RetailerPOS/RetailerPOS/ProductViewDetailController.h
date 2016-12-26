//
//  ProductViewDetailController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/6/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductViewDetailController : UIViewController
@property (strong, nonatomic) Product *product;

- (void)closeDetailPage;

// Detail Information
@property (strong, nonatomic) UIScrollView *detailView;

// Actions
- (IBAction)addProductToCart:(id)sender;

@end
