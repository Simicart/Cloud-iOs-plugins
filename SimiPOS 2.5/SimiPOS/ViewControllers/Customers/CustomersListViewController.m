//
//  CustomersListViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/27/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CustomersListViewController.h"
#import "CustomerInfoViewController.h"
#import "ShowMenuButton.h"
#import "SearchButton.h"
#import "MSFramework.h"
#import "UIImage+ImageColor.h"

#import "SearchCustomerCell.h"

//Ravi
#import "SearchCustomerModel.h"
//End

#define NUMBER_CUSTOMER_ON_PAGE     15

@interface CustomersListViewController ()
@property (nonatomic) BOOL isLoadingCustomer;
@property (nonatomic) BOOL userInteractionEnabled;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UILabel *noResultLabel;
@property (strong, nonatomic) NSNotification *noteCache;

@property (nonatomic) BOOL viewOrderCustomer;
- (void)orderCustomerDetail:(NSNotification *)note;
@end

@implementation CustomersListViewController
@synthesize editController;
@synthesize isLoadingCustomer, userInteractionEnabled;
@synthesize searchBar = _searchBar, animation, noResultLabel;

@synthesize customerList, searchTerm;
@synthesize noteCache;
@synthesize viewOrderCustomer;

- (id)init
{
    if (self = [super init]) {
        // Init listener
        viewOrderCustomer = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createTopBarMenu];
    
    //self.tableView.rowHeight = 54;
    self.userInteractionEnabled = YES;
    
    customerList = [[CustomerCollection alloc] init];
    customerList.pageSize = NUMBER_CUSTOMER_ON_PAGE;
    customerList.curPage = 1;
    
    self.isLoadingCustomer = NO;
    self.searchTerm = nil;
    
    [self registerNotification];
    
    self.animation = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 427, 176)];
    self.animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 427, 51)];
    noResultLabel.text = NSLocalizedString(@"No customer found!", nil);
    noResultLabel.textAlignment = NSTextAlignmentCenter;
    
    [self loadCustomer];
}

-(void)registerNotification{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCustomer) name:@"CustomersListViewControllerScolling" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCustomerDetail:) name:@"ViewOrderCustomerDetail" object:nil];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CustomersListViewControllerScolling" object:nil];
    }];
    
}

-(void)createTopBarMenu{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Search Customer
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 427, 65)];
    self.searchBar.placeholder = NSLocalizedString(@"Search Customers", nil);
    self.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor barBackgroundColor]];
    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = YES;
    self.searchBar.hidden = YES;
    
    [self.parentViewController.view addSubview:self.searchBar];
    
    // Navigation Button and Title
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[ShowMenuButton alloc] initMenuButton]];
    
    self.title = NSLocalizedString(@"Customers", nil);
    
    SearchButton *searchButton = [[SearchButton alloc] initSearchButton];
    [searchButton addTarget:self action:@selector(showSearchBar) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:searchButton];

    self.navigationItem.rightBarButtonItems = @[
                                                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self.editController action:@selector(addNewCustomer)],
                                                search
                                                ];

    
}

- (void)orderCustomerDetail:(NSNotification *)note
{
    if (viewOrderCustomer) {
        return;
    }
    NSDictionary *order = [note object];
    if (order == nil) {
        return;
    }
    viewOrderCustomer = YES;
    if (self.editController.createOrderBtn == nil) {
        noteCache = note;
        return;
    }
    // View customer detail
    Customer *customer = [Customer new];
    [customer setValue:[order objectForKey:@"customer_id"] forKey:@"id"];
    if (![MSValidator isEmptyString:[order objectForKey:@"customer_email"]]) {
        [customer setValue:[order objectForKey:@"customer_email"] forKey:@"email"];
    }
    self.editController.currentIndexPath = nil;
    [self.editController assignCustomer:customer];
}

#pragma mark - load customer list
- (void)loadCustomer
{
    if (!self.userInteractionEnabled) {
        return;
    }
    [self.tableView.infiniteScrollingView startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadCustomerThread) object:nil] start];
}

