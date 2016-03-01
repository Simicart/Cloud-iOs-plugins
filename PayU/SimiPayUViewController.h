//
//  SimiPayUViewController.h
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import "SimiPayUViewController.h"
#import <SimiCartBundle/SimiOrderModel.h>

@interface SimiPayUViewController : UIViewController<UIWebViewDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) SimiOrderModel* order;
@property (strong, nonatomic) UIPopoverController * popController;
@end
