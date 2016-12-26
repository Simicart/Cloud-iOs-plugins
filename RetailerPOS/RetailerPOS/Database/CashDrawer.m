//
//  CashDrawer.m
//  RetailerPOS
//
//  Created by mac on 3/2/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "CashDrawer.h"

@implementation CashDrawer

@dynamic cash_drawer_id;
@dynamic cash_drawer_name;
@dynamic save_automatic;

+(void)syncData:(NSArray*)cashDrawers{
    
    if(cashDrawers && cashDrawers.count >0){
        
        //remove database;
        [CashDrawer truncateAll];
        
        for(NSDictionary * item in cashDrawers){
            
            if(item && [item isKindOfClass:[NSDictionary class]]){
                NSString * cash_drawer_id =[NSString stringWithFormat:@"%@",[item objectForKey:@"id"]];
                NSString * cash_drawer_name =[NSString stringWithFormat:@"%@",[item objectForKey:@"name"]];
                NSString * saved_automatic =[NSString stringWithFormat:@"%@",[item objectForKey:@"saved_automatic"]];
                
                CashDrawer * cashDrawer =[CashDrawer MR_createEntity];
                
                cashDrawer.cash_drawer_id =cash_drawer_id;
                cashDrawer.cash_drawer_name =cash_drawer_name;
                cashDrawer.save_automatic =saved_automatic;
            }
        }
        
        SAVE_DATABASE;
    }

}

@end
