//
//  ZReportCashInfoCell.h
//  SimiPOS
//
//  Created by mac on 2/26/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZReportCashInfoCellDelegate <NSObject>

@optional
-(void)manualCountEventClick;
-(void)disableScrollViewKeyboardShow;

@end

@interface ZReportCashInfoCell : UITableViewCell<UITextFieldDelegate>

@property(weak, nonatomic) id<ZReportCashInfoCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIWebView *paymentMethodWebView;
@property (weak, nonatomic) IBOutlet UILabel *numberOrderLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordGrandTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *manualCountLabel;
@property (weak, nonatomic) IBOutlet UITextField *manualCountTextField;
@property (weak, nonatomic) IBOutlet UILabel *differenceLabel;

@property (weak, nonatomic) IBOutlet UIButton *btnCount;

-(void)setHideManualCount;
-(void)setShowManualCount;

-(void)setDataWithDict:(NSDictionary*)dict;


#pragma mark - caculate difference
-(void)setDifferenceValue:(float)manualCount;

@end
