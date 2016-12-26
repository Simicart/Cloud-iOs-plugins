//
//  SynchronizationCell.h
//  RetailerPOS
//
//  Created by mac on 4/13/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBCircularProgressBarView.h"
#import "APIManager.h"

@interface SynchronizationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *paymentProgressBar;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *customerProgressBar;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *categoriesProgressBar;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *productProgressBar;
@property (weak, nonatomic) IBOutlet MBCircularProgressBarView *shippingProgressBar;

@property (weak, nonatomic) IBOutlet UITextView *logDetailTextView;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *showLogButton;

-(void)synchronizationAll;

@end
