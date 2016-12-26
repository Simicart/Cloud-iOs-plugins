//
//  MagentoDiscount.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoAbstract.h"
#import "Discount.h"

@interface MagentoDiscount : MagentoAbstract

-(void)addCoupon:(Discount *)discount withCoupon:(NSString *)code finished:(SEL)finishedMethod;
-(void)addCustomDiscount:(Discount *)discount finished:(SEL)finishedMethod;

@end
