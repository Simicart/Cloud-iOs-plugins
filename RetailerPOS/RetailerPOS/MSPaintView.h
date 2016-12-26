//
//  MSPaintView.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSPaintView : UIView {
    UIBezierPath *_path;
    CGPoint points[5];
    NSUInteger counter;
}

- (void)clear;

@end
