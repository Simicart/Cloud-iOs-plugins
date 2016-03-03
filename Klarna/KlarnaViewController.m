//Axe created 2016

#import "KlarnaViewController.h"
#import <SimiCartBundle/SCAppDelegate.h>

@interface KlarnaViewController ()
@end

@implementation KlarnaViewController
{
    UIBarButtonItem *backItem;
    UIActivityIndicatorView* simiLoading;
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
}

-(void) viewDidLoad{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [_webView loadRequest:request];
    [self startLoadingData];
}

#pragma Webview Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    [self startLoadingData];
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
