//Axe created 2016

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SimiResponder.h>
#import <SimiCartBundle/SCThankYouPageViewController.h>

@interface KlarnaViewController : UIViewController<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) SimiOrderModel* order;
@end
