//
//  AppDelegate.m
//  RetailerPOS
//
//  Edit by Nguyen Duc Chien on 7/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import "AppDelegate.h"
#import "Paypalhere.h"
#import "LoginFormViewController.h"
#import "LeftSideBarMenuVC.h"
#import "JKLLockScreenViewController.h"

#import "LoginOfflineViewController.h"

@implementation AppDelegate

NSTimer *_watchDogTimer;

static AppDelegate *_sharedInstance = nil;

+(AppDelegate*)sharedInstance
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


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _sharedInstance =self;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Setup & Create Database with CoreData
    [self createDatabase];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //LoginFormViewController * loginVC = [LoginFormViewController sharedInstance];
    LoginOfflineViewController * loginVC = [LoginOfflineViewController sharedInstance];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nav.restorationIdentifier = @"MainNav";
    self.revealSideViewController = [[PPRevealSideViewController alloc] initWithRootViewController:nav];
    //self.revealSideViewController.delegate=self;
    self.revealSideViewController.restorationIdentifier =@"PPReveal";
    
    self.revealSideViewController.options = PPRevealSideOptionsBounceAnimations|PPRevealSideOptionsResizeSideView;
    
    
    self.window.rootViewController = self.revealSideViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openRevealSideMenuLeft) name:NOTIFY_SHOW_LEFT_SIDE_BAR_MENU object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLoginForm) name:NOTIFY_LOGOUT object:nil];
    
    NSNumber * manualPrint = [[NSUserDefaults standardUserDefaults] objectForKey:@"manual_print"];
    if(!manualPrint){
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:2] forKey:@"manual_print"];
    }
    
    //Kiem tra thoi gian & tu dong lock screen app
    [self setLockScreenTimeOutDefault];
    
    [self showLockScreenTimer];
    
    [self setDefaultSettingTheFirstTime];

    
    //NSString* uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

    //DLog(@"UUID:%@",uuid);
    
   // [self registerPushNotifyWithOptions:launchOptions];
    
    return YES;
}

-(void)registerPushNotifyWithOptions:(NSDictionary *)launchOptions{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotif) {
        DLog(@"remoteNotify:%@",remoteNotif);
    }
}

#pragma mark - Config Pushnotify
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSLog(@"deviceToken : %@", deviceToken);
    
    //Register PushNotification Succesfully
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];

    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSLog(@"************** Info ****************");
    NSLog(@"deviceName:%@",deviceName);
    NSLog(@"deviceVersion:%@",deviceVersion);
    NSLog(@"systemName:%@",systemName);
    NSLog(@"UUIDString:%@",deviceId);
    NSLog(@"deviceToken:%@",token);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
}


-(void)openRevealSideMenuLeft{
    
    [self.revealSideViewController preloadViewController:[LeftSideBarMenuVC sharedInstance] forSide:PPRevealSideDirectionLeft];
    self.revealSideViewController.panInteractionsWhenOpened = PPRevealSideInteractionNavigationBar;
    CGFloat offset =CGRectGetWidth([[UIScreen mainScreen] bounds]);
    [self.revealSideViewController pushOldViewControllerOnDirection:PPRevealSideDirectionLeft withOffset:offset animated:YES];
    
}

-(void)openLoginForm{
   
    //LoginFormViewController * loginVC = [LoginFormViewController sharedInstance];
    LoginOfflineViewController * loginVC = [LoginOfflineViewController sharedInstance];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.revealSideViewController popViewControllerWithNewCenterController:nav animated:YES];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url host] rangeOfString:@"takePayment"].location == 0) {
        // Paypal here call
        [[Paypalhere sharedModel] processPayment:url];
    }
    return YES;
}

#pragma mark -Setup & Create Database with CoreData
-(void)createDatabase{
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"MagentoStore.sqlite"];
}

-(void)setLockScreenTimeOutDefault{
    NSNumber * timeOut = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_GENERAL_TIMEOUT];
    if(!timeOut){
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:4] forKey:KEY_GENERAL_TIMEOUT];
    }
}

#pragma mark - Kiem tra thoi gian & lock screen app
- (void)showLockScreenTimer
{
    if (_watchDogTimer) {
        [_watchDogTimer invalidate];
    }
    
    NSUInteger timeout = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_GENERAL_TIMEOUT] integerValue];
    
    
    
    if (timeout == 4) { // never
        _watchDogTimer = nil;
    } else {
        switch (timeout) {
            case 0:
                timeout = 2*60;
                break;
                
            case 1:
                timeout = 5*60;
                break;
                
            case 2:
                timeout = 10*60;
                break;
                
            case 3:
                timeout = 15*60;
                break;
                
            default:
                timeout = 9999;
                break;
        }
        
        // DLog(@"timeout : %d",timeout);
        
        _watchDogTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(showLockScreen) userInfo:nil repeats:YES];
    }
}

-(void)showLockScreen{
    
    DLog(@"auto lock screen");
    JKLLockScreenViewController * lockScreen =[[JKLLockScreenViewController alloc] initWithNibName:@"JKLLockScreenViewController" bundle:nil];
    lockScreen.parrentVC=self.revealSideViewController.rootViewController;
    [self.revealSideViewController.rootViewController presentViewController:lockScreen animated:NO completion:nil];
}

#pragma mark - init & Config setting the first time
-(void)setDefaultSettingTheFirstTime{
    
    bool setConfig = BoolValue(KEY_LOAD_APP_FIRST_TIME);
    if(!setConfig){
        SetBoolValue(YES, KEY_LOAD_APP_FIRST_TIME);
        
        //TODO: the first time
        SetBoolValue(YES, KEY_CREATE_SHIPMENT);
        
        SetBoolValue(NO, KEY_CHECK_USE_TRY_DEMO);
    }
}

@end
