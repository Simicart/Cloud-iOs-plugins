//
//  SynchronizationCell.m
//  RetailerPOS
//
//  Created by mac on 4/13/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SynchronizationCell.h"
#import "MRProduct.h"
#import "CustomerInfo.h"
#import "MRCategory.h"
#import "MRPayment.h"
#import "MRShipping.h"

@implementation SynchronizationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

#pragma mark - Button Event Click
- (IBAction)syncPaymentButtonClick:(id)sender {
    [self syncPayments];
    [self showLastimeUpdate];
}

- (IBAction)syncCustomerButtonClick:(id)sender {
    [self syncCustomer];
    [self showLastimeUpdate];
}

- (IBAction)syncCategoryButtonClick:(id)sender {
    [self syncCategory];
    [self showLastimeUpdate];
}

- (IBAction)syncProducdtButtonClick:(id)sender {
    [self syncProduct];
    [self showLastimeUpdate];
}

- (IBAction)syncShippingButtonClick:(id)sender {

     [self syncShipping];
     [self showLastimeUpdate];
}

-(void)syncShipping{
    [MRShipping initDataDefault];
    [self.shippingProgressBar setValue:100
                   animateWithDuration:1];
    [self showLog];
    [self updateLog:@"SYNC SHIPPINGS METHOD"];
}

- (IBAction)showLogInfoClick:(id)sender {
    
        self.logDetailTextView.hidden = ! self.logDetailTextView.hidden;
    
    if(self.logDetailTextView.hidden){
        //Show log information
        [self.showLogButton setTitle:@"Show log information" forState:UIControlStateNormal];
    }else{
          [self.showLogButton setTitle:@"Hide log information" forState:UIControlStateNormal];
    }
}


-(void)showLog{
    [self.showLogButton setTitle:@"Hide log information" forState:UIControlStateNormal];
    self.logDetailTextView.hidden =NO;
}

-(void)synchronizationAll{
    
    [self syncPayments];
    [self syncCustomer];
    [self syncCategory];
    [self syncProduct];
    [self syncShipping];
    
    [self showLastimeUpdate];
}

#pragma mark - Sync Items
-(void)syncPayments{
    [self.paymentProgressBar setValue:1
                     animateWithDuration:1];
    
    [self showLog];
    [self updateLog:@"SYNC PAYMENTS METHOD"];
    
    [[APIManager shareInstance] getListPayments:^(BOOL success, id result) {
        
        
        if(success){
            [self.paymentProgressBar setValue:60.f
                             animateWithDuration:1];
            
            if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"data"]){
                
                //Cap nhat database
                NSDictionary * payments =[result objectForKey:@"data"];
                if(payments){
                    [MRPayment syncData:payments];
                    [self updateLog:[NSString stringWithFormat:@"TOTAL PAYMENTS (%d) UPDATED . ",(int)payments.allKeys.count-1]];
                }
                
                [self.paymentProgressBar setValue:100.f
                                 animateWithDuration:1];
                
                return ;
            }
        }
        
        [self.paymentProgressBar setValue:0
                         animateWithDuration:1];
        
        [self updateLog:[NSString stringWithFormat:@"Sync PAYMENTS fail:\n %@",result]];
        
    }];
    
    
}

#pragma mark - SYNC CUSTOMER
-(void)syncCustomer{
    
    [self.customerProgressBar setValue:1
                  animateWithDuration:1];
    
    [self showLog];
    [self updateLog:@"Sync Customers"];
    

    [[APIManager shareInstance] getCustomer:@"" Callback:^(BOOL success, id result) {
      
        if(success){
            [self.customerProgressBar setValue:60.f
                          animateWithDuration:1];
            
            NSDictionary * listData =[result objectForKey:@"data"];
            if(listData && [listData isKindOfClass:[NSDictionary class]]){
                
                dispatch_queue_t backgroundQueue = dispatch_queue_create("customerInfoList", 0);
                dispatch_async(backgroundQueue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self insertDataBase:listData];
                        
                    });
                });
            }
            
        }else{
            
            [self.customerProgressBar setValue:0
                          animateWithDuration:1];
            
            [self updateLog:[NSString stringWithFormat:@"Sync Customers fail:\n %@",result]];
        }
        
    }];
    
}

