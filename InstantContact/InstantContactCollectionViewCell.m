//
//  InstantContactCollectionViewCell.m
//  SimiCartPluginFW
//
//  Created by Gin on 2/3/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import "InstantContactCollectionViewCell.h"
#import <SimiCartBundle/UIImage+SimiCustom.h>
@implementation InstantContactCollectionViewCell{
    float sizeImage,widthLabel,heightLabel;
}
@synthesize image,label,stringColor;
-(instancetype) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sizeImage = [SimiGlobalVar scaleValue:68];
        widthLabel = self.frame.size.width;
        heightLabel = [SimiGlobalVar scaleValue:40];
        image = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - sizeImage)/2, (self.frame.size.height - sizeImage)/2, sizeImage, sizeImage)];
        [image setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:image];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeImage + image.frame.origin.y, widthLabel, heightLabel)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
        [self addSubview:label];
    }
    return self;
}
-(void)setCellCollection:(NSString *)img : (NSString *)text{
     [image setImage:[[UIImage imageNamed:img]imageWithColor:[[SimiGlobalVar sharedInstance]colorWithHexString:stringColor]]];
    label.text = SCLocalizedString(text);
}
@end
