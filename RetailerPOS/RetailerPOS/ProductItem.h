//
//  ProductItem.h
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/8/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductItem : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIImageView *optionsImage;
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productPrice;


@end
