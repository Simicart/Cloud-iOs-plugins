//
//  Payment.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"

@class PaymentCollection;

@interface Payment : ModelAbstract
@property (strong, nonatomic) PaymentCollection *collection;
@property (strong, nonatomic) Payment *instance;

-(BOOL)isCurrentMethod:(Payment *)method;

// Validate payment method
-(BOOL)validate;

// Payment options (Instance Methods)
-(BOOL)hasOptionForm;
-(BOOL)isCreditCardMethod;
-(NSArray *)formFields;

// Credit Card Info
-(NSString *)cardType;
-(NSString *)last4Digit;

// Save method
-(void)saveMethod;
-(void)saveMethodSuccess;

@end
