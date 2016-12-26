//
//  CashDrawerTableViewCell.m
//  RetailerPOS
//
//  Created by nguyen duc chien on 2/24/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.//

#import "XReportTableViewCell.h"

@implementation XReportTableViewCell

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

    }
}

@end
