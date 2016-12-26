//
//  SearchCustomerVC.m
//  RetailerPOS
//
//  Created by mac on 3/3/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SearchCustomerVC.h"
#import "CustomerInfo.h"
#import "SearchCustomerCell.h"
#import "CustomerEditViewController.h"
#import "MSNavigationController.h"

@interface SearchCustomerVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateCustomer;

@end

@implementation SearchCustomerVC
{
    NSArray * customerInfoList;
}


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    //[self updateDataFromServer];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initDefault];
    
    [self loadDataLocal];
    
   // [self updateDataFromServer];
    
    [self.searchBar becomeFirstResponder];
}

-(void)initDefault{
    self.btnCreateCustomer.layer.cornerRadius=5.0;
    self.btnCreateCustomer.backgroundColor = [UIColor barBackgroundColor];
    
    self.tblView.delegate=self;
    self.tblView.dataSource=self;
    self.searchBar.delegate=self;
    
    self.searchBar.searchBarStyle =UISearchBarStyleMinimal;
    
}

-(void)loadDataLocal{
    
    customerInfoList =[CustomerInfo MR_findAllSortedBy:@"customer_name" ascending:YES];
    [self.tblView reloadData];
}

-(void)updateDataFromServer{
    [[APIManager shareInstance] getCustomer:@"" Callback:^(BOOL success, id result) {
        if(!success)
            return ;
        
        NSDictionary * listData =[result objectForKey:@"data"];
        if(listData && [listData isKindOfClass:[NSDictionary class]]){
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("customerInfoList", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self insertDataBase:listData];
                    
                });
            });
        }
        
    }];
}

-(void)insertDataBase:(NSDictionary *) listData{
    
  //  DLog(@"result:%@",listData);

    
    NSArray * allKeys = [listData allKeys];
    if(allKeys && allKeys.count >0){
        
        //Xoa du lieu cu
        [CustomerInfo truncateAll];
        
        for(NSString * key in allKeys){
            
            id dict =[listData objectForKey:key];
                        
            if(dict && [dict isKindOfClass:[NSDictionary class]]){
                
               // NSLog(@"key:%@  value:%@",key,dict);
                
                CustomerInfo * customerInfo =[CustomerInfo MR_createEntity];
                customerInfo.customer_id=key;
                customerInfo.customer_name=[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
                customerInfo.email=[NSString stringWithFormat:@"%@",[dict objectForKey:@"email"]];
                customerInfo.group_id=[NSString stringWithFormat:@"%@",[dict objectForKey:@"group_id"]];
                customerInfo.telephone=[NSString stringWithFormat:@"%@",[dict objectForKey:@"telephone"]];
                
            }
            
        }
        
        [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
        [self loadDataLocal];
    }
}

#pragma mark - table delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(customerInfoList && customerInfoList.count >0){
        return customerInfoList.count;
    }
    
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString * cellID =@"SearchCustomerCell";
    SearchCustomerCell * cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = (SearchCustomerCell *)[[[NSBundle mainBundle] loadNibNamed:@"SearchCustomerCell" owner:nil options:nil] firstObject];
    }
    
    [cell setData:[customerInfoList objectAtIndex:indexPath.row]];
    
    cell.indexLabel.text =[NSString stringWithFormat:@"%d",(int)(indexPath.row +1)];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([indexPath row] > customerInfoList.count) {
        return;
    }
    
    CustomerInfo * customerInfo =[customerInfoList objectAtIndex:indexPath.row];
    
    Customer *customer = [Customer new];
    [customer setObject:customerInfo.customer_id forKey:@"id"];
    [customer setObject:customerInfo.customer_id forKey:@"customer_id"];
    
    [customer setObject:customerInfo.customer_name forKey:@"name"];
    [customer setObject:customerInfo.group_id forKey:@"group_id"];
    [customer setObject:customerInfo.email forKey:@"email"];
    [customer setObject:customerInfo.telephone forKey:@"telephone"];
    
    [[[NSThread alloc] initWithTarget:[Quote sharedQuote] selector:@selector(assignCustomerOffline:) object:customer] start];
    
    [self.itemTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    [self.listPopover dismissPopoverAnimated:YES];
    
}


#pragma mark - UI SearchBar delegate

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
       [self.view endEditing:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self showResultSearch];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

#pragma mark - show search results
-(void)showResultSearch{
    NSString * keySearch =self.searchBar.text;
    NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"(%@=='') || (customer_name contains[cd] %@) || (email contains[cd] %@) || (telephone contains[cd] %@)",keySearch,keySearch,keySearch,keySearch];
    customerInfoList =[CustomerInfo MR_findAllSortedBy:@"customer_name" ascending:YES withPredicate:predicate];
    [self.tblView reloadData];
}

- (IBAction)createCustomerButtonClick:(id)sender {
    
    [self.itemTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    [self.listPopover dismissPopoverAnimated:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ADD_NEW_CUSTOMER object:nil];
    
//    CustomerEditViewController *customerEdit = [[CustomerEditViewController alloc] init];
//    MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:customerEdit];
//    navController.modalPresentationStyle = UIModalPresentationFormSheet;

}


#pragma mark - Popover controller delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    [self.itemTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    return YES;
}

@end
