//
//  SearchCustomerCell.h
//  SimiPOS
//
//  Created by mac on 3/3/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerInfo.h"

@interface SearchCustomerCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (strong, nonatomic) IBOutlet UIImageView *phoneIcon;


@property (strong, nonatomic) CustomerInfo * customerInfo;

-(void)setData:(CustomerInfo *)customer;

-(void)setDataWithDict:(NSDictionary *)dict;

@end