-(void)insertDataBase:(NSDictionary *) listData{

    NSArray * allKeys = [listData allKeys];
    if(allKeys && allKeys.count >0){
        
        //Xoa du lieu cu
        [CustomerInfo truncateAll];
        
        for(NSString * key in allKeys){
            
            id dict =[listData objectForKey:key];
            
            if(dict && [dict isKindOfClass:[NSDictionary class]]){
                
                CustomerInfo * customerInfo =[CustomerInfo MR_createEntity];
                customerInfo.customer_id=key;
                customerInfo.customer_name=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                customerInfo.email=[NSString stringWithFormat:@"%@",[dict objectForKey:@"email"]];
                customerInfo.group_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"group_id"]];
                customerInfo.telephone=[NSString stringWithFormat:@"%@",[dict objectForKey:@"telephone"]];
            }
            
        }
        
        [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
        
        [self updateLog:[NSString stringWithFormat:@"TOTAL CUSTOMERS (%d) UPDATED . ",(int)allKeys.count]];
        
        [self.customerProgressBar setValue:100.f
                       animateWithDuration:1];
        
    }
}

#pragma mark - SYNC CATEGORY
-(void)syncCategory{

    [self.categoriesProgressBar setValue:1
                  animateWithDuration:1];
    
    [self showLog];
    [self updateLog:@"SYNC CATEGORIES"];
    
    [[APIManager shareInstance] getListCategories:^(BOOL success, id result) {
        
        
        if(success){
            [self.categoriesProgressBar setValue:60.f
                          animateWithDuration:1];
            
            if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"data"]){
                
                //Cap nhat database
                NSDictionary * categories =[result objectForKey:@"data"];
                if(categories){
                     [MRCategory syncData:categories];
                    [self updateLog:[NSString stringWithFormat:@"TOTAL CATEGORIES (%d) UPDATED . ",(int)categories.allKeys.count]];
                }
                
                [self.categoriesProgressBar setValue:100.f
                              animateWithDuration:1];
                
                return ;
            }
        }
        
        [self.categoriesProgressBar setValue:0
                      animateWithDuration:1];
        
        [self updateLog:[NSString stringWithFormat:@"Sync categories fail:\n %@",result]];
        
    }];
    
    
}

-(void)syncProduct{
    [self.productProgressBar setValue:1
                  animateWithDuration:1];
    
    [self showLog];
    [self updateLog:@"Sync PRODUCTS"];
    
    [[APIManager shareInstance] getListProducts:^(BOOL success, id result) {
        
        
        if(success){
            [self.productProgressBar setValue:60.f
                          animateWithDuration:1];
            
            if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"data"]){
                
                //Cap nhat database
                NSDictionary * products =[result objectForKey:@"data"];
                [MRProduct syncData:products];
                
                if([products objectForKey:@"total"]){
                    [self updateLog:[NSString stringWithFormat:@"TOTAL PRODUCTS (%@) UPDATED . ",[products objectForKey:@"total"]]];
                }
                
                [self.productProgressBar setValue:100.f
                              animateWithDuration:1];
                
                return ;
            }
        }
        
        [self.productProgressBar setValue:0
                      animateWithDuration:1];
        
        [self updateLog:[NSString stringWithFormat:@"Sync products fail:\n %@",result]];
            
    }];
}

#pragma mark - Show lastime update
-(void)showLastimeUpdate{
    
    NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
    dateFormatter.dateFormat =@"dd/MM/yyyy HH:mm:ss";

    self.lastUpdateTimeLabel.text =[NSString stringWithFormat:@"Last updated at %@",[dateFormatter stringFromDate:[NSDate date]]];
}

-(void)updateLog:(NSString *)message{
    
    NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
    dateFormatter.dateFormat =@"dd/MM/yyyy HH:mm:ss";
    
    NSString * logInfo =[NSString stringWithFormat:@"%@\n%@ : %@",self.logDetailTextView.text,[dateFormatter stringFromDate:[NSDate date]],message];
    self.logDetailTextView.text =logInfo;
}

@end
