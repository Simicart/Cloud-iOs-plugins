//
//  CatalogViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/16/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CatalogViewController.h"
#import "MenuContent.h"

#import "CartViewController.h"
#import "CheckoutViewController.h"
//#import "OfflineCheckOutVC.h"

#import "CartInformation.h"

#import "MSFramework.h"
#import "Configuration.h"
#import "ProductCollection.h"
#import "LeftSideBarMenuVC.h"
#import "CustomerEditViewController.h"

#import "ProductCollectionViewVC.h"

@interface CatalogViewController()
@property (strong, nonatomic) MSNavigationController *productNav;
@property (strong, nonatomic) MSNavigationController *cartNav;
@property (strong, nonatomic) CheckoutViewController *checkoutNav;

@end

@implementation CatalogViewController
@synthesize productNav, cartNav, checkoutNav;

static CatalogViewController * _sharedInstance =nil;

+(CatalogViewController *)sharedInstance{
    
    if(_sharedInstance !=nil){
        return  _sharedInstance;
    }
    
    @synchronized(self) {
        if(_sharedInstance ==nil){
          _sharedInstance =[[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sharedInstance =self;
    
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    [self.view setBackgroundColor:[UIColor lightGrayColor]];

    ProductCollectionViewVC *productView = [[ProductCollectionViewVC alloc] initWithNibName:@"ProductCollectionViewVC" bundle:nil];
    productNav = [[MSNavigationController alloc] initWithRootViewController:productView];
    productNav.view.frame = CGRectMake(0, 0, WINDOW_WIDTH-427, WINDOW_HEIGHT);
    
    CartViewController *cartView = [[CartViewController alloc] initWithNibName:@"CartViewController" bundle:nil];
    cartNav = [[MSNavigationController alloc] initWithRootViewController:cartView];    
    cartNav.view.frame = CGRectMake(WINDOW_WIDTH -427, 0, 427, WINDOW_HEIGHT);
    
   // cartView.productView = productView;
    
    // Add view controllers to self
    [self addChildViewController:productNav];
    [self.view addSubview:productNav.view];
    [productNav didMoveToParentViewController:self];
    
    [self addChildViewController:cartNav];
    [self.view addSubview:cartNav.view];
    [cartNav didMoveToParentViewController:self];
    
    // Change Page Event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToCheckoutPage) name:@"GoToCheckoutPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToShoppingCartPage) name:@"GoToShoppingCartPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPopUpAddNewCustomer) name:NOTIFY_ADD_NEW_CUSTOMER object:nil];
}

#pragma mark - Change page
- (void)goToCheckoutPage
{
    if (checkoutNav == nil) {
        // define checkout page
        checkoutNav = [[CheckoutViewController alloc] init];
        //checkoutNav = [[OfflineCheckOutVC alloc] init];
        checkoutNav.view.frame = CGRectMake(WINDOW_WIDTH, 0, 596, WINDOW_HEIGHT+20);
        
        [self addChildViewController:checkoutNav];
        [self.view addSubview:checkoutNav.view];
        [checkoutNav didMoveToParentViewController:self];
    }
    // Animation, Back 597 points
    [UIView beginAnimations:@"GoToPage" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    productNav.view.frame = [self translationFrame:productNav.view.frame withX:-597 withY:0];
    cartNav.view.frame = [self translationFrame:cartNav.view.frame withX:-597 withY:0];
    checkoutNav.view.frame = [self translationFrame:checkoutNav.view.frame withX:-597 withY:0];
    
    CartViewController *cartView = (CartViewController *)cartNav.topViewController;
    cartView.totalButton.frame = [self translationFrame:cartView.totalButton.frame withX:0 withY:75];
    cartView.totalLabel.frame = [self translationFrame:cartView.totalLabel.frame withX:0 withY:75];
    cartView.cartController.view.frame = [self resizeFrame:cartView.cartController.view.frame width:0 height:82];
    
    //gan gia tri total price
    checkoutNav.headerTotal.text = cartView.totalLabel.text;
    
    [UIView commitAnimations];
}

- (void)goToShoppingCartPage
{
    // Animation, Add 597 points
    [UIView beginAnimations:@"GoToPage" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    productNav.view.frame = [self translationFrame:productNav.view.frame withX:597 withY:0];
    cartNav.view.frame = [self translationFrame:cartNav.view.frame withX:597 withY:0];
    checkoutNav.view.frame = [self translationFrame:checkoutNav.view.frame withX:597 withY:0];
    
    CartViewController *cartView = (CartViewController *)cartNav.topViewController;
    cartView.totalButton.frame = [self translationFrame:cartView.totalButton.frame withX:0 withY:-75];
    cartView.totalLabel.frame = [self translationFrame:cartView.totalLabel.frame withX:0 withY:-75];
    cartView.cartController.view.frame = [self resizeFrame:cartView.cartController.view.frame width:0 height:-82];
    
    [UIView commitAnimations];
}

- (CGRect)translationFrame:(CGRect)frame withX:(CGFloat)x withY:(CGFloat)y
{
    return CGRectMake(frame.origin.x + x, frame.origin.y + y, frame.size.width, frame.size.height);
}

- (CGRect)resizeFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height
{
    return CGRectMake(frame.origin.x, frame.origin.y, frame.size.width + width, frame.size.height + height);
}

- (IBAction)showMenuButtonClick:(id)sender {
    
    LeftSideBarMenuVC *leftMenuSetting = [[LeftSideBarMenuVC alloc] initWithNibName:@"LeftSideBarMenuVC" bundle:nil];
    self.revealSideViewController.panInteractionsWhenOpened = PPRevealSideInteractionNavigationBar;
    CGFloat offset =CGRectGetWidth(self.view.frame);
    [self.revealSideViewController pushViewController:leftMenuSetting onDirection:PPRevealSideDirectionLeft withOffset:offset animated:YES];
    
}

#pragma mark - notify from search customer for add new customer
-(void)openPopUpAddNewCustomer{
    
    CustomerEditViewController *customerEdit = [[CustomerEditViewController alloc] init];
    MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:customerEdit];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:navController animated:YES completion:nil];
    
}

@end
