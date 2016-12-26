//
//  ProductViewController.m
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 2/3/16.
//  Copyright (c) 2013 Marcus Nguyen. All rights reserved.
//

#import "ProductViewController.h"
#import "Configuration.h"
#import "ShowMenuButton.h"
#import "SearchButton.h"
#import "SelectCategoryButton.h"
#import "InternetConnection.h"
#import "MSFramework.h"

// Models
#import "ProductCollection.h"
#import "Product.h"
#import "Quote.h"

// Sub View
#import "SelectCategoryViewController.h"
#import "ProductOptions.h"
#import "ProductItem.h"
#import "CustomSaleViewController.h"
#import "CustomDiscountViewController.h"
#import "ProductViewDetailController.h"

#define NUMBER_PRODUCT_ON_PAGE  16


@interface ProductViewController()

@property (strong, nonatomic) UITapGestureRecognizer *touchGesture;
@property (strong, nonatomic) UIActivityIndicatorView *animation;

@property (strong, nonatomic) UIView *bakNavigation;

@property (nonatomic) NSInteger page;

- (void)loadProductAfterConfigThread;
@end

@implementation ProductViewController
{
    SelectCategoryViewController *selectCategoryList;
    Permission * permission;
}

@synthesize touchGesture;

@synthesize isLoadingProduct = _isLoadingProduct;
@synthesize allProducts = _allProducts;
@synthesize searchProducts = _searchProducts;
@synthesize selectCategoryPopover;
@synthesize currentCategory = _currentCategory;

@synthesize searchBar = _searchBar;
@synthesize currentIndex = _currentIndex;

@synthesize pagingLabel = _pagingLabel;
@synthesize collectionView = _collectionView;
@synthesize productList = _productList;
@synthesize productOptionsPopover;

@synthesize customSale, cartDiscount;
@synthesize bakNavigation, page;

//@synthesize animation;

static ProductViewController *_sharedInstance = nil;

+(ProductViewController*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sharedInstance =self;
    
    self.view.backgroundColor = [UIColor backgroundColor];
    self.collectionView.backgroundColor = [UIColor backgroundColor];
    
    [self createAnimation];
    
    [self createMenuBar];
    
    // Double Taps => Show Product Detail
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewProductDetail:)];
    [self.collectionView addGestureRecognizer:longPress];
    
    // Load Product (first time)
    touchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tryToLoadProducts)];
    [self.collectionView addGestureRecognizer:touchGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollectionView) name:@"ProductCollectionSortAfter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failteToLoadProduct:) name:@"QueryException" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDiscountButton) name:QuoteEndRequestNotification object:nil];
    
    [self createMenuBottomBar];
    
    [self initDefault];
    
}

#pragma mark - init default
-(void)initDefault{
    self.isLoadingProduct = NO;
    self.searchProducts = [[ProductCollection alloc] init];
    self.searchProducts.pageSize = NUMBER_PRODUCT_ON_PAGE;
    
    // Init product collection
    self.productList = [[ProductCollection alloc] init];
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE;
    self.productList.curPage = 1;
    
    self.allProducts = self.productList;
    
    // Refreshing label and add event listener
    [self refreshPagingLabel];
    [self performSelector:@selector(loadProductAfterLogin) withObject:nil afterDelay:0];
}

