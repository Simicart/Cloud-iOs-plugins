//
//  CategoryAPI.h
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosAPI.h"

@interface CategoryAPI : RetailerPosAPI

- (void)getCategoryWithParams:(NSDictionary *)params method:(NSString*)method target:(id)target selector:(SEL)selector;

@end
