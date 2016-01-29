//
//  KlarnaViewController.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/14/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "KlarnaViewController.h"

@interface KlarnaViewController ()
@end

@implementation KlarnaViewController

-(void)viewDidLoadBefore
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [super viewDidLoadBefore];
}

- (void)viewDidAppear:(BOOL)animated
{
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [_webView loadRequest:request]; 
    [super viewDidAppear:animated];
}

- (void)didReceiveNotification:(NSNotification *)noti
{
    
}

#pragma Webview Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self startLoadingData];
    NSLog(@"%@", [NSString stringWithFormat:@"%@",request]);
    NSString* requestURL = [NSString stringWithFormat:@"%@",[request mainDocumentURL]];
    if([requestURL rangeOfString:@"klarna/confirmation?klarna_order_id"].location != NSNotFound){
        [self stopLoadingData];
        [self.navigationController popToRootViewControllerAnimated:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Your order is completed" delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return  YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoadingData];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoadingData];
}


#pragma mark dealoc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
