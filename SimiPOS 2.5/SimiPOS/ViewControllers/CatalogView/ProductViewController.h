//
//  ProductViewController.h
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 2/3/16.
//  Copyright (c) 2013 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "RPCategory.h"
#import "SelectCategoryButton.h"
//Gin add
#import "BarCodeViewController.h"

@class Product;
@class ProductCollection;

@interface ProductViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,UIGestureRecognizerDelegate,BarCodeViewController_Delegate,UITextFieldDelegate>

+(ProductViewController*)sharedInstance;

// View Product Detail
- (IBAction)viewProductDetail:(id)sender;

@property (nonatomic) BOOL isLoadingProduct;
- (IBAction)tryToLoadProducts;

// fix bug not update category
// lionel
@property (strong, nonatomic)SelectCategoryButton *categoryTitle;
// end

// Search and category
@property (strong, nonatomic) ProductCollection *allProducts;
@property (strong, nonatomic) ProductCollection *searchProducts;
@property (strong, nonatomic) UIPopoverController *selectCategoryPopover;
@property (strong, nonatomic) RPCategory *currentCategory;

-(IBAction)showSelectCategory:(id)sender;
-(void)didSelectCategory:(RPCategory *)category;

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *currentIndex;


// Collection View
@property (strong, nonatomic) IBOutlet UILabel *pagingLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalsLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) ProductCollection *productList;

- (void)failteToLoadProduct:(NSNotification *)note;

- (void)refreshCollectionView;
- (void)refreshPagingLabel;
- (void)loadMoreProducts;

// Popover View Controller
@property (strong, nonatomic) UIPopoverController *productOptionsPopover;

// Add product to cart
- (BOOL)addProductToCart:(Product *)product;

// Custom Sale and Cart Discount
@property (strong, nonatomic) UIButton *customSale;
@property (strong, nonatomic) UIButton *cartDiscount;

- (IBAction)customSale:(id)sender;
- (IBAction)cartDiscount:(id)sender;

- (void)refreshDiscountButton;


// process after change config
- (void)loadProductAfterConfig;

@end
