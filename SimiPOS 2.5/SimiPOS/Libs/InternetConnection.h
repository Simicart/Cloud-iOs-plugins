//
//  InternetConnection.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/19/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface InternetConnection : NSObject

+(BOOL)canAccess;

@end