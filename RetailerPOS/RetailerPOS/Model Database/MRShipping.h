//
//  MRShipping.h
//  RetailerPOS
//
//  Created by mac on 4/25/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MRShipping : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSNumber *sort_index;

+(void)initDataDefault;

@end