#pragma mark - Create Menu bar
-(void)createMenuBar{
    // Add Show Menu Button
    UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithCustomView:[[ShowMenuButton alloc] initMenuButton]];
    
    SelectCategoryButton *categoryTitle = [[SelectCategoryButton alloc] initCategoryButton];
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
    [self.animation startAnimating];
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
    //[self.customSale setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 110)];
    [self.customSale setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 120)];
    
    [self.customSale setTitle:NSLocalizedString(@"Custom Sale", nil) forState:UIControlStateNormal];
    [self.customSale setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    
    self.cartDiscount = [MSRoundedButton buttonWithType:UIButtonTypeCustom];    
    self.cartDiscount.frame = CGRectMake(WINDOW_WIDTH -427 - 135 - 25,WINDOW_HEIGHT -100, 135, 44);
    self.cartDiscount.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.cartDiscount.titleLabel.font = self.customSale.titleLabel.font;
    [self.cartDiscount setImage:[UIImage imageNamed:@"price_tag_USD"] forState:UIControlStateNormal];
    [self.cartDiscount setTitle:NSLocalizedString(@"Discount", nil) forState:UIControlStateNormal];
    [self.cartDiscount setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 8)];
    self.cartDiscount.imageView.layer.cornerRadius =5.0;
    self.cartDiscount.imageView.backgroundColor =[UIColor barBackgroundColor];
    //[self.cartDiscount setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 90)];
    [self.cartDiscount setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 90)];
    
    [self refreshDiscountButton];
    
    [self.customSale addTarget:self action:@selector(customSale:) forControlEvents:UIControlEventTouchUpInside];
    [self.cartDiscount addTarget:self action:@selector(cartDiscount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.customSale];
    
    permission =[Permission MR_findFirst];
    if(permission.all_cart_discount.boolValue || permission.cart_custom_discount.boolValue || permission.cart_coupon.boolValue){
        [self.view addSubview:self.cartDiscount];
    }
}

#pragma mark - load data
#pragma mark -
- (void)loadProductAfterLogin
{
    // Clear data
    [self.allProducts clear];
    [self.searchProducts clear];
    page = 1;
    self.currentIndex = nil;
    
    [self.collectionView reloadData];
    [self.cartDiscount setEnabled:NO];
    
    // Reload data from Website
    if (self.currentCategory) {
        [self didSelectCategory:nil];
    }
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE * 70;
    [self loadMoreProducts];
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE;
    
}

- (void)loadProductAfterConfig
{
    // Clear data
    [self.allProducts clear];
    [self.searchProducts clear];
    page = 1;
    self.currentIndex = nil;
    [self.collectionView reloadData];
    
    // Reload data from Website
    if (self.currentCategory) {
        [self didSelectCategory:nil];
    }
    
    // Animation
    [self.animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadProductAfterConfigThread) object:nil] start];
}

- (void)loadProductAfterConfigThread
{
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE  * 70;
    [self loadMoreProducts];
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE;
}

- (void)viewProductDetail:(id)sender
{
    if (self.presentedViewController) {
        return;
    }
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[(UIGestureRecognizer *)sender locationInView:self.collectionView]];
    NSUInteger row = [indexPath section] * NUMBER_PRODUCT_ON_PAGE + [Utilities transformMatrix4x4:[indexPath row]];
    if (row >= [self.productList getSize]) {
        return;
    }
    Product *product = [self.productList objectAtIndex:row];
    ProductViewDetailController *viewController = [ProductViewDetailController new];
    viewController.product = product;
    
    MSNavigationController *navControl = [[MSNavigationController alloc] initWithRootViewController:viewController];
    navControl.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:navControl animated:YES completion:nil];
}

- (void)failteToLoadProduct:(NSNotification *)note
{
    id model = [[note userInfo] objectForKey:@"model"];
    if ([self.productList isEqual:model]) {
        self.isLoadingProduct = NO;
    }
}

#pragma mark - Search Bar delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.searchBar.showsCancelButton = YES;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchOnlineWithTerm:searchBar.text];
}


-(void)searchOnlineWithTerm:(NSString *) termSearch{
    [self.productList clear];
    page = 1;
    [self refreshCollectionView];
    [self.productList setSearchTerm:termSearch];
    [self tryToLoadProducts];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchProducts clear];
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    
    [self searchOnlineWithTerm:@""];
}


