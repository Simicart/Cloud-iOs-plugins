//
//  DefaultPrintViewVCViewController.h
//  SimiPOS
//
//  Created by Trueplus02 on 3/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface DefaultPrintViewVCViewController : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong , nonatomic) Order * order;

- (void)cancelPrint;

#pragma mark - print order
- (void)printOrderAction;

@end
