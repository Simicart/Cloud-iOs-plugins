//
//  Stores.m
//  RetailerPOS
//
//  Created by mac on 3/2/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "Stores.h"

@implementation Stores

@dynamic store_id;
@dynamic store_name;
@dynamic enable_cash_drawer;

+(void)syncData:(NSArray *)stores{
    if(stores && stores.count >0){
        
        //remove database;
        [Stores truncateAll];
        
        for(NSDictionary * item in stores){
            
            if(item && [item isKindOfClass:[NSDictionary class]]){
                NSString * store_id =[NSString stringWithFormat:@"%@",[item objectForKey:@"id"]];
                NSString * store_name =[NSString stringWithFormat:@"%@",[item objectForKey:@"name"]];
                NSString * enable_cash_drawer =[NSString stringWithFormat:@"%@",[item objectForKey:@"enable_cash_drawer"]];
                
                Stores * store =[Stores MR_createEntity];
                
                store.store_id =store_id;
                store.store_name =store_name;
                store.enable_cash_drawer =enable_cash_drawer;
            }
        }
        
        SAVE_DATABASE;
    }
}

@end
