//Axe created 2016

#import "KlarnaViewController.h"
#import <SimiCartBundle/SCAppDelegate.h>

@interface KlarnaViewController ()
@end

@implementation KlarnaViewController
{
    UIBarButtonItem *backItem;
    UIActivityIndicatorView* simiLoading;
    BOOL isShowedAlert;
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
    [self startLoadingData];
    return  YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self stopLoadingData];
    
}

-(void) completePayment{
    [self.navigationController popToRootViewControllerAnimated:YES];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:SCLocalizedString(@"Thank you for your purchase")delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil, nil];
    [alertView show];

}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    [self stopLoadingData];
    NSString* requestURL = [NSString stringWithFormat:@"%@",webView.request.URL.absoluteString];
    if([requestURL rangeOfString:@"klarna/confirmation?klarna_order_id"].location != NSNotFound){
        if(!isShowedAlert){
        [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(completePayment) userInfo:nil repeats:NO];
        isShowedAlert = YES;
        }
    }
}


#pragma mark dealoc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}




@end
