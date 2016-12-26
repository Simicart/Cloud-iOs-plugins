//
//  AddToCartModelCollection.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface UpdateItemCartModel : RetailerPosModel

- (void)updateItemCartWithID : (NSString*)productId options:(NSDictionary *)options qty:(NSString *)qty price:(NSString *)price;

@end
