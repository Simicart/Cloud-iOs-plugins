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

-(void) didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:DidCancelOrder]){
            SCThankYouPageViewController* thankyouPage = [SCThankYouPageViewController new];
            thankyouPage.order = self.order;
            [thankyouPage.navigationItem setHidesBackButton:YES];
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                [self.navigationController pushViewController:thankyouPage animated:YES];
            else{
                [self.navigationController popToRootViewControllerAnimated:YES];
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
                UINavigationController* nvThankyou = [[UINavigationController alloc] initWithRootViewController:thankyouPage];
                UIPopoverController* tkPopover = [[UIPopoverController alloc] initWithContentViewController:nvThankyou];
                thankyouPage.popOver = tkPopover;
                [tkPopover  presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:viewController.view permittedArrowDirections:0 animated:YES];
            }
        }
    }else{
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:responder.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [self removeObserverForNotification:noti];
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
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidCancelOrder object:nil];
            [self startLoadingData];
            [self.order cancelAnOrder:[self.order valueForKey:@"_id"]];
        }
    }
}


@end
