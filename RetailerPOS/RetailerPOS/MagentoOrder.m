//
//  MagentoOrder.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/2016/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MagentoOrder.h"
#import "OrderCollection.h"
#import "MSFramework.h"

@implementation MagentoOrder

- (void)sendEmail:(Order *)order address:(NSString *)email finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"order.email" forKey:@"method"];
    
    [params setValue:@[[order objectForKey:@"increment_id"], email] forKey:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}

- (void)createInvoice:(Order *)order withData:(NSDictionary *)data finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"order_invoice.create" forKey:@"method"];
    
    [params setValue:@[[order objectForKey:@"increment_id"]] forKey:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}

- (void)createCreditmemo:(Order *)order withData:(NSDictionary *)data finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"order_creditmemo.create" forKey:@"method"];
    
    NSMutableArray *methodParams = [NSMutableArray new];
    [methodParams addObject:[order objectForKey:@"increment_id"]];
    [methodParams addObject:data];
    // Comment for Credit Memo
    if (![MSValidator isEmptyString:[data objectForKey:@"comment_text"]]) {
        [methodParams addObject:[data objectForKey:@"comment_text"]];
    }
    [params setValue:methodParams forKey:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}

- (void)cancel:(Order *)order finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"order.cancel" forKey:@"method"];
    [params setValue:@[[order objectForKey:@"increment_id"]] forKey:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}

//ship
- (void)ship:(Order *)order finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"order.ship" forKey:@"method"];
    [params setValue:@[[order objectForKey:@"increment_id"]] forKey:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}


- (void)comment:(Order *)order finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"order.addComment" forKey:@"method"];
    [params setValue:@[[order objectForKey:@"increment_id"], [order objectForKey:@"new_comment"]] forKey:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}

#pragma mark - implement abstract
- (NSMutableDictionary *)prepareLoad:(ModelAbstract *)model
{
    NSMutableDictionary *params = [super prepareLoad:model];
    [params setValue:@"order.info" forKey:@"method"];
    return params;
}

- (NSMutableDictionary *)prepareLoadCollection:(CollectionAbstract *)collection
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"order.search" forKey:@"method"];
    
    OrderCollection * orderCollection =(OrderCollection *)collection;
    
    NSString *searchTerm = [orderCollection searchTerm];
    if (searchTerm == nil) {
        searchTerm = @"";
    }
    [params setValue:@[searchTerm, [NSNumber numberWithUnsignedInteger: collection.curPage], [NSNumber numberWithUnsignedInteger: collection.pageSize]] forKey:@"params"];
    
    
    if(orderCollection.isHoldOrder){
    //    [params setValue:@[@"YES"] forKey:@"holdorder"];
         [params setValue:[NSNumber numberWithBool:orderCollection.isHoldOrder] forKey:@"holdorder"];
    }
    
    return params;
}

#pragma mark - load print data
- (void)loadPrint:(Order *)order finished:(SEL)finishedMethod
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"order.print" forKeyPath:@"method"];
    [params setValue:[order getIncrementId] forKeyPath:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}

- (void)cancelHoldOrder:(Order *)order finished:(SEL)finishedMethod{
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:@"order.holdOrderCancel" forKey:@"method"];
    [params setValue:@[[order objectForKey:@"increment_id"]] forKey:@"params"];
    [self post:params target:(NSObject *)order finished:finishedMethod async:NO];
}

@end
