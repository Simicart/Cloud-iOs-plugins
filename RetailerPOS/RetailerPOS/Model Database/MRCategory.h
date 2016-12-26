//
//  MRCategory.h
//  RetailerPOS
//
//  Created by mac on 4/21/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MRCategory : NSManagedObject

@property (nonatomic, retain) NSString *category_id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *level;
@property (nonatomic, retain) NSString *is_parrent;
@property (nonatomic, retain) NSString *parrent_id;
@property (nonatomic, retain) NSNumber *order_index;


+(void)syncData:(NSDictionary *)categories;

@end

