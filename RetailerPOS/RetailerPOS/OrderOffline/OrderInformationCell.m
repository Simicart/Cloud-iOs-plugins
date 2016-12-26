//
//  OrderInformationCell.m
//  RetailerPOS
//
//  Created by mac on 4/26/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "OrderInformationCell.h"
#import "UIView+Helper.h"

@implementation OrderInformationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.groupView.layer.cornerRadius =10.0;
    self.groupView.backgroundColor =[UIColor whiteColor];
    self.backgroundColor =[UIColor groupTableViewBackgroundColor];
    [self.groupView roundCornerswithRadius:5 andShadowOffset:5];    
}

@end
