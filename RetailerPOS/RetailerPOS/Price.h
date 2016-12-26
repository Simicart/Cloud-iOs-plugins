//
//  Price.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/31/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@interface Price : ModelAbstract

+(Price *)instance;
+(NSUInteger)precision;


+(NSString *)format:(NSNumber *)price;

-(NSString *)formatPrice:(long double)price;

@end
