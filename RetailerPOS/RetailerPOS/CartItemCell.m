//
//  CartItemCell.m
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/10/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CartItemCell.h"

@implementation CartItemCell
@synthesize badgeImageView;
@synthesize badgeLabel;

- (void)addBadgeQty:(CGFloat)qty
{
    if (badgeImageView == nil) {
        UIImage *badgeImage = [[UIImage imageNamed:@"cart_qtybadge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(13, 13, 13, 13)];
        badgeImageView = [[UIImageView alloc] initWithImage:badgeImage];
        badgeImageView.contentMode = UIViewContentModeScaleToFill;
        
        badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        badgeLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        badgeLabel.textColor = [UIColor whiteColor];
        [badgeImageView addSubview:badgeLabel];
        
        // Add badge image to Cell
        [self addSubview:badgeImageView];
    }
    if (qty == 1) {
        badgeImageView.hidden = YES;
        return;
    }
    badgeImageView.hidden = NO;
    
    badgeLabel.text = [NSString stringWithFormat:@"%.0f", qty];
    [badgeLabel sizeToFit];
    
    badgeImageView.frame = CGRectMake(67 - badgeLabel.frame.size.width / 2, 0, badgeLabel.frame.size.width + 15, 27);
    badgeLabel.center = CGPointMake(badgeImageView.frame.size.width / 2, badgeImageView.frame.size.height / 2);
}

@end
