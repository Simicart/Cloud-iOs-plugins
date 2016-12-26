//
//  OrderDetailViewController.m
//  RetailerPOS
//
//  Created by mac on 4/26/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "OrderDetailViewController.h"

#import "OrderInformationCell.h"
#import "OrderCustomerShippingCell.h"
#import "OrderProductDetailCell.h"

#define HEIGHT_ORDER_INFORMATION_CELL 296
#define HEIGHT_ORDER_CUSTOMER_SHIPPING_CELL 189
#define HEIGHT_ORDER_PRODUCT_DETAIL_CELL 102

@interface OrderDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(section == 2){
        return 5;
    }
    
    return 1;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0){
        return HEIGHT_ORDER_INFORMATION_CELL;
    }else if(indexPath.section == 1){
        return HEIGHT_ORDER_CUSTOMER_SHIPPING_CELL;
    }else if(indexPath.section == 2){
        return HEIGHT_ORDER_PRODUCT_DETAIL_CELL;
    }
    
    return 44;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell ;
    
    if(indexPath.section == 0){
        cell =(OrderInformationCell *)[[[NSBundle mainBundle] loadNibNamed:@"OrderInformationCell" owner:nil options:nil] firstObject];
        
    }else if(indexPath.section == 1){
        cell =(OrderCustomerShippingCell *)[[[NSBundle mainBundle] loadNibNamed:@"OrderCustomerShippingCell" owner:nil options:nil] firstObject];
        
    }else if(indexPath.section == 2){
        cell =(OrderProductDetailCell *)[[[NSBundle mainBundle] loadNibNamed:@"OrderProductDetailCell" owner:nil options:nil] firstObject];
        
    }
    
    cell.backgroundColor =[UIColor groupTableViewBackgroundColor];
    
    return cell;
}



@end
