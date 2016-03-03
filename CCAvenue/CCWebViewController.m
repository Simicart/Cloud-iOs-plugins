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

@implementation CCWebViewController{
    CCAvenueModel* ccAvenueModel;
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
    [self startLoadingData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self stopLoadingData];
    NSString *string = webView.request.URL.absoluteString;
    if ([string rangeOfString:redirectUrl].location != NSNotFound) {
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];
//        if(order)
//            ccAvenueModel = order;
//        else
            ccAvenueModel = [CCAvenueModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToThankyouPageWithNotification:) name:DidUpdateCCAvenuePayment object:nil];
        [self startLoadingData];
        if (([html rangeOfString:@"Aborted"].location != NSNotFound) ||
            ([html rangeOfString:@"Cancel"].location != NSNotFound)) {
            [ccAvenueModel updatePaymentWithOrder:[order valueForKey:@"_id"] status:@"2"];
        }else if (([html rangeOfString:@"Success"].location != NSNotFound)) {
            [ccAvenueModel updatePaymentWithOrder:[order valueForKey:@"_id"] status:@"1"];
        }else if ([html rangeOfString:@"Fail"].location != NSNotFound || [html rangeOfString:@"Error"].location != NSNotFound) {
            [ccAvenueModel updatePaymentWithOrder:[order valueForKey:@"_id"] status:@"0"];
        }
    }
}

-(void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:[NSString stringWithFormat:@"%@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//    NSLog(@"ccavenue request: %@", request.URL.absoluteString);
//    if([request.URL.absoluteString isEqualToString:self.redirectUrl]){
//        return NO;
//    }
    [self startLoadingData];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
