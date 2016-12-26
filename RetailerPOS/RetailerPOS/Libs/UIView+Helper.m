//
//  UIView+Helper.m
//  RetailerPOS
//
//  Created by mac on 4/27/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "UIView+Helper.h"

@implementation UIView(Helper)

- (void)roundCornerswithRadius:(float)cornerRadius
               andShadowOffset:(float)shadowOffset
{
    const float CORNER_RADIUS = cornerRadius;
    const float SHADOW_OFFSET = shadowOffset;
    const float SHADOW_OPACITY = 0.5;
    const float SHADOW_RADIUS = 3.0;
    
    UIView *superView = self.superview;
    
    CGRect oldBackgroundFrame = self.frame;
    [self removeFromSuperview];
    
    CGRect frameForShadowView = CGRectMake(0, 0, oldBackgroundFrame.size.width, oldBackgroundFrame.size.height);
    UIView *shadowView = [[UIView alloc] initWithFrame:frameForShadowView];
    [shadowView.layer setShadowOpacity:SHADOW_OPACITY];
    [shadowView.layer setShadowRadius:SHADOW_RADIUS];
    [shadowView.layer setShadowOffset:CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET)];
    
    [self.layer setCornerRadius:CORNER_RADIUS];
    [self.layer setMasksToBounds:YES];
    
    [shadowView addSubview:self];
    [superView addSubview:shadowView];
    
}
@end
