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
#import "Price.h"

// Sub View
#import "SelectCategoryViewController.h"
#import "ProductOptions.h"
#import "ProductItem.h"
#import "CustomSaleViewController.h"
#import "CustomDiscountViewController.h"
#import "ProductViewDetailController.h"
// lionel added
#import "UrlDomainConfig.h"
//Gin add
#import "UIImage+SimiCustom.h"

// Johan
#import "CategoryModel.h"
#import "ProductModel.h"
// End


#define NUMBER_PRODUCT_ON_PAGE  16


@interface ProductViewController()

@property (strong, nonatomic) UITapGestureRecognizer *touchGesture;
@property (strong, nonatomic) UIActivityIndicatorView *animation;

@property (strong, nonatomic) UIView *bakNavigation;

@property (nonatomic) NSInteger page;
@property (strong, nonatomic) id successObserver, failObserver;

// Johan

@property BOOL checkFooterLoading;
@property BOOL checkFirstLogin;
@property (strong, nonatomic) UIActivityIndicatorView *loadingView;

// End

- (void)loadProductAfterConfigThread;
@end

@implementation ProductViewController
{
    SelectCategoryViewController *selectCategoryList;
    Permission * permission;
    UrlDomainConfig *urlDomainConfig;
    //Gin fix QRBarcode
    NSString *textSearch;
    UIView *viewQR;
    UIImageView *imgQR;
    UITextField *tfBarcode;
    BOOL isQRBarcodeCamera;
    NSDate *dateBegin,*dateEnd;
    int checkQR;// 2 : khoi tao, 1 : La search bang QR, 0 : la search thuong
    //end

    //Johan
    CategoryModel *categoryModel;
    ProductModel *productModel;
    NSMutableDictionary *productRespone;
    NSMutableArray *arrProduct;
    //End
}
@synthesize categoryTitle;
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
@synthesize successObserver,failObserver;

@synthesize checkFooterLoading;
@synthesize checkFirstLogin;

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
//    touchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tryToLoadProducts)];
//    [self.collectionView addGestureRecognizer:touchGesture];
    
    checkFooterLoading = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCollectionView) name:@"ProductCollectionSortAfter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failteToLoadProduct:) name:@"QueryException" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDiscountButton) name:QuoteEndRequestNotification object:nil];
    [self createMenuBottomBar];
    
    [self initDefault];
    
    // Johan
    [self getCategoryCollection];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
    // End
    //Gin
    checkQR = 2;
    //End
}
-(void)viewWillAppear:(BOOL)animated {
    // Johan : Edit refesh cache product when login
    if (!checkFirstLogin) {
        [self.productList removeAllObjects];
        [self.collectionView reloadData];
        [self.animation startAnimating];
//        [self performSelector:@selector(loadProductAfterLogin) withObject:nil afterDelay:0];
//        productModel = [ProductModel new];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProduct:) name:@"DidGetProduct" object:categoryModel];
//        [productModel getProduct];
        checkFirstLogin = true;
    }else{
        NSString *checkUserID = [[NSUserDefaults standardUserDefaults] stringForKey:@"checkUserID"];
        if([checkUserID isEqualToString:@"0"]){
            selectCategoryList = nil;
            [self getCategoryCollection];
            [self.productList removeAllObjects];
            [self.collectionView reloadData];
            [self.animation startAnimating];
            [self performSelector:@selector(loadProductAfterLogin) withObject:nil afterDelay:0];
        }else{
            checkFooterLoading = false;
        }
    }
    // End
}

// lionel added
-(void)startRefresh {
    [self performSelector:@selector(loadProductAfterLogin) withObject:nil afterDelay:0];
}
// end

// Johan
-(void)getCategoryCollection{
    categoryModel = [CategoryModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCategory:) name:@"DidGetCategory" object:categoryModel];
    [categoryModel getCategory];
}

- (void) didGetCategory:(NSNotification *) noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidGetCategory" object:categoryModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if(![respone.status isEqualToString:@"SUCCESS"]){
        categoryModel = nil;
    }
}
// End

