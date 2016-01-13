//
//  SimiBraintreeModel.h
//  SimiCartPluginFW
//
//  Created by Axe on 12/30/15.
//  Copyright © 2015 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiOrderModel.h>

extern NSString *const kBraintreeUpdatePayment;
extern NSString *const kBraintreeGetToken;

extern NSString *const BRAINTREESENDNONCETOSERVER;
extern NSString *const BRAINTREEGETSETTING;
extern NSString *const BRAINTREEGETTOKEN;

@interface SimiBraintreeModel : SimiModel
-(void) sendNonceToServer:(NSString* )nonce andOrderID:(NSString*) orderID;
-(void) getSetting;
-(void) getToken;
@end
