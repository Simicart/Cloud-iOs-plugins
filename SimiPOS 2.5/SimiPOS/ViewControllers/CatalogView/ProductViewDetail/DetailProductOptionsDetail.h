//
//  DetailProductOptionsDetail.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/16/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "ProductOptionsDetail.h"

@interface DetailProductOptionsDetail : ProductOptionsDetail
@property (strong, nonatomic) UIPopoverController *popoverController;

- (CGSize)reloadContentSize;

@end
