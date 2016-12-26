//
//  CashDrawerTableViewCell.m
//  SimiPOS
//
//  Created by nguyen duc chien on 2/24/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.//

#import "ZReportTableViewCell.h"

@implementation ZReportTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDataWithDict:(NSDictionary*)dict{
    
    if(dict){
        self.paymentMethodLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"payment_name"]];
        self.numberOrderLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"order_count"]];
        self.recordGrandTotalLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"money_formated"]];//money_system
        self.manualCountLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"money_formated"]]; //money_system
        self.differenceLabel.text = @"0"; //[NSString stringWithFormat:@"%@",[dict objectForKey:@""]];
    }
}

@end
