//  Created by Nguyen Duc Chien on 8/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.


#import "AccountViewController.h"
#import "MSFramework.h"
#import "AppDelegate.h"
#import "ViewController.h"

#import "LoginFormViewController.h"
#import "LockScreenViewController.h"

#import "Account.h"
#import "MagentoAccount.h"
#import "Configuration.h"

#import "UserInfo.h"
#import "JKLLockScreenViewController.h"

@interface AccountViewController ()
@property (strong, nonatomic) UILabel *name, *email;
@end

@implementation AccountViewController
@synthesize name, email;

static AccountViewController *_sharedInstance = nil;

+(AccountViewController*)sharedInstance
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
    
    _sharedInstance=self;
    
    self.view.backgroundColor =[UIColor backgroundColor];

    // Lock screen button
    MSGrayButton *lockBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
    lockBtn.frame = CGRectMake(10, 74-20, 260, 54);
    lockBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [lockBtn setTitle:NSLocalizedString(@"Lock Screen", nil) forState:UIControlStateNormal];
   // [lockBtn setImage:[UIImage imageNamed:@"icon_account_lock.png"] forState:UIControlStateNormal];
    [self.view addSubview:lockBtn];
    [lockBtn addTarget:self action:@selector(lockScreen) forControlEvents:UIControlEventTouchUpInside];
    
    // Login button
    MSGrayButton *logoutBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
    logoutBtn.frame = CGRectMake(10, 138-20, 260, 54);
    logoutBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [logoutBtn setTitle:NSLocalizedString(@"Logout", nil) forState:UIControlStateNormal];
    //[logoutBtn setImage:[UIImage imageNamed:@"icon_account_logout.png"] forState:UIControlStateNormal];
    [logoutBtn setTitleColor:[UIColor barBackgroundColor] forState:UIControlStateNormal];
    [self.view addSubview:logoutBtn];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
}

- (CGSize)reloadContentSize
{
    CGFloat width = 280;
    CGFloat height = 202;
    if (name) {
        Account *account = [Account currentAccount];
        name.text = [account objectForKey:@"name"];
        email.text = [account objectForKey:@"email"];
    }
    self.preferredContentSize = CGSizeMake(width, height);
    return self.preferredContentSize;

}

#pragma mark - Button Action
- (void)lockScreen
{
    JKLLockScreenViewController * lockScreen =[[JKLLockScreenViewController alloc] initWithNibName:@"JKLLockScreenViewController" bundle:nil];
    lockScreen.parrentVC=self;
    [self presentViewController:lockScreen animated:YES completion:nil];
}



- (void)logout
{    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [[Configuration globalConfig] removeObjectForKey:@"session"];
    [[Configuration globalConfig] removeObjectForKey:@"password"];
    
    // Johan: Clear cache when logout
    [[Configuration globalConfig].productCache removeAllObjects];
    [[Configuration globalConfig].productCacheResult removeAllObjects];
    // End
    
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_LOGOUT object:nil];    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        return;
    }

    // Clear Session ID and Password
    [[Configuration globalConfig] removeObjectForKey:@"session"];
    [[Configuration globalConfig] removeObjectForKey:@"password"];

    LoginFormViewController * loginVC = [LoginFormViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    [self.revealSideViewController popViewControllerWithNewCenterController:nav animated:NO];
    
}


@end