- (void)loadCustomerThread
{
    //Ravi new network
    NSString *index = @"1";
    NSString *length = @"15";
    if (self.searchTerm == nil) {
        self.searchTerm = @"";
    }
    if (!customerList.loadCollectionFlag) {
        self.userInteractionEnabled = NO;
    } else if ([customerList getSize] >= [customerList getTotalItems]) {
        [self.tableView.infiniteScrollingView stopAnimating];
        return;
    } else {
        customerList.curPage++;
        self.userInteractionEnabled = NO;
        index = [NSString stringWithFormat:@"%lu",(unsigned long)customerList.curPage];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSearchCustomer:) name:@"DidSearchCustomer" object:nil];
    SearchCustomerModel *searchCustomerModel = [SearchCustomerModel new];
    [searchCustomerModel searchCustomerWidthKeySearch:self.searchTerm index:index length:length];
    return;
    //End
    
    
    
    
    if (!customerList.loadCollectionFlag) {
        self.userInteractionEnabled = NO;
        [customerList partialLoad];
    } else if ([customerList getSize] >= [customerList getTotalItems]) {
        [self.tableView.infiniteScrollingView stopAnimating];
        return;
    } else {
        customerList.curPage++;
        self.userInteractionEnabled = NO;
        [customerList partialLoad];
    }
    self.userInteractionEnabled = YES;
    if ([customerList getSize]) {
        noResultLabel.hidden = YES;
    } else {
        [self.view addSubview:noResultLabel];
        noResultLabel.hidden = NO;
    }
    [self.tableView.infiniteScrollingView stopAnimating];
    
    
    if (self.isLoadingCustomer) {
        self.isLoadingCustomer = NO;
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    } else {
        [self.tableView reloadData];
        [self.animation stopAnimating];

        if (![customerList hasSearchTerm] && [customerList getSize]
            && !viewOrderCustomer && [customerList getSize] <= NUMBER_CUSTOMER_ON_PAGE
            ) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        } else {
            viewOrderCustomer = NO;
            if (noteCache) {
                [self orderCustomerDetail:noteCache];
                noteCache = nil;
            }
        }
    }
}

- (void)cleanData
{
    self.isLoadingCustomer = NO;
    if (customerList) {
        customerList.curPage = 1;
        [customerList clear];
    }
    [self.tableView reloadData];
}

#pragma mark - search bar
-(void)showSearchBar
{
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //Ravi
    return;
    //End
    
    
    if ([searchText isEqualToString:self.searchTerm]) {
        self.isLoadingCustomer = NO;
        return;
    }
    if (self.isLoadingCustomer) {
        return;
    }
    if (!self.userInteractionEnabled) {
        self.isLoadingCustomer = YES;
        return;
    }
    // Show Search Mark

    [self.animation startAnimating];
    
    // Search customer
    self.searchTerm = searchText;
    customerList.searchTerm = self.searchTerm;
    
    [customerList clear];
    customerList.curPage = 1;
    
    [self loadCustomer];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    
    if ([searchBar.text isEqualToString:self.searchTerm]) {
        self.isLoadingCustomer = NO;
        return;
    }
    if (self.isLoadingCustomer) {
        return;
    }
    if (!self.userInteractionEnabled) {
        self.isLoadingCustomer = YES;
        return;
    }
    // Show Search Mark
    
    [self.animation startAnimating];
    
    // Search customer
    self.searchTerm = searchBar.text;
    customerList.searchTerm = self.searchTerm;
    
    [customerList clear];
    customerList.curPage = 1;
    
    [self loadCustomer];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
}

