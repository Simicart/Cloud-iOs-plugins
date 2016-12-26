//
//  OrdersListViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/2/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "OrdersListViewController.h"
#import "ShowMenuButton.h"
#import "SearchButton.h"
#import "UIView+InputNotification.h"
#import "UIImage+ImageColor.h"
#import "MSFramework.h"
#import "SearchOrderModel.h"
#import "Price.h"
#import "Account.h"

#define NUMBER_ORDER_ON_PAGE  10

@interface OrdersListViewController ()
@property (nonatomic) BOOL isLoadingOrder;
@property (nonatomic) BOOL userInteractionEnabled;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIControl *searchMark;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UILabel *noResultLabel;

@property (strong, nonatomic) NSMutableArray *dayPage;
@property (nonatomic) NSUInteger lastAnalysis;
- (NSDate *)dateAtIndex:(NSUInteger)index;
@property (strong, nonatomic) UIBarButtonItem *rightBarBtn;

//TileView
@property (weak , nonatomic) NSString * titleOfView;

@end

@implementation OrdersListViewController{
    // Johan
    SearchOrderModel *searchOrderModel;
    BOOL isFirstLoad;
    // End
}

@synthesize orderRespone, arrOrder;
@synthesize isLoadingOrder, userInteractionEnabled;
@synthesize searchBar = _searchBar, searchMark, animation, noResultLabel;

@synthesize dayPage, lastAnalysis;

@synthesize editViewController;
@synthesize orderList, searchTerm;

@synthesize rightBarBtn;
@synthesize titleOfView;


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self cleanData];
    self.userInteractionEnabled = YES;
    self.isLoadingOrder = NO;
    
    // First time load Order
    [self loadOrders];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.tableView.rowHeight = 88;
    
    // self.tableView.sectionHeaderHeight = 30;
    
    self.userInteractionEnabled = YES;
    
    // Johan
    orderRespone = [NSMutableDictionary new];
    arrOrder = [NSMutableArray new];
    // End
    
    
    self.isLoadingOrder = NO;
    
    // Navigation Button and Title
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[ShowMenuButton alloc] initMenuButton]];
    
    if(titleOfView){
        self.title = NSLocalizedString(titleOfView, nil);
    }else{
         self.title = NSLocalizedString(@"Orders", nil);
    }

    SearchButton *searchButton = [[SearchButton alloc] initSearchButton];
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    self.navigationItem.rightBarButtonItem = search;
    [searchButton addTarget:self action:@selector(showSearchBar) forControlEvents:UIControlEventTouchUpInside];
    rightBarBtn = search;
    
    // Search order
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 427, 65)];
    
    if(titleOfView){
       self.searchBar.placeholder = NSLocalizedString(@"Search Hold Orders", nil);
    }else{
       self.searchBar.placeholder = NSLocalizedString(@"Search Orders", nil);
    }
    
    self.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor barBackgroundColor]];
   // self.searchBar.tintColor = [UIColor barBackgroundColor];
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = YES;
    self.searchBar.hidden = YES;
    self.searchBar.alpha = 0.0;
    self.searchBar.tintColor =  [UIColor whiteColor];
    [self.parentViewController.view addSubview:self.searchBar];

    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableCancelButton) name:UIKeyboardDidHideNotification object:nil];
    
    self.searchMark = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 427, 768)];
    self.searchMark.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    self.searchMark.hidden = YES;
    [self.view addSubview:self.searchMark];
    [self.searchMark addTarget:self action:@selector(cancelSearch) forControlEvents:UIControlEventTouchUpInside];
    
    self.animation = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 427, 176)];
    self.animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.searchMark addSubview:self.animation];
    
    noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 427, 62)];
    noResultLabel.text = NSLocalizedString(@"No order found!", nil);
    noResultLabel.textAlignment = NSTextAlignmentCenter;
    
    // Loading more
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadOrders) name:@"OrderListViewControllerScolling" object:nil];
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OrderListViewControllerScolling" object:nil];
    }];
}


