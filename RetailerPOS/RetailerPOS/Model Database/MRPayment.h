//
//  MRPayment.h
//  RetailerPOS
//
//  Created by mac on 4/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MRPayment : NSManagedObject

@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *cctypes;
@property (nonatomic, retain) NSString *merchant;
@property (nonatomic, retain) NSNumber *order_index;

+(void)syncData:(NSDictionary *)payments;

@end
