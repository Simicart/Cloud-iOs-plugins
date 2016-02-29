//
//  CCAvenue.m
//  SimiCartPluginFW
//
//  Created by Axe on 1/20/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "CCAvenue.h"
#import <SimiCartBundle/SCAppDelegate.h>

@implementation CCAvenue
{
    SimiViewController* currentVC;
    CCAvenueModel* ccAvenueModel;
    SimiOrderModel* order;
//    NSString* rsaKey, *accessCode, *merchantID;
}
-(instancetype) init{
    if(self == [super init]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidPlaceOrderAfter object:nil];
    }
    return self;
}

-(void) didReceiveNotification:(NSNotification *)noti{
    SimiResponder* responder = [noti.userInfo objectForKey:@"responder"];
    [currentVC stopLoadingData];
    if([[responder.status uppercaseString] isEqualToString:@"SUCCESS"]){
        if([noti.name isEqualToString:DidPlaceOrderAfter]){
            if([[[noti.userInfo valueForKey:@"payment"] valueForKey:@"method_code"] isEqualToString:@"ccavenue"]){
                order = [noti.userInfo objectForKey:@"data"];
                currentVC = [noti.userInfo objectForKey:@"controller"];
                currentVC.isDiscontinue = YES;
                ccAvenueModel = [CCAvenueModel new];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:DidGetRSACCAvenue object:ccAvenueModel];
                [ccAvenueModel getRSAForOrder:[order valueForKey:@"_id"]];
                [currentVC startLoadingData];                
            }
            
        }else if([noti.name isEqualToString:DidGetRSACCAvenue]){
            [self removeObserverForNotification:noti];
            if(![ccAvenueModel objectForKey:@"errors"]){
                CCWebViewController* ccWebViewController = [CCWebViewController new];
                ccWebViewController.rsaKey = [ccAvenueModel valueForKey:@"rsa_key"];
                ccWebViewController.accessCode = [ccAvenueModel valueForKey:@"access_code"];
                ccWebViewController.merchantId = [ccAvenueModel valueForKey:@"merchant_id"];
                ccWebViewController.amount = [order valueForKey:@"grand_total"];
                ccWebViewController.currency = [[SimiGlobalVar sharedInstance] currencyCode];
                ccWebViewController.order = order;
                ccWebViewController.redirectUrl = [ccAvenueModel valueForKey:@"url"];
                ccWebViewController.cancelUrl = [ccAvenueModel valueForKey:@"url"];
                [currentVC.navigationController pushViewController:ccWebViewController animated:YES];
            }else{
                NSDictionary* errors = [ccAvenueModel objectForKey:@"errors"];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[errors valueForKey:@"code"] message:[errors valueForKey:@"message"] delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil, nil];
                UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
                UIViewController *viewController = [[(UINavigationController *)currentVC viewControllers] lastObject];
                [viewController.navigationController popToRootViewControllerAnimated:YES];
                [alert show];
            }
        }
    }else{
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:responder.status message:responder.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end
