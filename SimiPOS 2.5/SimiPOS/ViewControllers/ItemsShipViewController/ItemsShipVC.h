//
//  XReportVC.h
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 2/25/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "OrderEditViewController.h"

@interface ItemsShipVC : UIViewController

@property (strong, nonatomic) OrderEditViewController * parrentView;
@property (strong, nonatomic) Order * order;


@end
