//
//  PayPalHereSDKViewController.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 5/30/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ViewController.h"
#import "PaymentFormAbstract.h"
#import <PayPalHereSDK/PayPalHereSDK.h>

@interface PayPalHereSDKViewController : PaymentFormAbstract<PPHLoggingDelegate,UIWebViewDelegate,PPHTransactionManagerDelegate,PPHTransactionControllerDelegate,PPHSignatureViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>

@end
