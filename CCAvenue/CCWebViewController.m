//
//  CCPOViewController.m
//  CCIntegrationKit
//
//  Created by test on 5/12/14.
//  Copyright (c) 2014 Avenues. All rights reserved.
//

#import "CCWebViewController.h"
#import "CCTool.h"

@interface CCWebViewController ()

@end

@implementation CCWebViewController
{
    CCAvenueModel* avenueModel;
}
@synthesize rsaKey;@synthesize accessCode;@synthesize merchantId;@synthesize orderId;
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
    NSString *encryptedStr = [NSString stringWithFormat:@"merchant_id=%@&order_id=%@&redirect_url=%@&cancel_url=%@&enc_val=%@&access_code=%@",merchantId,orderId,redirectUrl,cancelUrl,encVal,accessCode];
    
    NSData *myRequestData = [NSData dataWithBytes: [encryptedStr UTF8String] length: [encryptedStr length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString: urlAsString]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:urlAsString forHTTPHeaderField:@"Referer"];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: myRequestData];
    
    [_viewWeb loadRequest:request];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidUpdateCCAvenuePayment object:nil];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    NSString *string = webView.request.URL.absoluteString;
    if ([string rangeOfString:@"/ccavResponseHandler.jsp"].location != NSNotFound) {
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
        
        avenueModel = [CCAvenueModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidUpdateCCAvenuePayment object:nil];
        [self startLoadingData];
        if (([html rangeOfString:@"Aborted"].location != NSNotFound) ||
            ([html rangeOfString:@"Cancel"].location != NSNotFound)) {
            [avenueModel updatePaymentWithOrder:orderId status:@"2"];
        }else if (([html rangeOfString:@"Success"].location != NSNotFound)) {
            [avenueModel updatePaymentWithOrder:orderId status:@"1"];
        }else if (([html rangeOfString:@"Fail"].location != NSNotFound)) {
            [avenueModel updatePaymentWithOrder:orderId status:@"0"];
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
        thankyouPage.order = [[SimiOrderModel alloc] initWithDictionary:avenueModel];
        [self.navigationController pushViewController:thankyouPage animated:YES];
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@",[avenueModel objectForKey:@"code" ]] message:[NSString stringWithFormat:@"%@",[avenueModel objectForKey:@"message" ]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [self.navigationController popViewControllerAnimated:NO];
        [alert show];
    }
}

@end
