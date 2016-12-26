//
//  ProductViewController.m
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 2/3/16.
//  Copyright (c) 2013 Marcus Nguyen. All rights reserved.
//

#import "ProductCollectionViewVC.h"
#import "ShowMenuButton.h"
#import "SearchButton.h"
#import "SelectCategoryButton.h"
#import "MSFramework.h"

// Models
#import "Product.h"
#import "Quote.h"

// Sub View
#import "SelectCategoryViewController.h"
#import "ProductOptions.h"
#import "ProductItem.h"
#import "CustomSaleViewController.h"
#import "CustomDiscountViewController.h"
#import "ProductViewDetailController.h"

#import "MRProduct.h"
#import "Price.h"


@interface ProductCollectionViewVC()

@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UIView *bakNavigation;

@end

@implementation ProductCollectionViewVC
{
    SelectCategoryViewController *selectCategoryList;
    Permission * permission;
    NSArray * listProducts;
    SelectCategoryButton *categoryTitle;
}


@synthesize selectCategoryPopover;
@synthesize searchBar = _searchBar;

@synthesize pagingLabel = _pagingLabel;
@synthesize collectionView = _collectionView;
@synthesize productOptionsPopover;
@synthesize customSale, cartDiscount;
@synthesize bakNavigation;

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadDatabase];
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor backgroundColor];
    self.collectionView.backgroundColor = [UIColor backgroundColor];
    
    [self createAnimation];
    
    [self createMenuBar];
    
    // Double Taps => Show Product Detail
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewProductDetail:)];
    [self.collectionView addGestureRecognizer:longPress];
 
    [self createMenuBottomBar];
    
    [self initDefault];
    
}

#pragma mark - load database
-(void)loadDatabase{
    listProducts  =[MRProduct findAll];
}

#pragma mark - init default
-(void)initDefault{
    [self.cartDiscount setEnabled:NO];
    
    NSString *ProductViewIdentifier = @"ProductViewIdentifier";
    NSString *EmptyCellIdentifier = @"EmptyCellIdentifier";
    
    UINib *nib = [UINib nibWithNibName:@"ProductItem" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:ProductViewIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:EmptyCellIdentifier];
}

#pragma mark - Create Menu bar
-(void)createMenuBar{
    // Add Show Menu Button
    UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithCustomView:[[ShowMenuButton alloc] initMenuButton]];
    
    categoryTitle = [[SelectCategoryButton alloc] initCategoryButton];
    [categoryTitle addTarget:self action:@selector(showSelectCategory:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectBtn = [[UIBarButtonItem alloc] initWithCustomView:categoryTitle];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Search Products", nil);
    self.searchBar.tintColor =  [UIColor whiteColor];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.backgroundColor =[UIColor barBackgroundColor];
    self.searchBar.backgroundImage =[UIImage imageWithColor:[UIColor barBackgroundColor]];
    
    UIView * groupSearbar =[[UIView alloc] initWithFrame:CGRectMake(5, 0, 400, 44)];
    [groupSearbar addSubview:self.searchBar];
    
    UIBarButtonItem *searchBarBtn =[[UIBarButtonItem alloc] initWithCustomView:groupSearbar];
    
    self.navigationItem.leftBarButtonItems = @[menuBtn,selectBtn,searchBarBtn];
}

#pragma mark - create animation
-(void)createAnimation{
    self.animation = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 427, 176)];
    self.animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.animation.center = self.collectionView.center;
    [self.collectionView addSubview:self.animation];
   // [self.animation startAnimating];
}

#pragma mark - create 2 bottom bar
-(void)createMenuBottomBar{
    // Custom sale and cart discount
   
    self.customSale = [MSRoundedButton buttonWithType:UIButtonTypeCustom];
    self.customSale.frame = CGRectMake(25, WINDOW_HEIGHT - 100, 160, 44);
    self.customSale.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.customSale.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.customSale setImage:[UIImage imageNamed:@"calculator"] forState:UIControlStateNormal];
    self.customSale.imageView.layer.cornerRadius =5.0;
    self.customSale.imageView.backgroundColor =[UIColor barBackgroundColor];
    [self.customSale setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 120)];
    
    [self.customSale setTitle:NSLocalizedString(@"Custom Sale", nil) forState:UIControlStateNormal];
    [self.customSale setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    
    self.cartDiscount = [MSRoundedButton buttonWithType:UIButtonTypeCustom];    
    self.cartDiscount.frame = CGRectMake(WINDOW_WIDTH -427 - 135 - 25,WINDOW_HEIGHT -100, 135, 44);
    self.cartDiscount.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.cartDiscount.titleLabel.font = self.customSale.titleLabel.font;
    [self.cartDiscount setImage:[UIImage imageNamed:@"price_tag_USD"] forState:UIControlStateNormal];
    [self.cartDiscount setTitle:@"Discount" forState:UIControlStateNormal];
    [self.cartDiscount setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    self.cartDiscount.imageView.layer.cornerRadius =5.0;
    self.cartDiscount.imageView.backgroundColor =[UIColor barBackgroundColor];
    [self.cartDiscount setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 90)];
    
    //[self refreshDiscountButton];
    
    [self.customSale addTarget:self action:@selector(customSale:) forControlEvents:UIControlEventTouchUpInside];
    [self.cartDiscount addTarget:self action:@selector(cartDiscount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.customSale];
    
    permission =[Permission MR_findFirst];
    if(permission.all_cart_discount.boolValue || permission.cart_custom_discount.boolValue || permission.cart_coupon.boolValue){
        [self.view addSubview:self.cartDiscount];
    }
}

#pragma mark - Search Bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
      [self searchOnlineWithTerm:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchOnlineWithTerm:searchBar.text];
}


