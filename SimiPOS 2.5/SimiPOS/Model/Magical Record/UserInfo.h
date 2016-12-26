//
//  UserInfo.h
//  SimiPOS
//
//  Created by mac on 3/2/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *store_id;
@property (nonatomic, retain) NSString *enable_cash_drawer;
@property (nonatomic, retain) NSString *cash_drawer_id;
@property (nonatomic, retain) NSString *session;

@property (nonatomic, retain) NSString *display_name;
@property (nonatomic, retain) NSString *email_address;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) NSString *user_id;

@end

