//
//  QuoteResource.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ModelAbstract.h"
#import "Quote.h"
#import "Product.h"
#import "Customer.h"

@interface QuoteResource : ModelAbstract

@property (strong, nonatomic) NSString *type;
-(void)loadDataRequest:(NSString *)type;
-(void)loadDataSuccess;

@property (strong, nonatomic) id itemId;
@property (strong, nonatomic) Product *product;
@property (strong, nonatomic) NSDictionary *options;
@property (strong, nonatomic) NSNumber *itemQty;
@property (strong, nonatomic) id customPrice;

-(void)addCustomSale;
-(void)addCustomSaleSuccess;

-(void)updateItemRequest:(id)identify method:(NSString *)method;
-(void)updateItemSuccess;

@property (strong, nonatomic) Customer *customer;
-(void)assignCustomer;
-(void)assignCustomerComplete;

@property (strong, nonatomic) NSDictionary *config;
-(void)placeOrder:(NSDictionary *)config;
-(void)placeOrderComplete;

@end