-(void)searchOnlineWithTerm:(NSString *) termSearch{
    
    if(termSearch.length >0){
    NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"data_index contains[cd] %@",termSearch];
    listProducts =[MRProduct MR_findAllSortedBy:@"sort_index" ascending:YES withPredicate:predicate];
        
        MRProduct * test = [listProducts firstObject];
        DLog(@"data_index:%@",test.data_index);
    }else{
          listProducts =[MRProduct MR_findAllSortedBy:@"sort_index" ascending:YES];
    }
    
    [self refreshCollectionView];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
    [self searchOnlineWithTerm:@""];
}


#pragma mark - working with categories
- (IBAction)showSelectCategory:(id)sender
{
    if (selectCategoryList == nil) {
        selectCategoryList = [[SelectCategoryViewController alloc] init];
        self.selectCategoryPopover = [[UIPopoverController alloc] initWithContentViewController:selectCategoryList];
        self.selectCategoryPopover.delegate = selectCategoryList;
        
        selectCategoryList.productCollectionViewVC = self;
        selectCategoryList.popoverController = self.selectCategoryPopover;
        [selectCategoryList reloadContentSize];
    }
    
    [self.selectCategoryPopover presentPopoverFromRect:[(UIButton *)sender bounds] inView:(UIButton *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)didSelectCategory:(MRCategory *)category
{
    if(category == nil){  // All product
        [self loadDatabase];
        
        [categoryTitle setTitle:@"All Products" forState:UIControlStateNormal];
    }else{
        [categoryTitle setTitle:category.name forState:UIControlStateNormal];
        [self filterProductByCategoryId:category.category_id];
    }
    
    //[self.collectionView reloadData];
    
    [self refreshCollectionView];
}


-(void)filterProductByCategoryId:(NSString *)cateID{
    NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"cat_ids contains[cd] %@",cateID];
    listProducts =[MRProduct MR_findAllSortedBy:@"sort_index" ascending:YES withPredicate:predicate];
}

- (void)refreshCollectionView
{
    [self.animation stopAnimating];
    [self.collectionView reloadData];
    
}

#pragma mark - viewProductDetail
- (void)viewProductDetail:(id)sender
{
    if (self.presentedViewController) {
        return;
    }
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[(UIGestureRecognizer *)sender locationInView:self.collectionView]];
    
    MRProduct * mrProduct =[listProducts objectAtIndex:indexPath.row];
    Product *product = [mrProduct convertModelProduct];
    
    ProductViewDetailController *viewController = [ProductViewDetailController new];
    viewController.product = product;
    
    MSNavigationController *navControl = [[MSNavigationController alloc] initWithRootViewController:viewController];
    navControl.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:navControl animated:YES completion:nil];
}


#pragma mark - Collection view source methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(listProducts && listProducts.count >0){
        
        customSale.enabled =YES;
        cartDiscount.enabled = YES;
        
        if(listProducts.count >1){
          self.totalsLabel.text =[NSString stringWithFormat:@"Total %d Products",(int)listProducts.count];
        }else{
          self.totalsLabel.text =[NSString stringWithFormat:@"Total %d Product",(int)listProducts.count];
        }
        return listProducts.count;
    }
    
    customSale.enabled =NO;
    cartDiscount.enabled = NO;
     self.totalsLabel.text =@"Total 0 Product";
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MRProduct * product =[listProducts objectAtIndex:indexPath.row];
    ProductItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductViewIdentifier" forIndexPath:indexPath];

    cell.productName.text = product.name;
    cell.productPrice.text = [Price format:[NSNumber numberWithFloat:[product getPrice].floatValue]];
    
    [cell.productImage setImageWithURL:[NSURL URLWithString:product.image] placeholderImage:[UIImage imageNamed:@"product_placeholder.png"]];
    
    if(product.has_option.boolValue){
        cell.optionsImage.hidden = NO;
    }else{
        cell.optionsImage.hidden = YES;
    }
    
    return cell;
}

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(114, 135);
   // return CGSizeMake(114, 148);
}

