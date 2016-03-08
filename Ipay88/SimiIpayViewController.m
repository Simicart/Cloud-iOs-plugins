//
//  SimiIpayViewController.m
//  SimiCartPluginFW
//
//  Created by KingRetina on 2/8/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import "SimiIpayViewController.h"
#import "SimiIpayModel.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>

@interface SimiIpayViewController ()

@end

@implementation SimiIpayViewController

@synthesize paymentsdk, payment, order;

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
    [self setToSimiView];
    self.navigationItem.title = SCLocalizedString(self.navigationItem.title);
    paymentsdk = [[Ipay alloc] init];
    paymentsdk.delegate = self;
    IpayPayment *ipay = [[IpayPayment alloc] init];
    [ipay setPaymentId:@""];
    [ipay setMerchantKey:[payment valueForKey:@"merchant_key"]];
    [ipay setMerchantCode:[payment valueForKey:@"merchant_code"]];
    [ipay setBackendPostURL:[payment valueForKey:@"backend_post_url"]];
    [ipay setRefNo:[order valueForKey:@"invoice_number"]];
    [ipay setCurrency:[order valueForKey:@"store_currency_code"]];
    [ipay setProdDesc:[order valueForKey:@"product_des"]];
    NSDictionary *customer = [order objectForKey:@"customer"];
    [ipay setUserName:[customer valueForKey:@"customer_name"]];
    [ipay setUserEmail:[customer valueForKey:@"customer_email"]];
    [ipay setUserContact:[customer valueForKey:@"contact"]];
    [ipay setRemark:@"Success"];
    [ipay setLang:@"ISO-8859-1"];
    
//    [ipay setCountry:[order valueForKey:@"country_id"]];
    [ipay setCountry:[[[order objectForKey:@"billing_address"] valueForKey:@"country"] valueForKey:@"code"]];
    [ipay setAmount:[order valueForKey:@"grand_total"]];
    if([[payment valueForKey:@"sand_box"] isEqualToString:@"1"]){
        [ipay setAmount:@"1.00"];
        [ipay setCurrency:@"MYR"];
        [ipay setCountry:@"MY"];
    }
    NSLog(@"ipay : %@", ipay);
    UIView *paymentView = [paymentsdk checkout:ipay];
    [self.view addSubview:paymentView];
    [self setContentSizeForViewInPopover:CGSizeMake(3*SCREEN_WIDTH/4, 3*SCREEN_HEIGHT/4)];
}

- (void)didUpdatePayment:(NSNotification *)noti{
    SimiResponder *responder = [noti.userInfo valueForKey:@"responder"];
    if ([responder.status isEqualToString:@"SUCCESS"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:SCLocalizedString(@"Thank you for your purchase") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(responder.status) message:responder.responseMessage delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        [alertView show];
    }
    [self stopLoadingData];
    [self removeObserverForNotification:noti];
}

- (void)updateIpayCheckoutPayment: (NSMutableDictionary *) params
{
    SimiIpayModel *ipayCheckoutModel = [[SimiIpayModel alloc]init];
    [ipayCheckoutModel updateIpayOrderWithParams:params];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToThankyouPageWithNotification:) name:@"DidUpdateIpayPayment" object:ipayCheckoutModel];
    [self startLoadingData];
}

- (void)cancelIpayCheckoutPayment: (NSMutableDictionary *) params
{
    SimiIpayModel *ipayCheckoutModel = [[SimiIpayModel alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveToThankyouPageWithNotification:) name:@"DidUpdateIpayPayment" object:ipayCheckoutModel];
    [ipayCheckoutModel updateIpayOrderWithParams:params];
    [self startLoadingData];
}

- (void)didCancelPayment:(NSNotification *)noti{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"FAIL") message:SCLocalizedString(@"Your order has been canceled") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
//    [alertView show];
    [self stopLoadingData];
//    [self.navigationController popToRootViewControllerAnimated:YES];
//    [self moveToThankyouPageWithNotification:noti];
    [self removeObserverForNotification:noti];
}

- (void)paymentSuccess:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withAuthCode:(NSString *)authCode{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transId forKey:@"payment_id"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"order_id"];
    [params setValue:@"1" forKey:@"status"];
    [self updateIpayCheckoutPayment:params];
}

- (void)paymentFailed:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transId forKey:@"payment_id"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"order_id"];
    [params setValue:@"0" forKey:@"status"];
    [self cancelIpayCheckoutPayment:params];
}

- (void)paymentCancelled:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc{
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setValue:transId forKey:@"payment_id"];
    [params setValue:[order valueForKey:@"invoice_number"] forKey:@"order_id"];
    [params setValue:@"0" forKey:@"status"];
    [self cancelIpayCheckoutPayment:params];
}

- (void)requerySuccess:(NSString *)refNo withMerchantCode:(NSString *)merchantCode withAmount:(NSString *)amount withResult:(NSString *)result{

}

- (void)requeryFailed:(NSString *)refNo withMerchantCode:(NSString *)merchantCode withAmount:(NSString *)amount withErrDesc:(NSString *)errDesc{

}


@end
