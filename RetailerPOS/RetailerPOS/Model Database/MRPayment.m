//
//  MRPayment.m
//  RetailerPOS
//
//  Created by mac on 4/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "MRPayment.h"

@implementation MRPayment

@dynamic code;
@dynamic title;
@dynamic cctypes;
@dynamic merchant;
@dynamic order_index;

+(void)syncData:(NSDictionary *)payments{
    
    if(payments && payments.allKeys >0){
        
        [MRPayment MR_truncateAll];
        int sortIndex =0;
        
        for(NSString * key in payments.allKeys){
            if([[payments objectForKey:key] isKindOfClass:[NSDictionary class]]){
                
                NSDictionary * payment =[payments objectForKey:key];
                NSString * code =[NSString stringWithFormat:@"%@",[payment objectForKey:@"code"]];
                NSString * title =[NSString stringWithFormat:@"%@",[payment objectForKey:@"title"]];
                NSString * cctypes =[NSString stringWithFormat:@"%@",[payment objectForKey:@"cctypes"]];
                NSString * merchant =[NSString stringWithFormat:@"%@",[payment objectForKey:@"merchant"]];
                sortIndex = sortIndex+1;
                
                MRPayment * mrPayment =[MRPayment MR_createEntity];
                mrPayment.code = code;
                mrPayment.title = title;
                mrPayment.cctypes = cctypes;
                mrPayment.merchant = merchant;
                mrPayment.order_index =[NSNumber numberWithInt:sortIndex];
            }
        }
        SAVE_DATABASE ;
    }
}

@end
