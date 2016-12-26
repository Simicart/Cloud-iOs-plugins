//
//  ProductOptionsDetail.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/22/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSBlueButton.h"
#import "ProductOptions.h"
#import "ProductOptionsMaster.h"

@interface ProductOptionsDetail : UITableViewController
@property (strong, nonatomic) ProductOptions *optionViewController;
@property (strong, nonatomic) ProductOptionsMaster *masterControl;

@property (strong, nonatomic) NSDictionary *detailOptions;
@property (nonatomic) BOOL hasOptionsLabel;

- (IBAction)changeDatePicker:(id)sender;

-(BOOL)hasSelectedOption;
-(BOOL)optionIsSelected:(NSDictionary *)option;

-(UIButton *)doneEditButton;
-(IBAction)doneEditOptions:(id)sender;

- (NSDictionary *)productOptionsValue;

@end
