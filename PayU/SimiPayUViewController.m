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

@implementation SimiPayUViewController {
    UIBarButtonItem *backItem;
    UIActivityIndicatorView* simiLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPayment:)];
    backButton.title = @"Cancel";
    NSMutableArray* leftBarButtons = [NSMutableArray arrayWithArray:self.navigationController.navigationItem.leftBarButtonItems];
    [leftBarButtons addObjectsFromArray:@[backButton]];
    self.navigationItem.leftBarButtonItems = leftBarButtons;
}

-(void) cancelPayment:(id) sender{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure that you want to cancel the order?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView show];
    alertView.tag = 0;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){
        if(buttonIndex == 0){
            
        }else if(buttonIndex == 1){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CancelOrder" object:nil userInfo:@{@"order_id" : self.orderId}];
            [self.navigationController popToRootViewControllerAnimated:YES];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Thank you" message:@"Your order is cancelled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
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
    [self startLoadingData];
    
}

#pragma mark UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *stringRequest = [NSString stringWithFormat:@"%@",request];
    if ([stringRequest containsString:@"sessionId"]) {
//        [self stopLoading];
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

- (void)startLoadingData{
    if (!simiLoading.isAnimating) {
        CGRect frame = self.view.frame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && self.navigationController) {
            if (frame.size.width > self.navigationController.view.frame.size.width) {
                frame = self.navigationController.view.frame;
            }
        }
        
        simiLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        simiLoading.hidesWhenStopped = YES;
        simiLoading.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        [self.view addSubview:simiLoading];
        self.view.userInteractionEnabled = NO;
        [simiLoading startAnimating];
        self.view.alpha = 0.5;
        
    }
}

- (void)stopLoadingData{
    self.view.userInteractionEnabled = YES;
    self.view.alpha = 1;
    [simiLoading stopAnimating];
    [simiLoading removeFromSuperview];
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
