//
//  KlarnaModel.h
//  SimiCartPluginFW
//
//  Created by Hoang Van Trung on 3/9/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

#define kSimiGetKlarnaURL @"klarna/checkout"
#define kSimiGetKlarnaUSURL @"klarna-usa/key"
#define DidGetKlarnaURL @"DidGetKlarnaURL"


@interface KlarnaModel : SimiModel
-(void) getKlarnaUSURLWithOrder:(NSString*) orderID;
-(void) getKlarnaURLWithOrder:(NSString*) orderID;
@end
