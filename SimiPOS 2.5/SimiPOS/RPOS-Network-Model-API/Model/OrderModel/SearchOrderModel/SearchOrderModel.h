//
//  SearchOrderModel.h
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface SearchOrderModel : RetailerPosModel

- (void)getOrder:(NSString*)offset limit:(NSString*)limit keySearch:(NSString*)keyword isHoldOrder:(NSString*)isHoldOrder;
- (void) removeCache:(NSString*)offset limit:(NSString*)limit keySearch:(NSString*)keyword isHoldOrder:(NSString*)isHoldOrder;
- (void)removeCacheHoldOrder;
@end
