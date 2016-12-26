//
//  MagentoPrintViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 4/22/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface MagentoPrintViewController : UIViewController <UIPrintInteractionControllerDelegate>
@property (strong, nonatomic) Order *order;

- (void)cancelPrint;

#pragma mark - load order detail view
- (void)loadOrderDetailView;
- (void)loadOrderDetailThread;

#pragma mark - print order
- (void)printOrderAction;
@end
