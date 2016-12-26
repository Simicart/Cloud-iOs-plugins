//
//  CashDrawerTableViewCell.h
//  RetailerPOS
//
//  Created by mac on 2/24/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CashDrawerTableViewCellDelegate <NSObject>

@optional
-(void)showContextDetail:(NSString *)context;

@end

@interface CashDrawerTableViewCell : UITableViewCell

@property (weak, nonatomic) id<CashDrawerTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *inLabel;
@property (weak, nonatomic) IBOutlet UILabel *outLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashierLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

-(void)setData:(NSDictionary*)dict;

@end