- (void)cancelSearch
{
    customerList.searchTerm = nil;
    self.searchBar.hidden = YES;
    
    self.searchBar.text = nil;
    [self.searchBar resignFirstResponder];
    
    if (self.searchTerm) {
        self.searchTerm = nil;
        self.isLoadingCustomer = NO;
        customerList.curPage = 1;
        [customerList clear];
        [self loadCustomer];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [customerList getSize];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // johan fix bug
    NSDictionary *customer = [customerList objectAtIndex:indexPath.row];
    
//    NSString *name = [[customer valueForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSString *email = [[customer valueForKey:@"email"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSString *phone = [[customer valueForKey:@"telephone"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString *name = [[NSString stringWithFormat:@"%@",[customer valueForKey:@"name"]]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *email = [[NSString stringWithFormat:@"%@",[customer valueForKey:@"email"]]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *phone = [[NSString stringWithFormat:@"%@",[customer valueForKey:@"telephone"]]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    
    NSMutableArray *heightCustomer = [[NSMutableArray alloc] init];
    if(name != nil && ![name isEqualToString:@""] && ![name isEqualToString:@"<null>"]){
        [heightCustomer addObject:name];
    }
    
    if(email != nil && ![email isEqualToString:@""]){
        [heightCustomer addObject:email];
    }
    
    if(phone != nil && ![phone isEqualToString:@""] && ![phone isEqualToString:@"<null>"]){
        [heightCustomer addObject:phone];
    }
    
    return (heightCustomer.count * 33.3);
    // end
//    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString * cellID =@"SearchCustomerCell";
    SearchCustomerCell * cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = (SearchCustomerCell *)[[[NSBundle mainBundle] loadNibNamed:@"SearchCustomerCell" owner:nil options:nil] firstObject];
    }
    
    NSDictionary *customer = [customerList objectAtIndex:[indexPath row]];
    
    [cell setDataWithDict:customer];
    
    cell.indexLabel.text =[NSString stringWithFormat:@"%d",(int)(indexPath.row +1)];
    // johan fix bug.
    NSString *customerName = [[customerList objectAtIndex:indexPath.row] valueForKey:@"name"];
    
    if ([customerName isKindOfClass:[NSNull class]]) {
        customerName = @"";
    }else{
        customerName = [customerName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    if(customerName == nil || [customerName isEqualToString:@""]){
        [cell.email setFrame:cell.name.frame];
    }
    
    NSString *customerPhone = [[customerList objectAtIndex:indexPath.row] valueForKey:@"telephone"] ;
    if ([customerPhone isKindOfClass:[NSNull class]]) {
        customerPhone = @"";
    }else{
        customerPhone = [customerPhone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if(customerPhone == nil || [customerPhone isEqualToString:@""]){
        cell.phoneIcon.hidden = YES;
    }
    // end
    return cell;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideKeyboard" object:nil];
    Customer *customer = [customerList objectAtIndex:[indexPath row]];
    self.editController.currentIndexPath = indexPath;
    [self.editController assignCustomer:customer];
}

#pragma mark - When add customer success then show current info
-(void)findCustomer:(Customer *)customer
{
    if(customer){
        [self.editController assignCustomer:customer];
        //self.tableView
        [self.tableView deselectRowAtIndexPath:[self.tableView
                                                indexPathForSelectedRow] animated: YES];
    }
}

//Ravi

- (void)didSearchCustomer : (NSNotification*)noti{
    self.userInteractionEnabled = YES;
    [self.tableView.infiniteScrollingView stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didSearchCustomer - %@",respone.data);
        
        customerList.loadCollectionFlag = YES;
        for (NSString *key in [respone.data allKeys]) {
            if ([key isEqualToString:@"total"]) {
                customerList.totalItems = [[respone.data valueForKey:key] integerValue];
            }else if ([key isEqualToString:@"customer_default_id"]){
                //customer_default_id
            }else{
                [customerList.sortedIndex addObject:key];
                Customer *customer = [Customer new];
                [customer addEntriesFromDictionary:[respone.data objectForKey:key]];
                [customer setValue:key forKey:@"id"];
                [customerList setObject:customer forKey:key];
            }
        }
        
        if ([customerList getSize]) {
            noResultLabel.hidden = YES;
        } else {
            [self.view addSubview:noResultLabel];
            noResultLabel.hidden = NO;
        }
        
        [self.tableView reloadData];
        
        
        if (![customerList hasSearchTerm] && [customerList getSize]
            && !viewOrderCustomer && [customerList getSize] <= NUMBER_CUSTOMER_ON_PAGE
            ) {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        } else {
            viewOrderCustomer = NO;
            if (noteCache) {
                [self orderCustomerDetail:noteCache];
                noteCache = nil;
            }
        }
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//End

@end
