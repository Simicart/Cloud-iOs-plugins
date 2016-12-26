//
//  MSPaintView.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
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
