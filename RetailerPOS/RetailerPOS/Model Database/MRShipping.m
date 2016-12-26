//
//  MRShipping.m
//  RetailerPOS
//
//  Created by mac on 4/25/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "MRShipping.h"

@implementation MRShipping

@dynamic name;
@dynamic code;
@dynamic price;
@dynamic sort_index;

+(void)initDataDefault{
    [MRShipping MR_truncateAll];
    
    for(int i =1 ; i < 5 ; i++){
        
        MRShipping * mrShipping =[MRShipping MR_createEntity];
        
        mrShipping.sort_index =[NSNumber numberWithInt:i];
        mrShipping.name =[NSString stringWithFormat:@"Shipping method %d",i];
        mrShipping.code =[NSString stringWithFormat:@"code%d",i];
        mrShipping.price =[NSNumber numberWithFloat:i];
    }
    
    SAVE_DATABASE ;
}

@end
