//
//  InstantContactCollectionViewCell.h
//  SimiCartPluginFW
//
//  Created by Gin on 2/3/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstantContactCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) UIImageView *image;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) NSString *stringColor;
-(void)setCellCollection:(NSString *)img : (NSString *)textt;
@end
