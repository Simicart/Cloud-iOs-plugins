//
//  ViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/15/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "MarkLayerController.h"
#import "LoginFormViewController.h"
#import "MenuItem.h"
#import "MenuContent.h"
#import "LockScreenViewController.h"

#import "UserStoreSettingVC.h"

@interface ViewController()
@property (strong, nonatomic) MenuItem *productMenu;
@property (strong, nonatomic) UIScrollView *menuView;

- (void)accountLogin;
- (void)accountLogout;
- (void)showLockScreen;
@end

@implementation ViewController

@synthesize controllerClasses;
@synthesize controllers;
@synthesize currentViewController;
@synthesize markLayer;

@synthesize menuItems;
@synthesize currentMenuItem;
@synthesize productMenu;
@synthesize menuView;

@synthesize activeMode;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.176 green:0.224 blue:0.282 alpha:1.000];
	// Do any additional setup after loading the view.
    self.currentMenuItem = -1;
   
    menuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 127, 768)];
    menuView.backgroundColor = self.view.backgroundColor;
    menuView.clipsToBounds = YES;
    
    //chiennd
    menuView.contentSize =CGSizeMake(127, 1000);
    [self.view addSubview:menuView];
    
    //Hien thi menu
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleViewMenu) name:@"globalToggleViewMenu" object:nil];
    
    //Hien thi menu product
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProductMenu) name:@"globalToggleProductMenu" object:nil];
    
    // Add Menu Item
    [self addMenuItem:NSLocalizedString(@"Account", nil) withImage:@"menu_account" controllerClass:@"AccountViewController"];
    
    productMenu = [self addMenuItem:NSLocalizedString(@"Products", nil) withImage:@"menu_products" controllerClass:@"CatalogViewController"];
    
    [self addMenuItem:NSLocalizedString(@"Orders", nil) withImage:@"menu_orders" controllerClass:@"OrdersViewController"];

    //ndchien:
    [self addMenuItem:NSLocalizedString(@"On-hold\nOrders", nil) withImage:@"menu_holded_orderlist" controllerClass:@"HoldOrdersViewController"];
    [self addMenuItem:NSLocalizedString(@"Cash Drawer", nil) withImage:@"cashdrawer" controllerClass:@"CashDrawerViewController"];
    [self addMenuItem:NSLocalizedString(@"Reports", nil) withImage:@"menu_report" controllerClass:@"ReportsViewController"];
    
    [self addMenuItem:NSLocalizedString(@"Customers", nil) withImage:@"menu_customer" controllerClass:@"CustomersViewController"];
    [self addMenuItem:NSLocalizedString(@"Settings", nil) withImage:@"menu_settings" controllerClass:@"SettingsViewController"];
    
    // Select product Menu for current
    [productMenu selectStyle];
    [self didSelectMenuItem:productMenu];
    
    // Lock screen
    self.activeMode = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountLogin) name:@"AccountLoginAfter" object:nil];
    
    // Show Login Form
    LoginFormViewController *loginForm = [LoginFormViewController new];
    [self addChildViewController:loginForm];
    [self.view addSubview:loginForm.view];
    [loginForm didMoveToParentViewController:self];
    
    // Logout Event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountLogout) name:@"AccountLogoutAfter" object:nil];
    //openStoreSetting
}

- (void)showLockScreen
{
    if (self.activeMode) {
        // Show lock screen
        LockScreenViewController *lockScreen = [LockScreenViewController new];
        lockScreen.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:lockScreen animated:YES completion:nil];
        lockScreen.view.superview.frame = CGRectMake(312, 186, 400, 376);
        
        // Inactive
        self.activeMode = NO;
    }
}

- (void)accountLogin
{
    self.activeMode = YES;
    [self openStoreSetting];
}

