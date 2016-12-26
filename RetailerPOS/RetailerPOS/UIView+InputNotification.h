//
//  UIView+InputNotification.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/30/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (InputNotification)

+ (UIView *)firstResponder:(UIView *)responder;

- (id)clone;

@end
