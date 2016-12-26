//
//  AddToCartModelCollection.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface CancelOnHoldOrderModel : RetailerPosModel

- (void)cancelHoldOrderWithID:(NSString*)orderID;

@end
