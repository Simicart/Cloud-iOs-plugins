//
//  ProductOptionsModel.h
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface ProductOptionsModel : RetailerPosModel

- (void)getProductOptionWithId:(NSString*)productId;

@end
