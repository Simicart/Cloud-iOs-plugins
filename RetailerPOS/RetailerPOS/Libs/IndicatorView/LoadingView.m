//
//  LoadingView.m
//  AnUong
//
//  Created by Toan Hoang Duc on 4/25/14.
//  Copyright (c) 2014 Toan Hoang Duc. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

// Cần inits cái gì thì cho vào chỗ này.
- (id)init
{
    if(self =[super init]) {
        
        NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        UIView *mainView = subViews[0];
        [self setFrame:mainView.frame];
        [self addSubview:mainView];
        
        [self setDefaults];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    
    self =[super initWithCoder:aDecoder];
    if(self) {
        
        NSArray *subViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        UIView *mainView = subViews[0];
        [self addSubview:mainView];
        
        [self setDefaults];
    }
    
    return self;
    
}

- (void)setDefaults
{
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setUserInteractionEnabled:NO];
    
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnimation.removedOnCompletion = NO;
    spinAnimation.byValue = [NSNumber numberWithFloat:2.0f*M_PI];
    spinAnimation.duration = 1.0f;
    spinAnimation.repeatCount = NSIntegerMax;
    [self.loadingImageView.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
