//
//  ProductImagesView.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/15/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductImagesView : UIView <UIScrollViewDelegate>
@property (retain, nonatomic) NSArray *images;

- (void)changePage:(id)sender;

@end
