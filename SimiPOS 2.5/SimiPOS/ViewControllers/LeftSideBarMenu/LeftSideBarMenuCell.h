//
//  LeftSideBarMenuCell.h
//  SimiPOS
//
//  Created by mac on 3/7/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftSideBarMenuCell : UITableViewCell

@property (strong, nonatomic) NSString * menuKey;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;

-(void)setTitleMenu:(NSString *)title ImageName:(NSString *)imageName MenuKey:(NSString *)menuKey;


@end
