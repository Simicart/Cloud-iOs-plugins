//
//  DemoInfo.h
//  RetailerPOS
//
//  Created by mac on 4/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MRDemoInfo : NSManagedObject

@property (nonatomic, retain) NSString *demo_url;
@property (nonatomic, retain) NSString *demo_user;
@property (nonatomic, retain) NSString *demo_pass;

@end

