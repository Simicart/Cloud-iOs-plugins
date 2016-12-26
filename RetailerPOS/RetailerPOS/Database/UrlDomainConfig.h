//
//  UrlDomainConfig.h
//  RetailerPOS
//
//  Created by mac on 3/17/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface UrlDomainConfig : NSManagedObject

@property (nullable, nonatomic, retain) NSString *domain_dev;
@property (nullable, nonatomic, retain) NSString *domain_live;
@property (nullable, nonatomic, retain) NSString *domain_active;
@property (nullable, nonatomic, retain) NSString *main_api_url;
@property (nullable, nonatomic, retain) NSString *dev_api_url;
@property (nullable, nonatomic, retain) NSString *api_key;

@end