#pragma mark - working with categories
- (IBAction)showSelectCategory:(id)sender
{
    if (selectCategoryList == nil) {
        selectCategoryList = [[SelectCategoryViewController alloc] init];
        self.selectCategoryPopover = [[UIPopoverController alloc] initWithContentViewController:selectCategoryList];
        self.selectCategoryPopover.delegate = selectCategoryList;
        
        selectCategoryList.productController = self;
        selectCategoryList.popoverController = self.selectCategoryPopover;
        [selectCategoryList reloadContentSize];
    }
    
    // self.selectCategoryPopover.popoverContentSize = [(SelectCategoryViewController *)self.selectCategoryPopover.contentViewController reloadContentSize];
    [self.selectCategoryPopover presentPopoverFromRect:[(UIButton *)sender bounds] inView:(UIButton *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)didSelectCategory:(Category *)category
{
    if (category == nil) {
        if (self.currentCategory == nil) {
            return;
        }
        self.currentCategory = nil;
        [self.productList clear];
        page = 1;
        if ([self.productList totalItems]) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        self.productList = self.allProducts;
        [(SelectCategoryButton *)self.navigationItem.titleView setTitle:NSLocalizedString(@"All Products", nil) forState:UIControlStateNormal];
        [(SelectCategoryButton *)self.navigationItem.titleView refreshButtonView];
        [self refreshCollectionView];
        return;
    }
    if ([category isEqual:self.currentCategory]) {
        return;
    }
    self.currentCategory = category;
    self.productList = self.searchProducts;
    [(SelectCategoryButton *)self.navigationItem.titleView setTitle:[category getName] forState:UIControlStateNormal];
    [(SelectCategoryButton *)self.navigationItem.titleView refreshButtonView];
    
    [self.productList clear];
    page = 1;
    [self refreshCollectionView];
    // Update product list filter (by category) and reload view
    [self.productList setCurrentCategory:[category getId]];
    [self tryToLoadProducts];
}

- (void)refreshCollectionView
{
    [self.animation stopAnimating];
    
    if (touchGesture && [self.productList getSize]) {
        [self.collectionView removeGestureRecognizer:touchGesture];
        touchGesture = nil;
    }
    // refresh collection view and update information after load collection view
    // [self.collectionView reloadData];
    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self refreshPagingLabel];
    self.isLoadingProduct = NO;
}

- (void)refreshPagingLabel
{
    int totalPage = 1;
    if ([self.productList totalItems] > 0) {
        totalPage = (int) ([self.productList totalItems] + NUMBER_PRODUCT_ON_PAGE - 1) / NUMBER_PRODUCT_ON_PAGE;
    }
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    if (page <= 0) {
        page = 1;
    }
    BOOL needLoadMore = NO;
    if (indexPaths != nil && [indexPaths count]) {
        page = (int)[[indexPaths objectAtIndex:0] section];
        for (NSUInteger i = 1; i < [indexPaths count]; i++) {
            if (page < (int)[[indexPaths objectAtIndex:i] section]) {
                page = (int)[[indexPaths objectAtIndex:i] section];
                break;
            }
        }
        page++;
        if ([self.productList getSize] < [self.productList totalItems]
            && page == (int)[self numberOfSectionsInCollectionView:self.collectionView]
            ) {
            self.productList.curPage = page;
            needLoadMore = YES;
            page--;
        }
    }// else { // if (![self.productList getSize]) {
    //    page = 1;
    //}
    self.pagingLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Page %d of %d", nil), page, totalPage];
    if ([self.productList totalItems] < 2) {
        self.totalsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Total %d Product", nil), [self.productList totalItems]];
    } else {
        self.totalsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Total %d Products", nil), [self.productList totalItems]];
    }
    if (needLoadMore && !self.isLoadingProduct) {
        
        //[self.loadingAnimation startAnimating];
        [self.animation stopAnimating];
        
        [[[NSThread alloc] initWithTarget:self selector:@selector(loadMoreProducts) object:nil] start];
    }
}

- (void)loadMoreProducts
{
    if (self.isLoadingProduct) {
        return;
    }
    self.isLoadingProduct = YES;
    @try {
        [self.productList partialLoad];
    }
    @catch (NSException *exception) {
        // Don't show exception to end-user
        self.isLoadingProduct = NO;
        //[self.loadingAnimation stopAnimating];
        [self.animation stopAnimating];
    }
}

#pragma mark - Collection view source methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([self.productList getSize] > 0) {
        NSInteger number = ([self.productList getSize] + NUMBER_PRODUCT_ON_PAGE - 1) / NUMBER_PRODUCT_ON_PAGE;
        if ([self.productList totalItems] > [self.productList getSize]) {
            return number+1;
        }
        return number;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section < [self numberOfSectionsInCollectionView:collectionView] - 1) {
        return NUMBER_PRODUCT_ON_PAGE;
    }
    if ([self.productList getSize] < [self.productList totalItems]) {
        return 1;
    }
    NSUInteger number = [self.productList getSize] % NUMBER_PRODUCT_ON_PAGE;
    if ([self.productList getSize] && number == 0) {
        return NUMBER_PRODUCT_ON_PAGE;
    }
    return [Utilities transformItems4x4:number];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
     NSString *ProductViewIdentifier = @"ProductViewIdentifier";
     NSString *EmptyCellIdentifier = @"EmptyCellIdentifier";
     BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"ProductItem" bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:ProductViewIdentifier];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:EmptyCellIdentifier];
        nibsRegistered = YES;
    }
    NSUInteger row = [indexPath section] * NUMBER_PRODUCT_ON_PAGE + [Utilities transformMatrix4x4:[indexPath row]];
    if (row >= [self.productList getSize]) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:EmptyCellIdentifier forIndexPath:indexPath];
    }
    ProductItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ProductViewIdentifier forIndexPath:indexPath];
    
    Product *product = [self.productList objectAtIndex:row];
    
    cell.productName.text = [product objectForKey:@"name"];
    [cell.productImage setImageWithURL:[NSURL URLWithString:[product objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"product_placeholder.png"]];
    cell.optionsImage.hidden = YES; // ![[product objectForKey:@"has_options"] boolValue];
    
    return cell;
}

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath section] * NUMBER_PRODUCT_ON_PAGE;
    if (row == [self.productList getSize]
        && [indexPath row] == 0
        ) {
        return CGSizeMake(30, 135);
    }
    return CGSizeMake(114, 135);
}

