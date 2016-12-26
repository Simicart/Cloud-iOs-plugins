//
//  CategoryModel.h
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface ProductModel : RetailerPosModel

- (void)getProduct:(NSString*)offset limit:(NSString*)limit category:(NSString*)categoryID keySearch:(NSString*)keyword;

@end
