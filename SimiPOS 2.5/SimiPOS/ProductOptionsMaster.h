//
//  ProductOptionsMaster.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/22/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSBlueButton.h"
#import "ProductOptions.h"
#import "ProductOptionsDetail.h"

@interface ProductOptionsMaster : UITableViewController <UITextFieldDelegate>
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
