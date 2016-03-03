//Axe created 2016

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/SCThankYouPageViewController.h>
#import <SimiCartBundle/SCPaymentViewController.h>

@interface KlarnaViewController : SCPaymentViewController <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString* url;
@end
