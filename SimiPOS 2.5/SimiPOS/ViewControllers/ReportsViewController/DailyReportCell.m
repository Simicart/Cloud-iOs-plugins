//
//  DailyReportCell.m
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 2/26/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import "DailyReportCell.h"

@implementation DailyReportCell

- (void)awakeFromNib {
    // Initialization code
    
}

-(void)setData:(NSDictionary *)dict{
    
    self.incrementId.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"increment_id"]];
    self.cashierName.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"cashier_name"]];
    self.storeName.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"store_name"]];
    self.billingName.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"billing_name"]];
    self.grandTotal.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"grand_total"]];
    self.createdAt.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"created_at"]];
    self.status.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"status"]];
    self.cashDrawer.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"cash_drawer"]];
    
}

@end
