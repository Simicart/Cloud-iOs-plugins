//
//  MSPaintView.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSPaintView.h"

@implementation MSPaintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setMultipleTouchEnabled:NO];
        _path = [UIBezierPath bezierPath];
        [_path setLineWidth:7];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [_path stroke];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    counter = 0;
    UITouch *touch = [touches anyObject];
    points[0] = [touch locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    counter++;
    UITouch *touch = [touches anyObject];
    points[counter] = [touch locationInView:self];
    if (counter == 4) {
        points[3] = CGPointMake((points[2].x + points[4].x) / 2, (points[2].y + points[4].y) / 2);
        [_path moveToPoint:points[0]];
        [_path addCurveToPoint:points[3] controlPoint1:points[1] controlPoint2:points[2]];
        [self setNeedsDisplay];
        points[0] = points[3];
        points[1] = points[4];
        counter = 1;
    }
}

- (void)clear
{
    [_path removeAllPoints];
    [self setNeedsDisplay];
}

@end
