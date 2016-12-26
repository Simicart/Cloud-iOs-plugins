//
//  UIView+InputNotification.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/30/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (InputNotification)

+ (UIView *)firstResponder:(UIView *)responder;

- (id)clone;

@end
