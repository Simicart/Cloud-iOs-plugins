//
//  SimiPayUViewController.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUViewController.h"
#import "SimiPayUModel.h"
#import "SimiGlobalVar+PayU.h"
#import <SimiCartBundle/SCThankyouPageViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>

@interface SimiPayUViewController ()

@end

@implementation SimiPayUViewController {
    SimiPayUModel *model;
    NSString *resultUrl;
    SimiViewController *viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    _webView = [[UIWebView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), 0, 0)];
    [self.view addSubview:_webView];
    _webView.delegate = self;
//    [self startLoadingData];
    NSLog(@"order detail : %@", self.order);
    NSDictionary *param = @{
                                @"order_id" : [self.order valueForKey:@"_id"],
                                @"continue_url" : @"http://localhost"
                            };
    if (model == nil) {
        model = [[SimiPayUModel alloc] init];
    }
    [model getDirectLink:param];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidGetPayUDirectLinkConfig" object:nil];
}

- (void)didReceiveNotification:(NSNotification *)noti{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if ([noti.name isEqualToString:@"DidGetPayUDirectLinkConfig"]) {
        SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
        if (![responder.status isEqualToString: @"SUCCESS"]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@, Please try again", responder.message] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        } else {
            if ([model valueForKey:@"errors"] != nil) {
//                NSDictionary *errors = [model valueForKey:@"errors"];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:@"Sorry, currentcy is not supported. Please choose another payment." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                alertView.tag = 1;
                [alertView show];
            } else {
                resultUrl = [model valueForKey:@"url"];
                NSURL *url = [[NSURL alloc]initWithString:[resultUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
                [_webView loadRequest:request];
            }
        }
    }
}



- (void)viewDidAppear:(BOOL)animated
{
//    self.edgesForExtendedLayout = UIRectEdgeBottom;
//    _webView = [[UIWebView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), 0, 0)];
//    [self.view addSubview:_webView];
//    _webView.delegate = self;
}

#pragma mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    if ([stringRequest containsString:@"sessionId"]) {
    }
    if ([stringRequest containsString:@"return"]) {
        SCThankYouPageViewController *thankYouPageViewController = [[SCThankYouPageViewController alloc] init];
        UINavigationController *navi;
        navi = [[UINavigationController alloc]initWithRootViewController:thankYouPageViewController];
        thankYouPageViewController.order = self.order;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _popController = [[UIPopoverController alloc] initWithContentViewController:navi];
            [_popController dismissPopoverAnimated:YES];
            thankYouPageViewController.popOver = _popController;
            _popController.delegate = self;
            navi.navigationBar.tintColor = THEME_COLOR;
            if (SIMI_SYSTEM_IOS >= 8) {
                navi.navigationBar.tintColor = THEME_APP_BACKGROUND_COLOR;
            }
            navi.navigationBar.barTintColor = THEME_COLOR;
            [self.navigationController popToRootViewControllerAnimated:YES];
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            UIViewController *currentViewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
            [_popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentViewController.view permittedArrowDirections:0 animated:YES];
        } else {
            [self.navigationController pushViewController:thankYouPageViewController animated:YES];
        }
    }else if ([stringRequest containsString:@"simipayu/index/failure"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[SCLocalizedString(@"Error") uppercaseString] message:SCLocalizedString(@"Have some errors, please try again") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    return  YES;
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [self startLoadingData];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [self stopLoadingData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
