//
//  CustomerInfo.h
//  SimiPOS
//
//  Created by mac on 3/3/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CustomerInfo : NSManagedObject

@property (nullable, nonatomic, retain) NSString *customer_id;
@property (nullable, nonatomic, retain) NSString *customer_name;
@property (nullable, nonatomic, retain) NSString *email;
@property (nullable, nonatomic, retain) NSString *group_id;
@property (nullable, nonatomic, retain) NSString *telephone;

@end

