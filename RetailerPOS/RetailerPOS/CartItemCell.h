//
//  CartItemCell.h
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/10/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFramework.h"

@interface CartItemCell : MSTableViewCell

@property (strong, nonatomic) UIImageView *badgeImageView;
@property (strong, nonatomic) UILabel *badgeLabel;

- (void)addBadgeQty: (CGFloat)qty;

@end