#pragma mark - search orders
- (void)showSearchBar
{
    searchMark.hidden = NO;
    self.searchBar.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.searchBar.alpha = 1.0;
    }];
    [self.searchBar becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:self.searchTerm]) {
        self.isLoadingOrder = NO;
        return;
    }
    if (self.isLoadingOrder) {
        return;
    }
    if (!self.userInteractionEnabled) {
        self.isLoadingOrder = YES;
        return;
    }
    // Show search mask
    self.searchMark.hidden = NO;
    self.searchTerm = searchText;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [self.animation startAnimating];
    
    // Search order
    
    orderList.searchTerm = self.searchTerm;
    [orderRespone setValue:self.searchTerm forKey:@"keyword"];
    
    if (self.dayPage) {
        [self.dayPage removeAllObjects];
    }
    self.lastAnalysis = 0;
    self.isLoadingOrder = NO;
    [orderRespone setValue:@"1" forKey:@"current_page"];
    [arrOrder removeAllObjects];
    [self.tableView.infiniteScrollingView startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadOrdersThread) object:nil] start];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
}

- (void)searchKeyboardWillHide:(NSNotification *)note
{
    if (self.searchBar.text == nil
        || [self.searchBar.text isEqualToString:@""]
    ) {
        [self cancelSearch];
    }
}

- (void)enableCancelButton
{
    for (UIView *btn in self.searchBar.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            [(UIButton *)btn setEnabled:YES];
        }
    }
}

- (void)cancelSearch
{
    [orderRespone setValue:@"" forKey:@"keyword"];
    
    self.searchMark.hidden = YES;
    [UIView animateWithDuration:0.25 animations:^{
        self.searchBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.searchBar.hidden = YES;
    }];
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    
    self.searchTerm = @"";
    if (self.dayPage) {
        [self.dayPage removeAllObjects];
    }
    self.lastAnalysis = 0;
    self.isLoadingOrder = NO;
    [orderRespone setValue:@"1" forKey:@"current_page"];
    [arrOrder removeAllObjects];
    [self loadOrders];
}

#pragma mark - load orders
- (void)loadOrders
{
    if (!self.userInteractionEnabled) {
        return;
    }
    if ([Account permissionValue:@"order.list"] == 4) {
        noResultLabel.text = NSLocalizedString(@"You do not have permission to view the order list.", nil);
        [self.view addSubview:noResultLabel];
        noResultLabel.hidden = NO;
        self.navigationItem.rightBarButtonItem = nil;
        return;
    }
    noResultLabel.text = NSLocalizedString(@"No order found!", nil);
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    [self.tableView.infiniteScrollingView startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadOrdersThread) object:nil] start];
}

- (void)loadOrdersThread
{
    // Johan
    NSInteger count = arrOrder.count;
    NSInteger total = ([[orderRespone valueForKey:@"total"] integerValue]);
    
    BOOL isLoad = [[orderRespone valueForKey:@"is_load"] boolValue];
    
    isFirstLoad = count ? NO : YES;
    if (!isLoad) {
        self.userInteractionEnabled = NO;
        [self requestGetListOrder];
    } else if (count >= total) {
        [self.tableView.infiniteScrollingView stopAnimating];
        return;
    } else {
        NSInteger page = [[orderRespone valueForKey:@"current_page"] integerValue];
        page++;
        [orderRespone setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"current_page"];
        self.userInteractionEnabled = NO;
        [self requestGetListOrder];
    }
    self.userInteractionEnabled = YES;
    // End
}

- (void) requestGetListOrder{
    searchOrderModel = [SearchOrderModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetOrder:) name:@"DidGetOrder" object:searchOrderModel];
    [searchOrderModel getOrder:[orderRespone valueForKey:@"current_page"] limit:[orderRespone valueForKey:@"number_page"] keySearch:[orderRespone valueForKey:@"keyword"] isHoldOrder:[orderRespone valueForKey:@"hold_order"]];
}

