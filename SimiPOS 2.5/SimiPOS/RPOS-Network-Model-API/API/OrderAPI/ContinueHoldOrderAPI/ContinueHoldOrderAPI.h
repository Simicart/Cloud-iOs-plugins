//
//  ContinueHoldOrderAPI.h
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosAPI.h"

@interface ContinueHoldOrderAPI : RetailerPosAPI

- (void)continueHoldOrderWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector;

@end
