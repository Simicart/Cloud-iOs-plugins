//
//  Stores.h
//  RetailerPOS
//
//  Created by mac on 3/2/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Stores : NSManagedObject

@property (nonatomic, retain) NSString *store_id;
@property (nonatomic, retain) NSString *store_name;
@property (nonatomic, retain) NSString *enable_cash_drawer;

+(void)syncData:(NSArray *)stores;
    
@end

