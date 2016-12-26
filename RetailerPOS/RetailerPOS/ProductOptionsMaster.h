//
//  ProductOptionsMaster.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/22/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSBlueButton.h"
#import "ProductOptions.h"
#import "ProductOptionsDetail.h"

@interface ProductOptionsMaster : UITableViewController <UITextFieldDelegate,UITextViewDelegate>
@property (strong, nonatomic) UIButton *doneButtonView;
@property (nonatomic) CGFloat tableWidth;

@property (strong, nonatomic) ProductOptionsDetail *detailControl;
@property (strong, nonatomic) NSArray *masterOptions;

@property (strong, nonatomic) NSIndexPath *currentSelectedPath;

-(void)refreshDoneButton;
-(void)refreshMasterOption:(NSDictionary *)option;
-(void)moveToNextOption;

-(id)selectedValues:(NSDictionary *)option;

-(UIButton *)doneEditButton;
-(IBAction)doneEditOptions:(id)sender;

@end
