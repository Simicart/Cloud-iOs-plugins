//
//  CCPOViewController.m
//  CCIntegrationKit
//
//  Created by test on 5/12/14.
//  Copyright (c) 2014 Avenues. All rights reserved.
//

#import "CCWebViewController.h"
#import "CCTool.h"
#import <SimiCartBundle/SCAppDelegate.h>

@interface CCWebViewController ()

@end

@implementation CCWebViewController
{
    CCAvenueModel* avenueModel;
    UIBarButtonItem *backItem;
    UIActivityIndicatorView* simiLoading;
}
@synthesize rsaKey;@synthesize accessCode;@synthesize merchantId;@synthesize order;
@synthesize amount;@synthesize currency;@synthesize redirectUrl;@synthesize cancelUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _viewWeb = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.view = _viewWeb;
    self.title = SCLocalizedString(@"CCAvenue Payment");
    //Axe added 251215
    [_viewWeb setContentMode:UIViewContentModeScaleAspectFill];
    _viewWeb.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    //
    _viewWeb.delegate = self;
    
    rsaKey = [rsaKey stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    rsaKey = [NSString stringWithFormat:@"-----BEGIN PUBLIC KEY-----\n%@\n-----END PUBLIC KEY-----\n",rsaKey];
    NSLog(@"%@",rsaKey);
    
    //Encrypting Card Details
    NSString *myRequestString = [NSString stringWithFormat:@"amount=%@&currency=%@",amount,currency];
    CCTool *ccTool = [[CCTool alloc] init];
    NSString *encVal = [ccTool encryptRSA:myRequestString key:rsaKey];
    encVal = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (CFStringRef)encVal,
                                                                        NULL,
                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                        kCFStringEncodingUTF8 ));
    
    //Preparing for a webview call
    NSString *urlAsString = [NSString stringWithFormat:@"https://secure.ccavenue.com/transaction/initTrans"];
    NSString *encryptedStr = [NSString stringWithFormat:@"merchant_id=%@&order_id=%@&redirect_url=%@&cancel_url=%@&enc_val=%@&access_code=%@",merchantId,[order valueForKey:@"_id"],redirectUrl,cancelUrl,encVal,accessCode];
    
    NSData *myRequestData = [NSData dataWithBytes: [encryptedStr UTF8String] length: [encryptedStr length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlAsString]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:urlAsString forHTTPHeaderField:@"Referer"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: myRequestData];
    
    [_viewWeb loadRequest:request];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidUpdateCCAvenuePayment object:nil];
    
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


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    NSString *string = webView.request.URL.absoluteString;
    if ([string rangeOfString:@"secure.ccavenue.com/transaction"].location != NSNotFound) {
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        if(!avenueModel)
            avenueModel = [CCAvenueModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidUpdateCCAvenuePayment object:nil];
        [self startLoadingData];
        if (([html rangeOfString:@"Aborted"].location != NSNotFound) ||
            ([html rangeOfString:@"Cancel"].location != NSNotFound)) {
            [avenueModel updatePaymentWithOrder:[order valueForKey:@"_id"] status:@"2"];
        }else if (([html rangeOfString:@"Success"].location != NSNotFound)) {
            [avenueModel updatePaymentWithOrder:[order valueForKey:@"_id"] status:@"1"];
        }else if (([html rangeOfString:@"Fail"].location != NSNotFound)) {
            [avenueModel updatePaymentWithOrder:[order valueForKey:@"_id"] status:@"0"];
        }
    }
}

//-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [self startLoadingData];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) didReceiveNotification:(NSNotification *)noti{
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    [self removeObserverForNotification:noti];
    if([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]){
        //delete quote
        [[SimiGlobalVar sharedInstance] setQuoteId:nil];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([userDefaults valueForKey:@"quoteId"]) {
            [userDefaults setValue:@"" forKey:@"quoteId"];
            [userDefaults synchronize];
        }
        SCThankYouPageViewController* thankyouPage = [[SCThankYouPageViewController alloc] init];
        if([noti.name isEqualToString:DidUpdateCCAvenuePayment]){
            thankyouPage.order = [[SimiOrderModel alloc] initWithDictionary:avenueModel];
        }else{
            thankyouPage.order = order;
        }
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            [self.navigationController pushViewController:thankyouPage animated:YES];
        else{
            UINavigationController* nvThankyou = [[UINavigationController alloc] initWithRootViewController:thankyouPage];
            UIPopoverController* tkPopover = [[UIPopoverController alloc] initWithContentViewController:nvThankyou];
            thankyouPage.popOver = tkPopover;
            [self.navigationController popToRootViewControllerAnimated:YES];
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
            UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
            [tkPopover presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:viewController.view permittedArrowDirections:0 animated:YES];
            
        }
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[avenueModel objectForKey:@"code" ]] message:[NSString stringWithFormat:@"%@",[avenueModel objectForKey:@"message" ]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.navigationController popViewControllerAnimated:NO];
        [alert show];
    }
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

//UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 0){
        if(buttonIndex == 0){
            
        }else if(buttonIndex == 1){
            if(!avenueModel)
                avenueModel = [CCAvenueModel new];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidCancelOrder object:nil];
            [self startLoadingData];
            [order cancelAnOrder:[order valueForKey:@"_id"]];
        }
    }
}


@end
