//
//  SaveCustomerAddressModel.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/28/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface SaveCustomerAddressModel : RetailerPosModel

- (void)saveCustomerAddressWithData:(NSDictionary*) data;

@end
