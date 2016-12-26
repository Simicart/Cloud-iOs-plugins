//
//  LeftSideBarMenuCell.m
//  SimiPOS
//
//  Created by mac on 3/7/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "LeftSideBarMenuCell.h"

@implementation LeftSideBarMenuCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setTitleMenu:(NSString *)title ImageName:(NSString *)imageName MenuKey:(NSString*) menuKey{
    self.menuKey = menuKey;
    self.titleLabel.text =title;
    self.avatarImage.image =[UIImage imageNamed:imageName];
}


@end
