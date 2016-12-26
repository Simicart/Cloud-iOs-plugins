//
//  PaymentViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/28/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "PaymentViewController.h"
#import "Quote.h"

#import "CreditCardFormController.h"
#import "PurchaseOrderFormController.h"
#import "OfflinePaymentFormController.h"

#import "WebposPaymentsFormController.h"
#import "WebposMultipaymentsFormController.h"

#import "MRPayment.h"

@implementation PaymentViewController
{
    NSInteger rowIndexSelected;
}

@synthesize checkout, collection;

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    collection =[MRPayment findAll];
   
    self.tableView.rowHeight = 80;

    //set defaul payment value
    rowIndexSelected =0;
    
    if(self.collection && self.collection.count >0){
         MRPayment *mrPayment = [self.collection objectAtIndex:rowIndexSelected];
         [Quote sharedQuote].mrPayment =mrPayment;
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(collection && collection.count >0){
        return collection.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"PaymentMethodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont systemFontOfSize:20];
    }
    
    MRPayment *mrPayment = [self.collection objectAtIndex:[indexPath row]];
    
    if(indexPath.row == rowIndexSelected){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = mrPayment.title;
    
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    rowIndexSelected =indexPath.row;
     MRPayment *mrPayment = [self.collection objectAtIndex:[indexPath row]];
    [Quote sharedQuote].mrPayment =mrPayment;
    
    
    [tableView reloadData];
}

@end
