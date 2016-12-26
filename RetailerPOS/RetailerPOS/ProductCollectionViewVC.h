//
//  ProductViewController.h
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 2/3/16.
//  Copyright (c) 2013 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "MRCategory.h"

@interface ProductCollectionViewVC : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate>

@property (strong, nonatomic) UIPopoverController *selectCategoryPopover;
@property (strong, nonatomic) UIPopoverController *productOptionsPopover;

@property (strong, nonatomic) UISearchBar *searchBar;

// Collection View
@property (strong, nonatomic) IBOutlet UILabel *pagingLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalsLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

// Custom Sale and Cart Discount
@property (strong, nonatomic) UIButton *customSale;
@property (strong, nonatomic) UIButton *cartDiscount;

- (void)didSelectCategory:(MRCategory *)category;
- (void)refreshDiscountButton;

- (IBAction)customSale:(id)sender;
- (IBAction)cartDiscount:(id)sender;

@end
