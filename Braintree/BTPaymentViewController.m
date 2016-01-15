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

@interface BTPaymentViewController ()
@end

@implementation BTPaymentViewController{
    SimiBraintreeModel* braintreeModel;
}
@synthesize braintreeClient;

-(void) viewDidLoadBefore{
    self.braintreeClient = [[BTAPIClient alloc] initWithAuthorization:self.clientToken];
    if([self.listBraintreePayments containsObject:@"android_pay"])
        [self.listBraintreePayments removeObject:@"android_pay"];
    if([self.listBraintreePayments containsObject:@"credit_card"])
       [self.listBraintreePayments removeObject:@"credit_card"];
    UITableView* tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.separatorColor = [UIColor clearColor];
    self.view = tableView;
    self.title = SCLocalizedString(@"Braintree");
    [super viewDidLoadBefore];
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
    }else if([identifier isEqualToString:@"paypal"]){
        BTDropInViewController* dropInVC = [[BTDropInViewController alloc] initWithAPIClient:self.braintreeClient];
        dropInVC.delegate = self;
        [self.navigationController pushViewController:dropInVC animated:YES];
    }
    else{
    
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

        }else if([identifier isEqualToString:@"paypal"]){
            cell.textLabel.text = @"Pay with Paypal and Card";
        }
        else{
            
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
    SimiResponder* responder = [noti.userInfo valueForKey:@"responder"];
    if([responder.status isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:BRAINTREESENDNONCETOSERVER]){
            SCThankYouPageViewController* thankyouPage = [SCThankYouPageViewController new];
            thankyouPage.order = self.order;
            [thankyouPage.navigationItem setHidesBackButton:YES];
            [self.navigationController pushViewController:thankyouPage animated:YES];
        }
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

@end
