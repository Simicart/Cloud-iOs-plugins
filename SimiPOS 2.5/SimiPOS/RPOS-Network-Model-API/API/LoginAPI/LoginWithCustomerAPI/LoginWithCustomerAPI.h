//
//  LoginWithCustomerAPI.h
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosAPI.h"

@interface LoginWithCustomerAPI : RetailerPosAPI

- (void)loginCustomerWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector;

@end
