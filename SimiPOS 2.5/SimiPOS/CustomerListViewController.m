//
//  CustomerListViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/12/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CustomerListViewController.h"
#import "CustomerEditViewController.h"
#import "Quote.h"
#import "MSFramework.h"

#define NUMBER_CUSTOMER_ON_PAGE     10

@interface CustomerListViewController ()
@property (nonatomic) BOOL isLoadingCustomer;
@property (nonatomic) BOOL userInteractionEnabled;
@property (strong, nonatomic) UIControl *searchMark;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UILabel *noResultLabel;
@end

@implementation CustomerListViewController
@synthesize isLoadingCustomer, userInteractionEnabled;
@synthesize searchMark;
@synthesize animation;
@synthesize noResultLabel;

@synthesize listPopover;
@synthesize itemTableView;

@synthesize isShowedHeader;
@synthesize headerBackground;
@synthesize createButton;
@synthesize searchBar = _searchBar;

@synthesize customerList;
@synthesize searchTerm;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 54;
    self.userInteractionEnabled = YES;
    
    customerList = [[CustomerCollection alloc] init];
    customerList.pageSize = NUMBER_CUSTOMER_ON_PAGE;
    customerList.curPage = 1;
    
    self.isLoadingCustomer = NO;
    self.searchTerm = nil;
    
    headerBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 120)];
    headerBackground.backgroundColor = [UIColor backgroundColor];
    
    createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createButton setBackgroundImage:[[UIImage imageNamed:@"btn_checkout.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [createButton setBackgroundImage:[[UIImage imageNamed:@"btn_checkout_pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateHighlighted];
    [createButton setTitle:NSLocalizedString(@"Create Customer", nil) forState:UIControlStateNormal];
    [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    createButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    createButton.frame = CGRectMake(5, 5, 387, 65);
    [createButton addTarget:self action:@selector(createCustomer) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 70, 400, 50)];
    self.searchBar.placeholder = NSLocalizedString(@"Search", nil);
    self.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor backgroundColor]];
    self.searchBar.tintColor = [UIColor backgroundColor];
//    self.searchBar.translucent = NO;
    self.searchBar.delegate = self;
    
    self.searchMark = [[UIControl alloc] initWithFrame:CGRectMake(0, 120, 400, 540)];
    self.searchMark.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    self.searchMark.hidden = YES;
    
    self.animation = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 400, 54)];
    self.animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.searchMark addSubview:self.animation];
    
    noResultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 400, 54)];
    noResultLabel.text = NSLocalizedString(@"No search results", nil);
    noResultLabel.textAlignment = NSTextAlignmentCenter;
    noResultLabel.backgroundColor = [UIColor backgroundColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCustomerSuccess) name:@"CollectionCustomerPartialLoadAfter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCustomerError:) name:@"QueryException" object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCustomer) name:@"CustomerListViewControllerScolling" object:nil];
//   
//    [self.tableView addInfiniteScrollingWithActionHandler:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"CustomerListViewControllerScolling" object:nil];
//    }];
    
    // First time load
    [self.tableView.infiniteScrollingView startAnimating];
    [self loadCustomer];
}

- (void)createCustomer
{
    [self.itemTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    [self.listPopover dismissPopoverAnimated:YES];
    
    CustomerEditViewController *customerEdit = [[CustomerEditViewController alloc] init];
    MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:customerEdit];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
    navController.view.superview.frame = CGRectMake(272, 119, 480, 529);
}

#pragma mark - search customer
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
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
    self.searchMark.hidden = NO;
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
}

#pragma mark - load customer list
- (void)loadCustomer
{
    if (!self.userInteractionEnabled) {
        return;
    }
    if (!customerList.loadCollectionFlag) {
        self.userInteractionEnabled = NO;
        [[[NSThread alloc] initWithTarget:customerList selector:@selector(partialLoad) object:nil] start];
        
        //[customerList partialLoad];
        
        // [customerList partialLoad];
        return;
    }
    if ([customerList getSize] >= [customerList getTotalItems]) {
        [self.tableView.infiniteScrollingView stopAnimating];
        return;
    }
    customerList.curPage++;
    self.userInteractionEnabled = NO;
    [[[NSThread alloc] initWithTarget:customerList selector:@selector(partialLoad) object:nil] start];
   //  [customerList partialLoad];
}