#pragma mark - Collection view delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // [animation startAnimating];
    
    NSUInteger row = [indexPath section] * NUMBER_PRODUCT_ON_PAGE + [Utilities transformMatrix4x4:[indexPath row]];
    if (row >= [self.productList getSize]) {
        return;
    }
    Product *product = [self.productList objectAtIndex:row];
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

#pragma mark - Scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self refreshPagingLabel];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isLoadingProduct) {
        return;
    }
    if ([self.productList getSize] >= [self.productList totalItems]) {
        return;
    }
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    if ([indexPaths count]) {
        page = [[indexPaths objectAtIndex:0] section] + 1;
        if (page == [self.productList getSize] / NUMBER_PRODUCT_ON_PAGE) {
            // Load more product
            self.productList.curPage = page + 1;
            [self.animation startAnimating];
            
            [[[NSThread alloc] initWithTarget:self selector:@selector(loadMoreProducts) object:nil] start];
        }
    }
}

- (IBAction)tryToLoadProducts
{
    if (self.isLoadingProduct) {
        return;
    }
    if ([self.productList getSize]) {
        return;
    }
    if ([InternetConnection canAccess]) {
        self.productList.curPage = 1;
        
        [self.animation startAnimating];
        
        [[[NSThread alloc] initWithTarget:self selector:@selector(loadMoreProducts) object:nil] start];
    }
}

#pragma mark - Add product to shopping cart
- (BOOL)addProductToCart:(Product *)product {
    [[Quote sharedQuote] addProduct:product withOptions:nil];
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
