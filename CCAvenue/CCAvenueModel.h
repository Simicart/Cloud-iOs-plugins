//
//  CCAvenueModel.h
//  SimiCartPluginFW
//
//  Created by Axe on 1/20/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SimiCartBundle/SimiOrderModel.h>

#define DidGetRSACCAvenue  @"DidGetRSACCAvenue"
#define DidUpdateCCAvenuePayment @"DidUpdateCCAvenuePayment"

@interface CCAvenueModel : SimiModel

-(void) getRSAForOrder:(NSString* ) orderID;
-(void) updatePaymentWithOrder:(NSString* ) orderID status:(NSString*) status;



@end
