//
//  CartItemCell.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/10/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFramework.h"

@interface CartItemCell : MSTableViewCell

@property (strong, nonatomic) UIImageView *badgeImageView;
@property (strong, nonatomic) UILabel *badgeLabel;

- (void)addBadgeQty: (CGFloat)qty;

@end
