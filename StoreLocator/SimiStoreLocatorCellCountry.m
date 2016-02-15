//
//  SimiStoreLocatorCellCountry.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/9/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorCellCountry.h"

@implementation SimiStoreLocatorCellCountry
@synthesize lblCellContent, simiAddressModel;

- (void)awakeFromNib
{
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.lblCellContent = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, CGRectGetWidth(self.frame), 44)];
        [self addSubview:self.lblCellContent];
        [self setBackgroundColor:[UIColor whiteColor]];
    }
    return self;
}
@end