#pragma mark - Collection view delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MRProduct * mrProduct =[listProducts objectAtIndex:indexPath.row];
    Product *product = [mrProduct convertModelProduct];
    
   // DLog(@"product:%@",product)
    
    if ([[product objectForKey:@"has_options"] boolValue] == YES) {
        // Init option content view
        ProductOptions *productOptions;
        if (self.productOptionsPopover == nil) {
            productOptions = [[ProductOptions alloc] init];
            self.productOptionsPopover = [[UIPopoverController alloc] initWithContentViewController:productOptions];
            self.productOptionsPopover.delegate = productOptions;
            productOptions.popoverController = self.productOptionsPopover;
        } else {
            productOptions = (ProductOptions *)self.productOptionsPopover.contentViewController;
        }
        productOptions.product = product;
        [productOptions.productOptions removeAllObjects];
        // Update content size for Popover
        productOptions.collectionView = collectionView;
        productOptions.indexPath = indexPath;
        self.productOptionsPopover.popoverContentSize = [productOptions reloadContentSize];
        // Show Popover
        CGRect frame = [[collectionView layoutAttributesForItemAtIndexPath:indexPath] frame];
        [self.productOptionsPopover presentPopoverFromRect:frame inView:collectionView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    } else {
        
        // [self performSelectorOnMainThread:@selector(addProductToCart:) withObject:nil waitUntilDone:YES];
        
        [[[NSThread alloc] initWithTarget:self selector:@selector(addProductToCart:) object:product] start];
    }
}

#pragma mark - Add product to shopping cart
- (BOOL)addProductToCart:(Product *)product {
    [[Quote sharedQuote] addProductOffline:product withOptions:nil];
    return YES;
}

#pragma mark - Custom sale and cart discount
- (IBAction)customSale:(id)sender
{
    if (self.pagingLabel.hidden) {
        self.pagingLabel.hidden = NO;
        self.totalsLabel.hidden = NO;
        
        self.navigationItem.titleView = self.bakNavigation;
        self.bakNavigation = nil;
        
        //[self.customSale setImage:[UIImage imageNamed:@"product_customsale.png"] forState:UIControlStateNormal];
        [self.customSale setImage:[UIImage imageNamed:@"calculator"] forState:UIControlStateNormal];
        
        [self.customSale setTitle:NSLocalizedString(@"Custom Sale", nil) forState:UIControlStateNormal];
        // hide custom sale form
        for (UIViewController *childControl in self.childViewControllers) {
            if ([childControl isKindOfClass:[CustomSaleViewController class]]) {
                [UIView animateWithDuration:0.25 animations:^{
                    childControl.view.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [childControl willMoveToParentViewController:nil];
                    [childControl.view removeFromSuperview];
                    [childControl removeFromParentViewController];
                }];
            }
        }
        return;
    }
    self.pagingLabel.hidden = YES;
    self.totalsLabel.hidden = YES;
    
    self.bakNavigation = self.navigationItem.titleView;
    self.navigationItem.titleView = nil;
   // self.navigationItem.title = NSLocalizedString(@"Custom Sale", nil);
    
    [self.customSale setImage:[UIImage imageNamed:@"btn_close.png"] forState:UIControlStateNormal];
    [self.customSale setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    // Show custom sale form
    CustomSaleViewController *addCustomSale = [[CustomSaleViewController alloc] init];
    [self addChildViewController:addCustomSale];
    
    [self.view addSubview:addCustomSale.view];
    [addCustomSale didMoveToParentViewController:self];
    addCustomSale.view.alpha = 0.0;
    [UIView animateWithDuration:0.25 animations:^{
        addCustomSale.view.alpha = 1.0;
    }];
}

- (IBAction)cartDiscount:(id)sender
{
    // Show cart discount form
    CustomDiscountViewController *customDiscountForm = [[CustomDiscountViewController alloc] init];
    MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:customDiscountForm];
    navController.modalPresentationStyle =UIModalPresentationFormSheet;
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
    
}

- (void)refreshDiscountButton
{
    if ([[Quote sharedQuote] totalItemsQty] == 0.0) {
        [self.cartDiscount setEnabled:NO];
    } else {
        [self.cartDiscount setEnabled:YES];
    }
}

@end