- (void)loadCustomerSuccess
{
    
    self.userInteractionEnabled = YES;
    [self.tableView.infiniteScrollingView stopAnimating];
    
    if ([customerList getSize]) {
        // Hide label
        noResultLabel.hidden = YES;
    } else {
        // Show no results
        [self.view.superview addSubview:noResultLabel];
        noResultLabel.hidden = NO;
    }
    if (self.isLoadingCustomer) {
        self.isLoadingCustomer = NO;
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    } else {
        [self.tableView reloadData];
        [self reloadContentSize];
        self.searchMark.hidden = YES;
        [self.animation stopAnimating];
    }
}

- (void)loadCustomerError:(NSNotification *)note
{
    id model = [[note userInfo] objectForKey:@"model"];
    if ([customerList isEqual:model]) {
        self.userInteractionEnabled = YES;
        [self.tableView.infiniteScrollingView stopAnimating];
        if (self.isLoadingCustomer) {
            self.isLoadingCustomer = NO;
            [self searchBar:self.searchBar textDidChange:self.searchBar.text];
        } else {
            self.searchMark.hidden = YES;
            [self.animation stopAnimating];
        }
    }
}

- (CGSize)reloadContentSize
{
    CGFloat width = 400;
    CGFloat height = 174; // 66 + 54 + 54
    // Check customer collection
    if ([customerList getSize]) {
        height += ([customerList getSize] - 1) * 54;
    }
    // Max height is screen
    if (height > 660) {
        height = 660; // 174 + 9 x 54
    }
    // self.contentSizeForViewInPopover = CGSizeMake(width, height);
    // return self.contentSizeForViewInPopover;
    
    [self setPreferredContentSize:CGSizeMake(width, height)];
    
    return self.preferredContentSize;
    
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!isShowedHeader && self.view.superview != nil) {
        isShowedHeader = YES;
        
        
        [self.view.superview addSubview:headerBackground];
        [self.view.superview addSubview:createButton];
        [self.view.superview addSubview:self.searchBar];
         self.searchBar.text = self.searchTerm;
        [self.view.superview addSubview:self.searchMark];
        
        self.view.frame = CGRectMake(0, 120, self.view.frame.size.width, self.view.frame.size.height - 120);
        
        [self.tableView bringSubviewToFront:self.view];
    }
    
    return [customerList getSize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomerListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.numberOfLines = 2;
    }
    
    
    if ([customerList getSize] == 0) {
        [self reloadContentSize];
        return cell;
    }
    NSDictionary *customer = [customerList objectAtIndex:[indexPath row]];
  //  NSLog(@"customer %d :%@",indexPath.row,customer);
    
    NSMutableArray *textArray = [NSMutableArray new];
    if ([[customer objectForKey:@"name"] isKindOfClass:[NSString class]]) {
        [textArray addObject:[customer objectForKey:@"name"]];
    }
    if ([[customer objectForKey:@"telephone"] isKindOfClass:[NSString class]]) {
        [textArray addObject:[customer objectForKey:@"telephone"]];
    }
    cell.textLabel.text = [textArray componentsJoinedByString:@"\n"];
    
    cell.detailTextLabel.text = [[customer objectForKey:@"email"] isKindOfClass:[NSString class]] ? [customer objectForKey:@"email"] : nil;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] > [self.customerList getSize]) {
        return;
    }
    Customer *customer = [self.customerList objectAtIndex:[indexPath row]];
    [[[NSThread alloc] initWithTarget:[Quote sharedQuote] selector:@selector(assignCustomer:) object:customer] start];
    
    [self.itemTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    [self.listPopover dismissPopoverAnimated:YES];
}

#pragma mark - Popover controller delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    [itemTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
    self.isLoadingCustomer = NO;
    return YES;
}

@end
