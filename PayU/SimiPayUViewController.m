//
//  SimiPayUViewController.m
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "SimiPayUViewController.h"

@interface SimiPayUViewController ()

@end

@implementation SimiPayUViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.title = @"PayU";
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn addTarget:self action:@selector(cancelBtnHandle) forControlEvents:(UIControlEventTouchUpInside)];
    [cancelBtn setTitle:@"Cancel" forState:(UIControlStateNormal)];
    [cancelBtn sizeToFit];
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
}

-(void)cancelBtnHandle {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    _webView = [[UIWebView alloc] initWithFrame:CGRectInset(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), 0, 0)];
//    _webView = [[UIWebView alloc]initWithFrame:CGRectInset(self.view.bounds, 0, 64)];
    _webView.delegate = self;
    NSURL *url = [[NSURL alloc]initWithString:[self.stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    [self startLoading];
}

#pragma mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@",request);
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    NSLog(@"string request : %@", stringRequest);
    if ([stringRequest containsString:@"sessionId"]) {
        [self stopLoading];
    }
    if ([stringRequest containsString:@"return"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"SUCCESS") message:SCLocalizedString(@"Thank your for purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }else if ([stringRequest containsString:@"simipayu/index/failure"])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[SCLocalizedString(@"Error") uppercaseString] message:SCLocalizedString(@"Have some errors, please try again") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    return  YES;
}

-(void)startLoading {
    if (!self.loadingView.isAnimating) {
        CGRect frame = self.view.frame;
        self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        [self.loadingView hidesWhenStopped];
        self.loadingView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self.view addSubview:self.loadingView];
        [self.loadingView startAnimating];
        self.view.alpha = 0.5;
    }
}

-(void)stopLoading {
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1;
    [self.loadingView stopAnimating];
    [self.loadingView removeFromSuperview];
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
