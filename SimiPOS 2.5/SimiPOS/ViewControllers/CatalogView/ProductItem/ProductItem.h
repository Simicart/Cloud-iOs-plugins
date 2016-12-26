//
//  ProductItem.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/8/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductItem : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIImageView *optionsImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UIView *productPriceBackground;


@end
