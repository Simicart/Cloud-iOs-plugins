//
//  MSTableViewCell.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 9/29/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFramework.h"

@implementation MSTableViewCell
@synthesize iOS8Update = _iOS8Update;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.iOS8Update = 0;
        if ([MSFramework isIOS8]) {
            if (style == UITableViewCellStyleSubtitle) {
                self.iOS8Update = 2;
            } else if (style == UITableViewCellStyleValue1) {
                self.iOS8Update = 1;
            }
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.iOS8Update == 2) {
        CGRect frame = self.textLabel.frame;
        frame.origin.x += 10;
        self.textLabel.frame = frame;
        
        frame = self.detailTextLabel.frame;
        frame.origin.x += 10;
        self.detailTextLabel.frame = frame;
    } else if (self.iOS8Update == 1) {
        CGRect frame = self.textLabel.frame;
        frame.origin.x += 10;
        self.textLabel.frame = frame;
        
        CGRect detailFrame = self.detailTextLabel.frame;
        if (detailFrame.size.width) {
            detailFrame.origin.x -= 10;
            if (detailFrame.origin.x < frame.origin.x + frame.size.width) {
                detailFrame.size.width -= frame.origin.x + frame.size.width - detailFrame.origin.x;
                detailFrame.origin.x = frame.origin.x + frame.size.width;
            }
            self.detailTextLabel.frame = detailFrame;
        } else {
            [self.contentView addSubview:self.detailTextLabel];
            self.detailTextLabel.frame = CGRectMake(frame.origin.x + frame.size.width, self.frame.size.height / 2 - 11, self.frame.size.width - frame.origin.x - frame.size.width - 10, 21);
        }
    }
}

@end
