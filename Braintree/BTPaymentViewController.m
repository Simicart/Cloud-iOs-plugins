//
//  BTPaymentViewController.m
//  SimiCartPluginFW
//
//  Created by Axe on 12/8/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//
@import PassKit;
#import "BraintreeApplePay.h"
#import "BTPaymentViewController.h"
#import "BraintreeCard.h"
#import "BraintreePayPal.h"
#import "SimiBraintreeModel.h"
#import <SimiCartBundle/SCThankyouPageViewController.h>
#import <SimiCartBundle/SCAppDelegate.h>


@interface BTPaymentViewController ()
@end

@implementation BTPaymentViewController{
    SimiBraintreeModel* braintreeModel;
    UIBarButtonItem *backItem;
    UIActivityIndicatorView* simiLoading;
}
@synthesize braintreeClient;



-(void) viewDidLoad{
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:self.clientToken];
    if([self.listBraintreePayments containsObject:@"android_pay"])
        [self.listBraintreePayments removeObject:@"android_pay"];
    if([self.listBraintreePayments containsObject:@"credit_card"])
        [self.listBraintreePayments removeObject:@"credit_card"];
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    tableView.delegate = self;
    tableView.dataSource = self;
    if (SIMI_SYSTEM_IOS >= 9) {
        tableView.cellLayoutMarginsFollowReadableWidth = NO;
    }
    
    //    tableView.separatorColor = [UIColor clearColor];
    self.view = tableView;
    self.title = SCLocalizedString(@"Braintree");
    
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


#pragma mark TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = [self.listBraintreePayments objectAtIndex:indexPath.row];
    if([identifier isEqualToString:@"apple_pay"]){
        PKPaymentRequest *paymentRequest = [self paymentRequest];
        PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        vc.delegate = self;
        if(vc)
            [self presentViewController:vc animated:YES completion:nil];
    }else if([identifier isEqualToString:@"mastercard"]){
        BTDropInViewController* dropInVC = [[BTDropInViewController alloc] initWithAPIClient:self.braintreeClient];
        dropInVC.delegate = self;
        [self.navigationController pushViewController:dropInVC animated:YES];
    }
    else {
    
    }
}
- (PKPaymentRequest *)paymentRequest {
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.merchantIdentifier = self.appleMerchant;
    paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    NSLog(@"countryCode %@, currencyCode %@",[[SimiGlobalVar sharedInstance] countryCode],[[SimiGlobalVar sharedInstance] currencyCode]);
    paymentRequest.countryCode = @"US";
    paymentRequest.currencyCode = [[SimiGlobalVar sharedInstance] currencyCode];
    
    NSDecimalNumber* subTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self.order valueForKey:@"subtotal"]]];
    NSDecimalNumber* grandTotal = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@",[self.order valueForKey:@"grand_total"]]];
    paymentRequest.paymentSummaryItems =
    @[
      [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subTotal],
      [PKPaymentSummaryItem summaryItemWithLabel:@"Grand Total" amount:grandTotal],
      ];
    return paymentRequest;
}
#pragma mark TableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section_{
    return self.listBraintreePayments.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = [self.listBraintreePayments objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if([identifier isEqualToString:@"apple_pay"]){
            cell.textLabel.text = @"Pay with Apple Pay";

        }else if([identifier isEqualToString:@"mastercard"]){
            cell.textLabel.text = @"Pay with Paypal and Card";
        }
        else {
            cell.textLabel.text = identifier;
        }
    }
//    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel* lblHeader = [UILabel new];
    lblHeader.text = SCLocalizedString(@"Braintree");
    lblHeader.backgroundColor = [UIColor blackColor];
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    lblHeader.font = [UIFont fontWithName:@"Helvetica-Bold" size:30];
    return lblHeader;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void) didTapApplePay{
    PKPaymentRequest *paymentRequest = [self paymentRequest];
    PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    vc.delegate = self;
    if(vc)
        [self presentViewController:vc animated:YES completion:nil];
}
- (void)userDidCancelPayment {
        [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {

    // Example: Tokenize the Apple Pay payment
    BTApplePayClient *applePayClient = [[BTApplePayClient alloc]
                                        initWithAPIClient:self.braintreeClient];
    [applePayClient tokenizeApplePayPayment:payment
                                 completion:^(BTApplePayCardNonce *tokenizedApplePayPayment,
                                              NSError *error) {
                                     if (tokenizedApplePayPayment) {
                                         // On success, send nonce to your server for processing.
                                         // If applicable, address information is accessible in `payment`.
                                         NSLog(@"nonce = %@", tokenizedApplePayPayment.nonce);
                                         [self postNonceToServer:tokenizedApplePayPayment.nonce];
                                         // Then indicate success or failure via the completion callback, e.g.
                                         completion(PKPaymentAuthorizationStatusSuccess);
                                     } else {
                                         // Tokenization failed. Check `error` for the cause of the failure.

                                         // Indicate failure via the completion callback:
                                         completion(PKPaymentAuthorizationStatusFailure);
                                     }
                                 }];
}


// Be sure to implement -paymentAuthorizationViewControllerDidFinish:
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    if(!braintreeModel)
        braintreeModel = [SimiBraintreeModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:BRAINTREESENDNONCETOSERVER object:braintreeModel];
    [self startLoadingData];
    [braintreeModel sendNonceToServer:paymentMethodNonce andOrderID:[self.order valueForKey:@"_id"]];
}

-(void) didReceiveNotification:(NSNotification *)noti{
    [self stopLoadingData];
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:BRAINTREESENDNONCETOSERVER] || [noti.name isEqualToString:DidCancelOrder]){
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
                UIPopoverController* tkPoppver = [[UIPopoverController alloc] initWithContentViewController:nvThankyou];
                thankyouPage.popOver = tkPoppver;
                
                [tkPoppver presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:viewController.view permittedArrowDirections:0 animated:YES];
            }
        }
    }else{
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"Error") message:responder.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alertView show];
    }
    [self removeObserverForNotification:noti];
}

#pragma mark - BTViewControllerPresentingDelegate

// Required
- (void)paymentDriver:(id)paymentDriver
requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Required
- (void)paymentDriver:(id)paymentDriver
requestsDismissalOfViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

#pragma mark - BTAppSwitchDelegate

// Optional - display and hide loading indicator UI
- (void)appSwitcherWillPerformAppSwitch:(id)appSwitcher {
    [self showLoadingUI];
    
    // You may also want to subscribe to UIApplicationDidBecomeActiveNotification
    // to dismiss the UI when a customer manually switches back to your app since
    // the payment button completion block will not be invoked in that case (e.g.
    // customer switches back via iOS Task Manager)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoadingUI:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)appSwitcherWillProcessPaymentInfo:(id)appSwitcher {
    [self hideLoadingUI:nil];
}

- (void)appSwitcher:(id)appSwitcher didPerformSwitchToTarget:(BTAppSwitchTarget)target{
    
}


#pragma mark - Private methods

- (void)showLoadingUI {
    [self startLoadingData];
}

- (void)hideLoadingUI:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [self stopLoadingData];
}

#pragma mark PTDropInViewControllerDelegate
- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithTokenization:(BTPaymentMethodNonce *)paymentMethodNonce{
    if(paymentMethodNonce.nonce){
        [self postNonceToServer:paymentMethodNonce.nonce];
    }
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController{
    NSLog(@"DIDCANCEL");
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
