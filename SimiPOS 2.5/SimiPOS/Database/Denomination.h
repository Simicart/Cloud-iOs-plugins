//
//  Denomination.h
//  SimiPOS
//
//  Created by mac on 3/1/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Denomination : NSManagedObject

@property (nonatomic, retain) NSNumber *deno_id;
@property (nonatomic, retain) NSString *deno_name;
@property (nonatomic, retain) NSString *deno_value;

@end

