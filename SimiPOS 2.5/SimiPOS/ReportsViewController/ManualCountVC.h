//
//  ManualCountVCViewController.m
//  SimiPOS
//
//  Created by NGUYEN DUC CHIEN on 2/28/16.
//  Copyright © 2016 MARCUS Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManualCountVCDelegate <NSObject>

@optional

-(void)getTotalManualCount:(float)total;

@end

@interface ManualCountVC : UIViewController

@property(weak,nonatomic) id<ManualCountVCDelegate>delegate;

@end
