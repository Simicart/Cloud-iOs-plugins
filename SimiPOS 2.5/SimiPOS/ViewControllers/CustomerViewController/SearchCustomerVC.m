//
//  SearchCustomerVC.m
//  SimiPOS
//
//  Created by mac on 3/3/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SearchCustomerVC.h"
#import "CustomerInfo.h"
#import "SearchCustomerCell.h"
#import "CustomerEditViewController.h"
#import "MSNavigationController.h"

//Ravi
#import "SearchCustomerModel.h"
//End

@interface SearchCustomerVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblView;
// lionel added
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *animation;
@property (weak, nonatomic) IBOutlet UILabel *loadingLb;
// end
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateCustomer;


@end

@implementation SearchCustomerVC
{
    NSArray * customerInfoList;
}


-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    [self updateDataFromServer];
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
    self.animation.hidden = YES;
    self.loadingLb.hidden = YES;
    
    self.searchBar.delegate=self;
    self.searchBar.searchBarStyle =UISearchBarStyleMinimal;
    
}

-(void)loadDataLocal{
    
    //Ravi fix bug search not working
    if (self.searchBar.text) {
        [self showResultSearch];
    }else{
        customerInfoList =[CustomerInfo MR_findAllSortedBy:@"customer_name" ascending:YES];
        [self.tblView reloadData];
    }
    //End
    
//    customerInfoList =[CustomerInfo MR_findAllSortedBy:@"customer_name" ascending:YES];
//    [self.tblView reloadData];
}

-(void)updateDataFromServer{
    // lionel added
//    if(customerInfoList.count == 0) {
    self.animation.hidden = NO;
    [self.animation startAnimating];
    self.loadingLb.hidden = NO;
    self.tblView.hidden = YES;
//    }
    // end
    
    //Ravi new network
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSearchCustomer:) name:@"DidSearchCustomer" object:nil];
    SearchCustomerModel *searchCustomerModel = [SearchCustomerModel new];
    [searchCustomerModel searchCustomerWidthKeySearch:@""index:@"1" length:@"999999"];
    return;
    //End
    
    
    [[APIManager shareInstance] getCustomer:@"" Callback:^(BOOL success, id result) {
        // lionel added
        [self.animation stopAnimating];
        self.animation.hidden = YES;
        self.loadingLb.hidden = YES;
        self.tblView.hidden = NO;
        // end
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
    // johan fix bug
    CustomerInfo *customer = [customerInfoList objectAtIndex:indexPath.row];
    NSString *name = [[customer valueForKey:@"customer_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [[customer valueForKey:@"email"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *phone = [[customer valueForKey:@"telephone"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *heightCustomer = [[NSMutableArray alloc] init];
    if(name != nil && ![name isEqualToString:@""] && ![name isEqualToString:@"<null>"]){
        [heightCustomer addObject:name];
    }
    
    if(email != nil && ![email isEqualToString:@""] ){
        [heightCustomer addObject:email];
    }
    
    if(phone != nil && ![phone isEqualToString:@""] && ![phone isEqualToString:@"<null>"]){
        [heightCustomer addObject:phone];
    }
    return (heightCustomer.count * 33.3);
    // end
//    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString * cellID =@"SearchCustomerCell";
    SearchCustomerCell * cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = (SearchCustomerCell *)[[[NSBundle mainBundle] loadNibNamed:@"SearchCustomerCell" owner:nil options:nil] firstObject];
    }
    
    [cell setData:[customerInfoList objectAtIndex:indexPath.row]];
    
    cell.indexLabel.text =[NSString stringWithFormat:@"%d",(int)(indexPath.row +1)];
    // johan fix bug.
    NSString *customerName = [[[customerInfoList objectAtIndex:indexPath.row] valueForKey:@"customer_name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(customerName == nil || [customerName isEqualToString:@""]){
        [cell.email setFrame:cell.name.frame];
    }
    
    if([[customerInfoList objectAtIndex:indexPath.row] valueForKey:@"telephone"] == nil || [[[customerInfoList objectAtIndex:indexPath.row] valueForKey:@"telephone"] isEqualToString:@""]){
        cell.phoneIcon.hidden = YES;
    }
    // end
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
    
    [[[NSThread alloc] initWithTarget:[Quote sharedQuote] selector:@selector(assignCustomer:) object:customer] start];
    
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

//Ravi

- (void)didSearchCustomer : (NSNotification*)noti{
    [self.animation stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didPlaceOrder - %@",respone.data);
        
        
        self.animation.hidden = YES;
        self.loadingLb.hidden = YES;
        self.tblView.hidden = NO;
        // end
        
        NSDictionary * listData = respone.data;
        if(listData && [listData isKindOfClass:[NSDictionary class]]){
            dispatch_queue_t backgroundQueue = dispatch_queue_create("customerInfoList", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self insertDataBase:listData];
                });
            });
        }
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//End

@end
