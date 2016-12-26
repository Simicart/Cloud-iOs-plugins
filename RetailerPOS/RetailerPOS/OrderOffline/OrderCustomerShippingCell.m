//
//  OrderCustomerShippingCell.m
//  RetailerPOS
//
//  Created by mac on 4/26/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "OrderCustomerShippingCell.h"
#import "UIView+Helper.h"

@implementation OrderCustomerShippingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.groupView.backgroundColor =[UIColor whiteColor];
    [self.groupView roundCornerswithRadius:5 andShadowOffset:5];
    
}

@end
