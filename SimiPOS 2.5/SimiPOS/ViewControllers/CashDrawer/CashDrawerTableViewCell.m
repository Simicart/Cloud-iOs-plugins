//
//  CashDrawerTableViewCell.m
//  SimiPOS
//
//  Created by mac on 2/24/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import "CashDrawerTableViewCell.h"

@implementation CashDrawerTableViewCell

- (void)awakeFromNib {

}


-(void)setData:(NSDictionary*)dict{
    self.timeStampLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"created_time"]];
    self.inLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"cash_in"]];
    self.outLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"cash_out"]];
    self.balanceLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"current_balance"]];
    self.orderIdLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"order_id"]];
    self.cashierLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"cashier"]];    
    self.locationLabel.text = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"location"]] stringByReplacingOccurrencesOfString:@"<null>" withString:@""];
    self.noteLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"comment"]];
    
    [self.locationLabel sizeToFit];
    [self.noteLabel sizeToFit];
    
}

- (IBAction)showDetailButtonClick:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(showContextDetail:)]){
        [self.delegate showContextDetail:self.noteLabel.text];
    }
}


@end