- (void)accountLogout
{
    self.activeMode = NO;
    [productMenu selectStyle];
    if (self.currentMenuItem == productMenu.view.tag) {
        if (self.currentViewController && self.currentViewController.view.frame.origin.x == 0) {
            return;
        }
        [self toggleViewMenu];
    } else {
        [self didSelectMenuItem:productMenu];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Menu delegate
- (MenuItem *)addMenuItem:(NSString *)itemLabel withImage:(NSString *)imageOrNil controllerClass:(NSString *)controllerClass
{
    if (self.controllerClasses == nil) {
        self.controllerClasses = [[NSMutableArray alloc] init];
        self.controllers = [[NSMutableArray alloc] init];
        self.menuItems = [[NSMutableArray alloc] init];
    }
    NSUInteger itemIdx = [self.menuItems count];
    CGRect menuFrame = CGRectMake(0, itemIdx * 125, 135, 125);
    
    MenuItem *menuItem = [MenuItem new];
    menuItem.view.frame = menuFrame;
    menuItem.view.tag = itemIdx;
    
    menuItem.menuLabelView.text = itemLabel;
    if (imageOrNil != nil) {
        menuItem.menuImageView.image = [UIImage imageNamed:imageOrNil];
        menuItem.menuImageView.highlightedImage = [UIImage imageNamed:[imageOrNil stringByAppendingString:@"_highlight"]];
    }
    
    [self addChildViewController:menuItem];
    [self.menuView addSubview:menuItem.view];
    [menuItem didMoveToParentViewController:self];
    
    [self.controllerClasses addObject:controllerClass];
    [self.menuItems addObject:menuItem];
    [self.controllers addObject:@""];
    
    return menuItem;
}

- (void)didSelectMenuItem:(MenuItem *)menuItem {
    if (self.currentMenuItem == menuItem.view.tag) {
        return;
    }
    NSInteger selectMenuItem = menuItem.view.tag;
    UIViewController <MenuContent> *controller = [self.controllers objectAtIndex:selectMenuItem];
    if ([controller isEqual: @""]) {
        NSString *controllerClass = [self.controllerClasses objectAtIndex:selectMenuItem];
        if ([controllerClass isEqual: @""]) {
            [menuItem clearStyle];
            return;
        }
        Class ctrCls = NSClassFromString(controllerClass);
        controller = [[ctrCls alloc] initMenuView];
        [self.controllers setObject:controller atIndexedSubscript:selectMenuItem];
    }
    if ([controller didSelectedChange]) {
        if (self.currentMenuItem >= 0) {
            MenuItem *selectedMenu = (MenuItem *)[self.menuItems objectAtIndex:self.currentMenuItem];
            [selectedMenu clearStyle];
            UIViewController *currentController = [self.controllers objectAtIndex:self.currentMenuItem];
            [currentController willMoveToParentViewController:nil];
            [currentController.view removeFromSuperview];
            [currentController removeFromParentViewController];
        }
        self.currentMenuItem = selectMenuItem;
        [self addChildViewController:controller];
        [self.view addSubview:controller.view];
        [controller didMoveToParentViewController:self];
        self.currentViewController = controller;
        CGRect frame = controller.view.frame;
        frame.origin.x = 127;
        controller.view.frame = frame;
        [self toggleViewMenu];
    } else {
        [menuItem clearStyle];
    }
}

- (void)toggleViewMenu
{
    if (self.currentViewController == nil) {
        return;
    }
    [UIView beginAnimations:@"Show and Hide Menu" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    
    if (self.currentViewController.view.frame.origin.x == 0) {
        if (self.markLayer == nil) {
            self.markLayer = [[MarkLayerController alloc] init];
            self.markLayer.view.frame = [self.view bounds];
            
            //split line
            UIView *transparentLayer = [[UIView alloc] initWithFrame:CGRectMake(-2, 0, 2, 768)];
            [transparentLayer setBackgroundColor:[UIColor whiteColor]];
            transparentLayer.alpha = 0.1;
            [self.markLayer.view addSubview:transparentLayer];
        }
        [self.currentViewController addChildViewController:self.markLayer];
        [self.currentViewController.view addSubview:self.markLayer.view];
        [self.markLayer didMoveToParentViewController:self.currentViewController];
        
        [self.view bringSubviewToFront:menuView];
        menuView.frame = CGRectMake(0, 0, 127, 768);
        [self.view bringSubviewToFront:self.currentViewController.view];
        self.currentViewController.view.frame = CGRectMake(127, 0, 1024, 768);
    } else {
        menuView.frame = CGRectMake(0, 0, 0, 768);
        self.currentViewController.view.frame = CGRectMake(0, 0, 1024, 768);
        if (self.markLayer.parentViewController != nil) {
            [self.markLayer willMoveToParentViewController:nil];
            [self.markLayer.view removeFromSuperview];
            [self.markLayer removeFromParentViewController];
        }
    }
    
    [UIView commitAnimations];
}

-(void)showProductMenu{

    [productMenu selectStyle];
    [self didSelectMenuItem:productMenu];    
}


#pragma mark - Setting Store & Cash Drawer
- (void)openStoreSetting
{
    UserStoreSettingVC *viewController = [[UserStoreSettingVC alloc] init];
    
    viewController.view.frame =self.view.frame;
    
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

@end
