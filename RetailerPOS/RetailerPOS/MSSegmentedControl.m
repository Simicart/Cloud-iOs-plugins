//
//  MSSegmentedControl.m
//  RetailerPOS
//
//  Edit by Nguyen Duc Chieen on 23/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import "MSSegmentedControl.h"
#import "MSFramework.h"

@implementation MSSegmentedControl

- (id)initWithItems:(NSArray *)items
{
    self = [super initWithItems:items];
    
//    [self setBackgroundImage:[[UIImage imageNamed:@"btn_segment.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
//    [self setBackgroundImage:[[UIImage imageNamed:@"btn_segment_selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];

    self.tintColor = [UIColor barBackgroundColor];
    
    [self setDividerImage:[UIImage imageWithColor:[UIColor borderColor]] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    return self;
}

@end
