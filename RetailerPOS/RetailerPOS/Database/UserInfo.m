//
//  UserInfo.m
//  RetailerPOS
//
//  Created by mac on 3/2/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

@dynamic username;
@dynamic store_id;
@dynamic enable_cash_drawer;
@dynamic cash_drawer_id;
@dynamic session;

@dynamic display_name;
@dynamic email_address;
@dynamic password;
@dynamic user_id;

+(void)syncData:(NSDictionary *)userInfoDict{
    
    if(userInfoDict){
    
        [UserInfo truncateAll];
        
        UserInfo * userInfo =[UserInfo MR_createEntity];
        userInfo.username =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"username"]];
        userInfo.display_name =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"display_name"]];
        userInfo.email_address =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"email"]];
        userInfo.session =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"sessid"]];
        userInfo.user_id =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"user_id"]];
        userInfo.password =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"password"]];
        
        SAVE_DATABASE;
    }
}

@end
