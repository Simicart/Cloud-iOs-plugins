//
//  OrderNoteViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 4/27/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "QuoteNoteViewController.h"
#import "OrderEditViewController.h"
#import "Order.h"

@interface OrderNoteViewController : QuoteNoteViewController
@property (strong, nonatomic) Order *order;
@property (strong, nonatomic) OrderEditViewController *editViewController;
@end
