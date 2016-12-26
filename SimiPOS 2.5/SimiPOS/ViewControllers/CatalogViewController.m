//
//  CatalogViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/16/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CatalogViewController.h"
#import "MenuContent.h"

#import "ProductViewController.h"
#import "CartViewController.h"
#import "CheckoutViewController.h"
#import "CartInformation.h"

#import "MSFramework.h"
#import "Configuration.h"
#import "ProductCollection.h"
#import "LeftSideBarMenuVC.h"
#import "CustomerEditViewController.h"

@interface CatalogViewController()
@property (strong, nonatomic) MSNavigationController *productNav;
@property (strong, nonatomic) MSNavigationController *cartNav;
@property (strong, nonatomic) UIViewController *checkoutNav;

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
    
    // Add Sub View
    ProductViewController *productView = [[ProductViewController alloc] initWithNibName:@"ProductViewController" bundle:nil];
    productNav = [[MSNavigationController alloc] initWithRootViewController:productView];
    //productNav.view.frame = CGRectMake(0, 0, 596, 768);
    productNav.view.frame = CGRectMake(0, 0, WINDOW_WIDTH- 427, WINDOW_HEIGHT);
    
    CartViewController *cartView = [[CartViewController alloc] initWithNibName:@"CartViewController" bundle:nil];
    cartNav = [[MSNavigationController alloc] initWithRootViewController:cartView];
    //cartNav.view.frame = CGRectMake(597, 0, 427, 768);
    cartNav.view.frame = CGRectMake(WINDOW_WIDTH - 427, 0, 427, WINDOW_HEIGHT);
    
    cartView.productView = productView;
    
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
    
    // Reload product state after place order success
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProductState) name:@"QuotePlaceOrderSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPopUpAddNewCustomer) name:NOTIFY_ADD_NEW_CUSTOMER object:nil];
}

#pragma mark - Reload product state
- (void)reloadProductState
{
    // Remove option of configurable product
    NSMutableArray *productIds = [NSMutableArray new];
    for (QuoteItem *item in [[Quote sharedQuote] getAllItems]) {
        Product *product = item.product;
        if ([product hasOptions] && [product objectForKey:@"options"]) {
            for (NSDictionary *option in [product objectForKey:@"options"]) {
                if ([[option objectForKey:@"config"] boolValue]) {
                    // Find product on List
                    [productIds addObject:[product getId]];
                    break;
                }
            }
        }
    }
    if ([productIds count]) {
        ProductViewController *productView = (ProductViewController *)productNav.topViewController;
        ProductCollection *productList = productView.productList;
        for (NSString *productId in productIds) {
            for (NSUInteger i = 0; i < [productList getSize]; i++) {
                Product *product = [productList objectAtIndex:i];
                if ([productId isEqualToString:[product getId]]) {
                    [product removeObjectForKey:@"options"];
                    break;
                }
            }
        }
    }

}


#pragma mark - Change page
- (void)goToCheckoutPage
{
    if (checkoutNav == nil) {
        // define checkout page
        checkoutNav = [[CheckoutViewController alloc] init];
        //checkoutNav.view.frame = CGRectMake(1025, 0, 596, 768);
        // Johan
        if(WINDOW_WIDTH > 1024){
            checkoutNav.view.frame = CGRectMake(WINDOW_WIDTH, 0, 800, WINDOW_HEIGHT+20);
        }else{
            checkoutNav.view.frame = CGRectMake(WINDOW_WIDTH, 0, 596, WINDOW_HEIGHT+20);
        }
        // End
        [self addChildViewController:checkoutNav];
        [self.view addSubview:checkoutNav.view];
        [checkoutNav didMoveToParentViewController:self];
    }
    // Animation, Back 597 points
    [UIView beginAnimations:@"GoToPage" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    productNav.view.frame = [self translationFrame:productNav.view.frame withX:-productNav.view.frame.size.width withY:0];
    // reset frame of cartNavigation
    // Johan
    if(WINDOW_WIDTH > 1024){
        [cartNav.view setFrame:CGRectMake(WINDOW_WIDTH -801, 0, WINDOW_WIDTH -801, WINDOW_HEIGHT + 20)];
        
        cartNav.view.frame = [self translationFrame:cartNav.view.frame withX: - (WINDOW_WIDTH -801) withY:0];
        checkoutNav.view.frame = [self translationFrame:checkoutNav.view.frame withX:-801 withY:0];
        
    }else{
        [cartNav.view setFrame:CGRectMake(WINDOW_WIDTH -597, 0, WINDOW_WIDTH -597, WINDOW_HEIGHT + 20)];
        
        cartNav.view.frame = [self translationFrame:cartNav.view.frame withX: - (WINDOW_WIDTH -597) withY:0];
        checkoutNav.view.frame = [self translationFrame:checkoutNav.view.frame withX:-597 withY:0];
        
    }
    // else
    
    CartViewController *cartView = (CartViewController *)cartNav.topViewController;
    [cartView.cartController.view setFrame:CGRectMake(cartNav.view.frame.origin.x, cartNav.view.frame.origin.y, cartNav.view.frame.size.width, cartView.cartController.view.frame.size.height)];
    cartView.totalButton.frame = [self translationFrame:cartView.totalButton.frame withX:0 withY:75];
    cartView.totalLabel.frame = [self translationFrame:cartView.totalLabel.frame withX:0 withY:75];
    cartView.cartController.view.frame = [self resizeFrame:cartView.cartController.view.frame width:0 height:82];
    
    [UIView commitAnimations];
}

- (void)goToShoppingCartPage
{
    //Ravi post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoShoppingCartPage" object:nil];
    //End
    
    // Animation, Add 597 points
    [UIView beginAnimations:@"GoToPage" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    productNav.view.frame = [self translationFrame:productNav.view.frame withX:WINDOW_WIDTH -427 withY:0];
    // reset frame of cartNavigation
    [cartNav.view setFrame:CGRectMake(WINDOW_WIDTH - 427, 0, 427, WINDOW_HEIGHT + 20)];

    // Johan
    if(WINDOW_WIDTH > 1024){
        checkoutNav.view.frame = [self translationFrame:checkoutNav.view.frame withX:801 withY:0];
    }else{
        checkoutNav.view.frame = [self translationFrame:checkoutNav.view.frame withX:597 withY:0];
    }
    // End

    CartViewController *cartView = (CartViewController *)cartNav.topViewController;
    [cartView.cartController.view setFrame:CGRectMake(cartView.cartController.view.frame.origin.x, cartView.cartController.view.frame.origin.y, cartNav.view.frame.size.width, cartView.cartController.view.frame.size.height)];
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