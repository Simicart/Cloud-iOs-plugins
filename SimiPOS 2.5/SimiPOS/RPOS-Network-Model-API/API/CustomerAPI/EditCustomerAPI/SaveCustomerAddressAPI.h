//
//  SaveCustomerAddressAPI.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosAPI.h"

@interface SaveCustomerAddressAPI : RetailerPosAPI

- (void)saveCustomerAddressWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector;

@end