//
//  APIManager.m
//  RetailerPOS
//
//  Created by Marcus on 12/04/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagentoAbstract.h"
#import "UserInfo.h"
#import "ModelAbstract.h"
#import "CollectionAbstract.h"
#import "Configuration.h"

typedef void(^Callback)(BOOL success,id result);

@interface APIManager : NSObject

+ (instancetype)shareInstance;

#pragma mark - post default
-(void)post:(NSDictionary *)params callback:(Callback)callback withUrlAPI:(NSString *)apiUrl;

#pragma mark - login
-(void)loginWithUsername:(NSString *)username Password:(NSString *)password Callback:(Callback)callback;

-(void)loadReportMidAndEndOfDay:(Callback)callback;

-(void)getListManualCount:(Callback)callback;

#pragma mark - ZReport Close store
-(void)closeStoreManualCount:(NSString *)manualCount CashAmountKept:(NSString *)cashAmountKept Callback:(Callback)callback;

#pragma mark - Daily Report
-(void)getDailyReport:(Callback)callback;


#pragma mark - Cash drawer management
-(void)getTransactionList:(Callback)callback;

-(void)addTransactionAmount:(NSString *)amount Note:(NSString *)note Type:(NSString *)type Callback:(Callback)callback;

-(void)getCurrentBalance:(Callback)callback;

#pragma  mark - set store data
-(void)setStoreData:(NSString *)storeId TillId:(NSString *)tillId Callback:(Callback)callback;

#pragma mark- customer
-(void)getCustomer:(NSString *)searchKey Callback:(Callback)callback;

#pragma mark - checkout_cart.holdOrder
-(void)holdOrderCashIn:(NSString *)cashIn Note:(NSString *)note Callback:(Callback)callback;

#pragma mark - custoemr.getCustomerGroups
-(void)getCustomerGroups:(Callback)callback;

#pragma mark - change profile info
-(void)changeProfleUserId:(NSString*)userId Name:(NSString*)name Email:(NSString*)email OldPassword:(NSString*)oldPassword NewPassword:(NSString*)newPassword Callback:(Callback)callback;

-(void)orderShipmentOrderId:(NSString *)incrementId WithItems:(NSDictionary *)items Callback:(Callback)callback;

#pragma mark - Active Key
-(void)getStoreUrl:(NSString *)apiKey Callback:(Callback)callback;

-(void)getOrderPrintLink:(NSString *)incrementId  Callback:(Callback)callback;

#pragma mark - Hold Continue
-(void)holdOrderContinue:(NSString *)incrementId Callback:(Callback)callback;


-(void)requestTrial:(NSString *)email Domain:(NSString *)domain Callback:(Callback)callback;

#pragma mark - Lay thong tin demo info
-(void)getDemoDataCallback:(Callback)callback;

#pragma mark - ****** OFFLINE MODE ******************

#pragma mark - Get list Product
-(void)getListProducts:(Callback)callback;

#pragma mark - get list Categories
-(void)getListCategories:(Callback)callback;

-(void)getListPayments:(Callback)callback;

@end
