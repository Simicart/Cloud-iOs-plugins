//
//  SimiTagCollectionCell.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/12/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiTagCollectionCell.h"

@implementation SimiTagCollectionCell
@synthesize lblTagName, imgTag, simiTagModel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setData
{
    if (!self.hasData) {
        self.hasData = YES;
        imgTag = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:imgTag];
        
        lblTagName = [UILabel new];
        CGRect frame= imgTag.frame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            frame.origin.x += 29;
            frame.size.width -= 29;
        }else
        {
            frame.origin.x += 39;
            frame.size.width -= 39;
        }
        [lblTagName setFrame:frame];
        lblTagName.textColor = [[SimiGlobalVar sharedInstance] colorWithHexString:@"#393939"];
        [lblTagName setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE - 4]];
        [self addSubview:lblTagName];
    }
}
@end