- (void) didGetOrder:(NSNotification *) noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidGetOrder" object:searchOrderModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    [self.animation stopAnimating];
    noResultLabel.hidden = YES;
    [self.tableView.infiniteScrollingView stopAnimating];
    if([respone.status isEqualToString:@"SUCCESS"]){
        NSMutableDictionary * returnData = [respone valueForKey:@"data"];
        [self parseData:returnData];
        [orderRespone setValue:@"1" forKey:@"is_load"];
        NSInteger count = ((NSMutableArray*)[orderRespone objectForKey:@"arr_order"]).count;
        NSString *keyword = [orderRespone valueForKey:@"keyword"];
        if (count) {
            noResultLabel.hidden = YES;
        } else {
            [self.view addSubview:noResultLabel];
            noResultLabel.hidden = NO;
        }
        
        if (self.isLoadingOrder) {
            self.isLoadingOrder = NO;
            [self searchBar:self.searchBar textDidChange:self.searchBar.text];
        } else {
            [self reloadData];
            [self.animation stopAnimating];
            self.searchMark.hidden = YES;
            // select latest order to view
            if (keyword && count) {
                if (isFirstLoad) {
                    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
                    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                } else if (self.editViewController.currentIndexPath) {
                    [self.tableView selectRowAtIndexPath:self.editViewController.currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
        [self reloadData];
    }else{
        NSInteger page = [[orderRespone valueForKey:@"current_page"] integerValue];
        page--;
        [orderRespone setValue:[NSString stringWithFormat:@"%ld",(long)page] forKey:@"current_page"];
        [Utilities alert:@"Load Order" withMessage:respone.message[0]];
    }
}

- (void) parseData:(NSMutableDictionary *)data{
    NSMutableArray *sortArr = [NSMutableArray new];
    for (NSString *key in [data allKeys]) {
        if([key isEqual:@"total"]){
            [orderRespone setObject:[data valueForKey:key] forKey:@"total"];
        }else{
            Order *order = [Order new];
            [order setValue:key forKey:@"id"];
            [order addEntriesFromDictionary:[data objectForKey:key]];
            [sortArr addObject:order];
        }
    }
    
    NSArray * arr = [sortArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([[obj1 valueForKey:@"id"] integerValue] > [[obj2 valueForKey:@"id"] integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if ([[obj1 valueForKey:@"id"] integerValue] < [[obj2 valueForKey:@"id"] integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];

    
    [arrOrder addObjectsFromArray:arr];
    
    [orderRespone setObject:arrOrder forKey:@"arr_order"];
}

- (void)cleanData
{
    if (self.dayPage) {
        [self.dayPage removeAllObjects];
    }
    self.lastAnalysis = 0;
    self.isLoadingOrder = NO;
    if (orderRespone) {
        [orderRespone setValue:@"1" forKey:@"current_page"];
        [orderRespone removeAllObjects];
        [arrOrder removeAllObjects];
    }
    
    [orderRespone setValue:@"1" forKey:@"current_page"];
    [orderRespone setValue:@"15" forKey:@"number_page"];
    [orderRespone setValue:@"" forKey:@"keyword"];
    [orderRespone setValue:@"0" forKey:@"is_load"];
    if(self.isHoldOrder){
        [orderRespone setValue:@"1" forKey:@"hold_order"];
    }else{
        [orderRespone setValue:@"0" forKey:@"hold_order"];
    }
    [self.tableView reloadData];
}

- (void)reloadData
{
    NSInteger count = arrOrder.count;
    if(count){
        // Analysis Result
        NSDate *currentDate = nil;
        NSMutableArray *lastPage = nil;
        
        if (self.dayPage == nil) {
            self.dayPage = [NSMutableArray new];
        } else if ([self.dayPage count]) {
            lastPage = [self.dayPage lastObject];
            currentDate = [lastPage objectAtIndex:2];
        }
        for (; lastAnalysis < count; lastAnalysis++) {
            NSDate *orderDate = [self dateAtIndex:lastAnalysis];
            if (currentDate == nil || ![currentDate isEqual:orderDate]) {
                currentDate = orderDate;
                // Create new page
                NSNumber *location = [NSNumber numberWithInteger:lastAnalysis];
                NSNumber *length = [NSNumber numberWithInteger:1];
                lastPage = [[NSMutableArray alloc] initWithObjects:location, length, currentDate, nil];
                [dayPage addObject:lastPage];
            } else {
                // Update old page
                NSNumber *length = (NSNumber *)[lastPage objectAtIndex:1];
                length = [NSNumber numberWithInteger:([length integerValue] + 1)];
                [lastPage setObject:length atIndexedSubscript:1];
            }
        }
        // Reload Table View
        [self.tableView reloadData];
    }
}

- (NSDate *)dateAtIndex:(NSUInteger)index
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *orderDate = [dateFormatter dateFromString:[[arrOrder objectAtIndex:index] objectForKey:@"created_at"]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dayString = [dateFormatter stringFromDate:orderDate];
    return [dateFormatter dateFromString:dayString];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dayPage count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *page = [dayPage objectAtIndex:section];
    return [[page objectAtIndex:1] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"OrderListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.numberOfLines = 2;
        cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 66)];
        
        UILabel *orderTotal = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 200, 18)];
        orderTotal.font = [UIFont boldSystemFontOfSize:18];
        orderTotal.tag = 2;
        orderTotal.highlightedTextColor = [UIColor whiteColor];
        orderTotal.textColor =[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.00f];
        
        [cell.accessoryView addSubview:orderTotal];
        
        UILabel *createTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 200, 18)];
        createTime.font = [UIFont systemFontOfSize:14];
        createTime.tag = 3;
        //createTime.textColor = [UIColor blueColor] ;//[UIColor grayColor];
        createTime.highlightedTextColor = [UIColor whiteColor];
        [cell.accessoryView addSubview:createTime];
        
        UILabel *productSkus = [[UILabel alloc] initWithFrame:CGRectMake(60, 65, tableView.frame.size.width - 80, 16)];
        productSkus.font = [UIFont systemFontOfSize:15];
        productSkus.tag = 4;
        //productSkus.textColor = [UIColor greenColor];//[UIColor grayColor];
        productSkus.highlightedTextColor = [UIColor whiteColor];
        [cell.contentView addSubview:productSkus];
    }
    
    NSArray *page = [dayPage objectAtIndex:[indexPath section]];
    NSUInteger index = [[page objectAtIndex:0] integerValue] + [indexPath row];
    Order *order = [arrOrder objectAtIndex:index];
    
    cell.textLabel.text = [NSString stringWithFormat:@"# %@", [order objectForKey:@"increment_id"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[order objectForKey:@"customer_name"]];
    
    if ([MSValidator isEmptyString:[order objectForKey:@"customer_name"]]) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",[order objectForKey:@"org_customer_name"]];
    }
    
    UILabel *orderTotal = (UILabel *)[cell.accessoryView viewWithTag:2];
    orderTotal.text = [Price format:[order objectForKey:@"grand_total"]];
    
    UILabel *createdTime = (UILabel *)[cell.accessoryView viewWithTag:3];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *orderDate = [dateFormatter dateFromString:[order objectForKey:@"created_at"]];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    createdTime.text = [dateFormatter stringFromDate:orderDate];
    
    cell.imageView.image = [UIImage imageNamed:[self getStatusImage:order]];
    
    UILabel *productSkus = (UILabel *)[cell.contentView viewWithTag:4];
    productSkus.text = [order objectForKey:@"product_skus"];
    
    cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSString *)getStatusImage:(Order *)order
{
    NSString *status = [NSString stringWithFormat:@"%@",[order objectForKey:@"status"]];
    if ([status isEqualToString:@"pending"]) {
        return @"order_pending.png";
    } else if ([status isEqualToString:@"complete"]) {
        return @"order_complete.png";
    } else if ([status isEqualToString:@"canceled"] || [status isEqualToString:@"closed"]) {
        return @"order_closed.png";
    } else if ([status isEqualToString:@"holded"]) {
       return @"status_holded";
    }
    
    return @"order_processing.png";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(!dayPage || dayPage.count == 0){
        return @"";
    }
    
    if([dayPage objectAtIndex:section]){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        NSArray *page = [dayPage objectAtIndex:section];
        return [dateFormatter stringFromDate:[page objectAtIndex:2]];
    }
    else{
        return @"";
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *page = [dayPage objectAtIndex:[indexPath section]];
    NSUInteger index = [[page objectAtIndex:0] integerValue] + [indexPath row];
    Order *order = [arrOrder objectAtIndex:index];
    
    // Show order detail
    self.editViewController.currentIndexPath = indexPath;
    [self.editViewController assignOrder:order];
}

#pragma mark - set Title of ViewController
-(void)setTitleOfViewController:(NSString *)title{
    titleOfView = title;
}

-(void)cleanCacheHoldOrder{
    if(searchOrderModel){
        [searchOrderModel removeCacheHoldOrder];
    }
}
@end