#pragma mark - init default
-(void)initDefault{
    self.isLoadingProduct = NO;
    self.searchProducts = [[ProductCollection alloc] init];
    self.searchProducts.pageSize = NUMBER_PRODUCT_ON_PAGE;
    
    // Init product collection
    self.productList = [[ProductCollection alloc] init];
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE;
    self.productList.curPage = 1;
    
    page = 1;
    // Johan
    productRespone = [NSMutableDictionary new];
    [productRespone setValue:@"1" forKey:@"current_page"];
    [productRespone setValue:@"32" forKey:@"number_page"];
    
    arrProduct = [NSMutableArray new];
    // End
    
    self.allProducts = self.productList;
    
    // Refreshing label and add event listener
    
    [self performSelector:@selector(loadProductAfterLogin) withObject:nil afterDelay:0];
    [self refreshPagingLabel];
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
    
    //Gin edit cameraQR
    viewQR = [[UIView alloc] initWithFrame:CGRectMake( 310 -44, 0, 44, 44)];
    imgQR = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 24, 24)];
    imgQR.contentMode = UIViewContentModeScaleAspectFit;
    [imgQR setImage:[[UIImage imageNamed:@"barcode_icon" ] imageWithColor:[UIColor barBackgroundColor]] ];
    [viewQR addSubview:imgQR];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openCameraQRBarcode:)];
    tap.delegate = self;
    [viewQR addGestureRecognizer:tap];
    //End
    UIView * groupSearbar =[[UIView alloc] initWithFrame:CGRectMake(5, 0, 400, 44)];
    [groupSearbar addSubview:self.searchBar];
    [self.searchBar addSubview:viewQR];
    
    UIBarButtonItem *searchBarBtn =[[UIBarButtonItem alloc] initWithCustomView:groupSearbar];
    
    self.navigationItem.leftBarButtonItems = @[menuBtn,selectBtn,searchBarBtn];
}
//Gin
#pragma mark TapGesture Delegate
-(void)openCameraQRBarcode:(UITapGestureRecognizer *) tapGeture{
    BarCodeViewController *barcodeViewController = [BarCodeViewController new];
    barcodeViewController.delegate = self;
    isQRBarcodeCamera = YES;
    [self.navigationController pushViewController:barcodeViewController animated:YES];
}
-(void)searchQRcodeText:(NSString *)text{
    checkQR = 1;
    [self searchOnlineWithTerm:text];
}
//End
#pragma mark - create animation
-(void)createAnimation{
    self.animation = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((WINDOW_WIDTH - 427- 50)/2, (WINDOW_HEIGHT -276)/2, 50, 176)];
    self.animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    self.animation.center = self.collectionView.center;
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
    
    NSInteger number_page = NUMBER_PRODUCT_ON_PAGE * 2;
    [productRespone setObject:[NSString stringWithFormat:@"%ld",(long)number_page] forKey:@"number_page"];

//    [self loadMoreProducts];
    productModel = [ProductModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProduct:) name:@"DidGetProduct" object:productModel];
    [productModel getProduct:[productRespone valueForKey:@"current_page"] limit:[productRespone valueForKey:@"number_page"] category:nil keySearch:nil];
    [productRespone setObject:[NSString stringWithFormat:@"%ld",(long)number_page] forKey:@"number_page"];
    
}

// Johan
- (void) didGetProduct:(NSNotification *) noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidGetProduct" object:productModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    [self.animation stopAnimating];
    self.isLoadingProduct = NO;
    if([respone.status isEqualToString:@"SUCCESS"]){
        NSMutableDictionary * returnData = [productModel valueForKey:@"data"];
        [self parseData:returnData];
        [self refreshPagingLabel];
        [self.collectionView reloadData];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
        
}

- (void) parseData:(NSMutableDictionary *)data{
    NSMutableArray *sortArr = [NSMutableArray new];
    
    for (NSString *key in [data allKeys]) {
        if([key isEqual:@"total"]){
            [productRespone setObject:[data valueForKey:key] forKey:@"total"];
        }else{
            Product *product = [Product new];
            [product setValue:key forKey:@"id"];
            [product addEntriesFromDictionary:[data objectForKey:key]];
            [sortArr addObject:product];
        }
    }
    
    NSArray *arr = [sortArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 valueForKey:@"id"] integerValue] > [[obj2 valueForKey:@"id"] integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if ([[obj1 valueForKey:@"id"] integerValue] < [[obj2 valueForKey:@"id"] integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortedNameArray= [arr sortedArrayUsingDescriptors:@[sort]];
    
    [arrProduct addObjectsFromArray:sortedNameArray];
    
    [productRespone setObject:arrProduct forKey:@"arr_product"];
}
// End

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
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE * 3;
    [self loadMoreProducts];
    self.productList.pageSize = NUMBER_PRODUCT_ON_PAGE;
    
}

- (void)viewProductDetail:(id)sender
{
    if (self.presentedViewController) {
        return;
    }
    NSInteger count = arrProduct.count;
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[(UIGestureRecognizer *)sender locationInView:self.collectionView]];
    NSUInteger row = [indexPath section] * NUMBER_PRODUCT_ON_PAGE + [Utilities transformMatrix4x4:[indexPath row]];
    if (row >= count) {
        return;
    }
    Product *product = [arrProduct objectAtIndex:row];
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
    //Gin
    [viewQR setHidden:YES];
    //End
    return YES;
}



- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //Gin
    if (textSearch) {
        if (![textSearch containsString:searchText]) {
             searchBar.text = [searchText stringByReplacingOccurrencesOfString:textSearch withString:@""];
            textSearch = nil;
        }
        dateBegin = [NSDate new];
    }else{
        if (searchText.length == 1) {
            dateBegin = [NSDate new];
        }
    }
    //End
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    checkFooterLoading = false;
    [self searchOnlineWithTerm:searchBar.text];
    //Gin
    dateEnd = [NSDate new];
    NSTimeInterval secondsBetween = [dateEnd timeIntervalSinceDate:dateBegin];
    if (secondsBetween > 0.5) {
        checkQR = 0;
    }else{
        checkQR = 1;
    }
    if (checkQR == 0) {
        [searchBar resignFirstResponder];
    }
    //End
}
-(void)searchOnlineWithTerm:(NSString *) termSearch{
    [arrProduct removeAllObjects];
    page = 1;
    [self refreshCollectionView];
    textSearch = termSearch;
    self.searchBar.text = termSearch;
    self.searchBar.showsCancelButton = YES;
    [viewQR setHidden:YES];
    [productRespone setValue:[self.currentCategory getId] forKey:@"category_id"];
    [productRespone setValue:termSearch forKey:@"keyword"];
    [self tryToLoadProducts];
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchProducts clear];
    self.searchBar.text = @"";
    self.searchBar.showsCancelButton = NO;
    // Johan
    [viewQR setHidden:NO];
    [searchBar resignFirstResponder];
    [arrProduct removeAllObjects];
    // End
    page = 1;
    [self refreshCollectionView];
    [productRespone setValue:nil forKey:@"keyword"];
    [productRespone setValue:[self.currentCategory getId] forKey:@"category_id"];
    [self.productList setSearchTerm:nil];
    [self tryToLoadProducts];
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
}
//Gin fix QRBarcode
#pragma mark - Barcode methods
- (void)CheckSearchQRbarcode
{
    // Take action for Bar Code
    if (checkQR == 1 && [[productRespone valueForKey:@"total"] boolValue]){
        Product *product1 = [[productRespone objectForKey:@"arr_product"] objectAtIndex:0];
        if ([[product1 objectForKey:@"has_options"] boolValue]) {
            // View detail
            ProductViewDetailController *viewController = [ProductViewDetailController new];
            viewController.product = product1;
            MSNavigationController *navControl = [[MSNavigationController alloc] initWithRootViewController:viewController];
            navControl.modalPresentationStyle = UIModalPresentationPageSheet;
            [self presentViewController:navControl animated:YES completion:nil];
        } else {
            // Add to Cart
            [[[NSThread alloc] initWithTarget:self selector:@selector(addProductToCart:) object:product1] start];
        }
    }
    if (isQRBarcodeCamera) {
        checkQR = 2;
        isQRBarcodeCamera = NO;
    }
    //End
}
//End
#pragma mark - working with categories
- (IBAction)showSelectCategory:(id)sender
{
    if (selectCategoryList == nil) {
        selectCategoryList = [[SelectCategoryViewController alloc] init];
        self.selectCategoryPopover = [[UIPopoverController alloc] initWithContentViewController:selectCategoryList];
        self.selectCategoryPopover.delegate = selectCategoryList;
        
        selectCategoryList.productController = self;
        selectCategoryList.popoverController = self.selectCategoryPopover;

        if(categoryModel != nil && [categoryModel isKindOfClass:[NSDictionary class]]){
            [selectCategoryList parseData:categoryModel];
        }
    }
    
    // self.selectCategoryPopover.popoverContentSize = [(SelectCategoryViewController *)self.selectCategoryPopover.contentViewController reloadContentSize];
    else{
        [selectCategoryList reloadContentSize];
    }
    [self.selectCategoryPopover presentPopoverFromRect:[(UIButton *)sender bounds] inView:(UIButton *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (void)didSelectCategory:(RPCategory *)category
{
    if (category == nil) {
        
//        if (self.currentCategory == nil) {
//            return;
//        }
        
        self.currentCategory = nil;
        [arrProduct removeAllObjects];
        page = 1;
        if ([self.productList totalItems]) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
        [productRespone setValue:nil forKey:@"category_id"];
//        [productRespone setValue:nil forKey:@"keyword"];
        [categoryTitle setTitle:NSLocalizedString(@"All Products", nil) forState:UIControlStateNormal];
        [categoryTitle refreshButtonView];
        [self refreshCollectionView];
        [self tryToLoadProducts];
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
        return;
    }
    
    if ([category isEqual:self.currentCategory]) {
        return;
    }
    
    self.currentCategory = category;
    [categoryTitle setTitle:[category getName] forState:UIControlStateNormal];
    [categoryTitle refreshButtonView];
    [arrProduct removeAllObjects];
    page = 1;
    [self refreshCollectionView];
    // Update product list filter (by category) and reload view
    [productRespone setValue:[category getId] forKey:@"category_id"];
    [self tryToLoadProducts];
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)refreshCollectionView
{
    [self.animation stopAnimating];
    
    if (touchGesture && [self.productList getSize]) {
        [self.collectionView removeGestureRecognizer:touchGesture];
        touchGesture = nil;
    }

    [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self refreshPagingLabel];

    self.isLoadingProduct = NO;
}

- (void)refreshPagingLabel
{
    //Gin fix QRbarcode
    if (textSearch) {
        [self CheckSearchQRbarcode];
    }
    //end
    
    // Johan
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    NSInteger total = ([[productRespone valueForKey:@"total"] integerValue]);
    // End
    
    int totalPage = 1;
    if (total > 0) {
        totalPage = (int) (total + NUMBER_PRODUCT_ON_PAGE - 1) / NUMBER_PRODUCT_ON_PAGE;
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
        
        //Johan
        if (count < total && page == (int)[self numberOfSectionsInCollectionView:self.collectionView]) {
            if(checkFooterLoading){
                [productRespone setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"current_page"];
                needLoadMore = YES;
            }else{
                [productRespone setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"current_page"];
                needLoadMore = YES;
                page--;
            }
        }
        // End
    }
    self.pagingLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Page %d of %d", nil), page, totalPage];
    if (total < 2) {
        self.totalsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Total %d Product", nil), total];
    } else {
        self.totalsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Total %d Products", nil), total];
    }
    if (needLoadMore && !self.isLoadingProduct) {
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
        NSInteger curPage = [[productRespone valueForKey:@"current_page"] integerValue];
        NSInteger pageSize = [[productRespone valueForKey:@"number_page"] integerValue];
        NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
        if (count > (curPage - 1) * pageSize || (count % pageSize)) {
            return;
        }
        if (curPage > (count / pageSize) + 1) {
            curPage = (count / pageSize) + 1;
            [productRespone setValue:[NSString stringWithFormat:@"%ld",(long)curPage] forKey:@"current_page"];
        }
        productModel = [ProductModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProduct:) name:@"DidGetProduct" object:productModel];
        
        //Ravi fix bug search
//        [productModel getProduct:[productRespone valueForKey:@"current_page"] limit:[productRespone valueForKey:@"number_page"] category:nil keySearch:nil];
        [productModel getProduct:[productRespone valueForKey:@"current_page"] limit:[productRespone valueForKey:@"number_page"] category:[productRespone valueForKey:@"category_id"] keySearch:[productRespone valueForKey:@"keyword"]];
        //End
        
    }
    @catch (NSException *exception) {
        // Don't show exception to end-user
        self.isLoadingProduct = NO;
        [self.animation stopAnimating];
    }
}

#pragma mark - Collection view source methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    NSInteger total = ([[productRespone valueForKey:@"total"]integerValue]);
    if (count > 0) {
        NSInteger number = (count + NUMBER_PRODUCT_ON_PAGE - 1) / NUMBER_PRODUCT_ON_PAGE;
        if (total > count) {
            return number+1;
        }
        return number;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    if (section < [self numberOfSectionsInCollectionView:collectionView] - 1) {
        return NUMBER_PRODUCT_ON_PAGE;
    }
    if (count < ([[productRespone valueForKey:@"total"]integerValue])) {
        return 1;
    }
    NSUInteger number = count % NUMBER_PRODUCT_ON_PAGE;
    if (count && number == 0) {
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
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    if (row >= count) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:EmptyCellIdentifier forIndexPath:indexPath];
    }
    ProductItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ProductViewIdentifier forIndexPath:indexPath];
    Product *product = [((NSMutableArray*)[productRespone objectForKey:@"arr_product"]) objectAtIndex:row];
    cell.layer.cornerRadius = 10;
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    cell.productImage.clipsToBounds = YES;
    cell.productName.text = [product objectForKey:@"name"];
    cell.productPrice.text = @"";
    CGFloat finalPrice = 0;
    if ([product valueForKey:@"final_price"] != nil) {
        finalPrice = (CGFloat)[[product valueForKey:@"final_price"] floatValue];
    } else {
        if ([product valueForKey:@"price"] != nil) {
            finalPrice = (CGFloat)[[product valueForKey:@"price"] floatValue];
        }
    }
    if (finalPrice == 0) {
        cell.productPrice.hidden = YES;
        cell.productPriceBackground.hidden = YES;
    } else {
        cell.productPrice.hidden = NO;
        cell.productPriceBackground.hidden = NO;
        cell.productPrice.text = [Price format:[NSNumber numberWithFloat: finalPrice]];
    }
    cell.productPrice.textColor = [UIColor barBackgroundColor];
    [cell.productImage setImageWithURL:[NSURL URLWithString:[product objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"product_placeholder.png"]];
    cell.optionsImage.hidden = YES; // ![[product objectForKey:@"has_options"] boolValue];
    
    return cell;
}

// Johan: Add footer view loading

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    [self.loadingView stopAnimating];
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    NSInteger total = ([[productRespone valueForKey:@"total"] integerValue]);

    NSInteger sectionIndex = [self numberOfSectionsInCollectionView:self.collectionView] - 1;
    if(sectionIndex == section){
        if(checkFooterLoading){
            if (count >= total) {
                return CGSizeZero;
            }else{
                return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
            }
        }else{
            return CGSizeZero;
        }
    }else{
        return CGSizeZero;
    }
}


- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        
        if(self.loadingView == nil){
            self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        
        self.loadingView.center = CGPointMake(((self.collectionView.frame.size.width / 2) - 50), (self.collectionView.frame.size.height / 2));
        
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer" forIndexPath:indexPath];
        
        [footerView addSubview:self.loadingView];
        
        [self.loadingView startAnimating];
        
        reusableview = footerView;
    }
    
    return reusableview;
}
// End

//Ravi fix bug lệch layout ở productview khi scoll 
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    UIEdgeInsets insets;
    if (WINDOW_WIDTH > 1024) {
        insets = UIEdgeInsetsMake(0, 15, 0, 14);
    }else {
        insets = UIEdgeInsetsMake(0, 15, 0, 16);
    }
    return insets;
}
//End

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    NSUInteger row = [indexPath section] * NUMBER_PRODUCT_ON_PAGE;
    if (row == count
        && [indexPath row] == 0
        ) {
        return CGSizeMake(30, 135);
    }
    // Gin
    if (WINDOW_WIDTH > 1024) {
        return CGSizeMake(200, 190);
    }else
        return CGSizeMake(114, 135);
}

#pragma mark - Collection view delegate methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // [animation startAnimating];
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    NSUInteger row = [indexPath section] * NUMBER_PRODUCT_ON_PAGE + [Utilities transformMatrix4x4:[indexPath row]];
    if (row >= count) {
        return;
    }
    Product *product = [[productRespone objectForKey:@"arr_product"] objectAtIndex:row];
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
    // Johan
    NSInteger count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    NSInteger total = ([[productRespone valueForKey:@"total"] integerValue]);
    // End
    
    checkFooterLoading = true;
    
    if (self.isLoadingProduct) {
        return;
    }
    if (count >= total) {
        return;
    }
    NSArray *indexPaths = [self.collectionView indexPathsForVisibleItems];
    if ([indexPaths count]) {
        page = [[indexPaths objectAtIndex:0] section] + 1;
        if (page == count / NUMBER_PRODUCT_ON_PAGE) {
            // Load more product
            page  = page + 1;
            [productRespone setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"current_page"];
            [[[NSThread alloc] initWithTarget:self selector:@selector(loadMoreProducts) object:nil] start];
        }
    }
}

- (IBAction)tryToLoadProducts
{
    checkFooterLoading = false;
    if (self.isLoadingProduct) {
        return;
    }
    
    NSInteger count = 0;
    if(![[productRespone objectForKey:@"arr_product"] isKindOfClass:[NSNull class]]){
        count = ((NSMutableArray*)[productRespone objectForKey:@"arr_product"]).count;
    }
    
    if (count) {
        return;
    }
    if ([InternetConnection canAccess]) {
        [productRespone setValue:@"1" forKey:@"current_page"];
        [self.animation startAnimating];
        
        productModel = [ProductModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetProduct:) name:@"DidGetProduct" object:productModel];
        [productModel getProduct:[productRespone valueForKey:@"current_page"] limit:[productRespone valueForKey:@"number_page"] category:[productRespone valueForKey:@"category_id"] keySearch:[productRespone valueForKey:@"keyword"]];
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
