//
//  ProductViewDetailController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/6/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ProductViewDetailController : UIViewController
@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) Product *productFullInfo;

- (void)closeDetailPage;

// Detail Information
@property (strong, nonatomic) UIScrollView *detailView;

// Actions
- (IBAction)addProductToCart:(id)sender;

@end
