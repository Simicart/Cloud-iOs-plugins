//
//  TransctionAddModel.h
//  SimiPOS
//
//  Created by Dong on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface TransctionAddModel : RetailerPosModel

- (void)getTransactionAdd:(NSString*)amount note:(NSString*)note type:(NSString*)type;

@end
