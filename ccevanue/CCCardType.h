//
//  CCCardType.h
//  CCIntegrationKit
//
//  Created by test on 5/14/14.
//  Copyright (c) 2014 Avenues. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCCardType : NSObject
    @property (strong, nonatomic) NSString *cardName;
    @property (strong, nonatomic) NSString *cardType;
    @property (strong, nonatomic) NSString *payOptType;
    @property (strong, nonatomic) NSString *dataAcceptedAt;
    @property (strong, nonatomic) NSString *status;
@end
