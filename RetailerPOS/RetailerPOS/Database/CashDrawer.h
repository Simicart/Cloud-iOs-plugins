//
//  CashDrawer.h
//  RetailerPOS
//
//  Created by mac on 3/2/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CashDrawer : NSManagedObject

@property (nonatomic, retain) NSString *cash_drawer_id;
@property (nonatomic, retain) NSString *cash_drawer_name;
@property (nonatomic, retain) NSString *save_automatic;

+(void)syncData:(NSArray*)cashDrawers;

@end
