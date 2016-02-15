//
//  UILabel+DynamicSizeMe.m
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/7/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "UILabel+DynamicSizeMe.h"

@implementation UILabel (DynamicSizeLabel)
-(float)resizeToFit{
    float height = [self expectedHeight];
    CGRect newFrame = [self frame];
    newFrame.size.height = height;
    [self setFrame:newFrame];
    return newFrame.origin.y + newFrame.size.height;
}

-(float)expectedHeight{
    [self setNumberOfLines:0];
    self.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGSize maximumLabelSize = CGSizeMake(self.frame.size.width,9999);
    
    CGSize expectedLabelSize = [[self text] sizeWithFont:[self font]
                                       constrainedToSize:maximumLabelSize
                                           lineBreakMode:[self lineBreakMode]];
    return expectedLabelSize.height;
}
@end
