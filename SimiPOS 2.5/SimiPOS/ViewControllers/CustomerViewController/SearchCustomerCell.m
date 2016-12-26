//
//  SearchCustomerCell.m
//  SimiPOS
//
//  Created by mac on 3/3/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SearchCustomerCell.h"

@implementation SearchCustomerCell


- (void)awakeFromNib {
    // Initialization code
}

-(void)setData:(CustomerInfo *)customer{
    
    self.customerInfo =customer;
    
    self.name.text =customer.customer_name;
    self.email.text=customer.email;
    self.phoneNumber.text=customer.telephone;
    
    if(!customer.telephone || [customer.telephone isEqualToString:@"<null>"]){
        self.phoneNumber.text =@"";
        self.phoneIcon.hidden =YES;
    }else{
        self.phoneNumber.text=[NSString stringWithFormat:@"%@",customer.telephone];
        self.phoneIcon.hidden =NO;
    }
}

-(void)setDataWithDict:(NSDictionary *)dict{
    
    self.name.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    self.email.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"email"]];

    
    if([[dict objectForKey:@"telephone"] isKindOfClass:[NSNull class]]){
        self.phoneNumber.text =@"";
        self.phoneIcon.hidden =YES;
    }else{
        self.phoneNumber.text=[NSString stringWithFormat:@"%@",[dict objectForKey:@"telephone"]];
        self.phoneIcon.hidden =NO;
    }
    
}

@end
