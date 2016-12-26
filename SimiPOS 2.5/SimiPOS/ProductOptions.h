//
//  ProductOptions.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Product;
@class ProductOptionsMaster;
@class ProductOptionsDetail;

@interface ProductOptions : UIViewController <UIPopoverControllerDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UIPopoverController *popoverController;

@property (strong, nonatomic) ProductOptionsMaster *masterOptions;
@property (strong, nonatomic) ProductOptionsDetail *detailOptions;


@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) NSMutableDictionary *productOptions;

// Estimate content size for Popover
- (CGSize)reloadContentSize;

// Validate options and add product to cart
- (BOOL)validateOptions;
- (BOOL)addProductToCart;
- (void)threadAddProductToCart;

@end
