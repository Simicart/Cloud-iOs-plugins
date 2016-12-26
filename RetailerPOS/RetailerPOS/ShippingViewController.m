//
//  ShippingViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/19/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ShippingViewController.h"
#import "CheckoutViewController.h"
#import "EditShippingViewController.h"
#import "Price.h"

#import "MRShipping.h"


@implementation ShippingViewController
{
    NSInteger rowItemSelected;
}
@synthesize isShowContent;

@synthesize headerView, headerLabel, headerButton;
@synthesize contentView, shippingMethods;

- (id)init
{
    if (self = [super init]) {
        self.isShowContent = NO;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // Animation and Event
    self.collection =[MRShipping MR_findAllSortedBy:@"sort_index" ascending:YES];
    
    rowItemSelected =0;
    
    if(self.collection && self.collection.count >0){
        MRShipping *mrShipping = [self.collection objectAtIndex:rowItemSelected];
        [Quote sharedQuote].mrShipping =mrShipping;
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    // Shipping View Style
    self.view.backgroundColor = [UIColor lightBorderColor];
    
	// Shipping Header
    self.headerView = [[UIControl alloc] initWithFrame:CGRectMake(1, 1, 496, 58)];
    [self.view addSubview:self.headerView];
    self.headerView.backgroundColor = [UIColor barBackgroundColor];//[UIColor backgroundColor];
    [self.headerView addTarget:self action:@selector(toggleShippingForm) forControlEvents:UIControlEventTouchUpInside];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 356, 38)];
    [self.headerView addSubview:self.headerLabel];
    self.headerLabel.backgroundColor = self.headerView.backgroundColor;
    self.headerLabel.font = [UIFont systemFontOfSize:22];
    self.headerLabel.text = NSLocalizedString(@"Shipping", nil);
    self.headerLabel.textColor = [UIColor whiteColor];
    
    self.headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.headerButton.frame = CGRectMake(366, 0, 130, 58);
    [self.headerView addSubview:self.headerButton];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Edit Address", nil)];
    [attString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, attString.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attString.length)];
    [self.headerButton setAttributedTitle:attString forState:UIControlStateNormal];
    // [self.headerButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.headerButton addTarget:self action:@selector(editShippingAddress) forControlEvents:UIControlEventTouchUpInside];
    
    // Shipping Content
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(1, 60, 496, 60)];
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = self.headerView.backgroundColor;
    self.contentView.hidden = YES;
    
    self.shippingMethods = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 496, 60) style:UITableViewStylePlain];
    self.shippingMethods.dataSource = self;
    self.shippingMethods.delegate = self;
    self.shippingMethods.rowHeight = 60;
    [self.contentView addSubview:self.shippingMethods];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCreateShipmentForThisOrder) name:KEY_CHANGE_VALUE_CREATE_SHIPMENT object:nil];
    
}

-(void)updateCreateShipmentForThisOrder{
    [self.shippingMethods reloadData];
}

- (IBAction)toggleShippingForm
{
    [UIView animateWithDuration:0.25 animations:^{
        self.isShowContent = !self.isShowContent;
        if (self.isShowContent) {
            self.contentView.hidden = NO;
        }
        CheckoutViewController *controller = (CheckoutViewController *)self.parentViewController;
        [controller reloadPaymentFormSize];
    } completion:^(BOOL finished) {
        self.contentView.hidden = !self.isShowContent;
    }];
}

- (IBAction)editShippingAddress
{
    EditShippingViewController *editShipping = [EditShippingViewController new];
    MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:editShipping];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navController animated:YES completion:nil];
    navController.view.superview.frame = CGRectMake(272, 119, 480, 529);
}

- (CGSize)reloadContentSize
{
    CGFloat width = 498;
    CGFloat height = 60;
    if ([[[Quote sharedQuote] objectForKey:@"is_virtual"] boolValue]) {
        self.view.hidden = YES;
        return CGSizeMake(width, 0);
    } else {
        self.view.hidden = NO;
    }
    if (self.isShowContent) {
        CGFloat contentHeight = 180;
        // Update depend on #shipping
        if (self.collection.count > 3) {
            contentHeight = 360;
        } else if (self.collection.count > 1) {
            contentHeight = 120 + 60 * self.collection.count;
        }
        
        self.contentView.frame = CGRectMake(1, 60, 496, contentHeight);
        self.shippingMethods.frame = CGRectMake(0, 0, 496, contentHeight);
        
        height += contentHeight + 1;
    }
    self.view.frame = CGRectMake(49, 30, width, height);
    return CGSizeMake(width, height);
}

- (void)updateShippingLabel
{
    Shipping *shippingAddress = [Quote sharedQuote].shipping;
    Shipping *currentMethod = [shippingAddress shippingMethod];
    if (currentMethod != nil) {
        self.headerLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Shipping", nil), [currentMethod objectForKey:@"carrierName"]];
    } else {
        self.headerLabel.text = NSLocalizedString(@"Shipping", nil);
    }
    // Update Shipping View
    if (self.isShowContent) {
        self.isShowContent = NO;
        [self toggleShippingForm];
    }
    [self.shippingMethods reloadData];
}

#pragma mark - Table View Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return self.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"ShippingMethodCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    if ([indexPath section]) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.accessoryView = nil;
    } else {
        cell.selectionStyle = UITableViewCellEditingStyleNone;
        cell.textLabel.text = NSLocalizedString(@"Create shipment for this order?", nil);
        
        UISwitch *isShipped = [[UISwitch alloc] init];
        [isShipped setOnTintColor:[UIColor barBackgroundColor]];
        cell.accessoryView = isShipped;
        [isShipped addTarget:self action:@selector(updateShipped:) forControlEvents:UIControlEventValueChanged];
        
        //[isShipped setOn:[[Quote sharedQuote] isShipped]];
        [isShipped setOn:BoolValue(KEY_CREATE_SHIPMENT)];
        
        cell.detailTextLabel.text = nil;
        // Shipped
        return cell;
    }
    MRShipping * mrShipping = [self.collection objectAtIndex:[indexPath row]];
    
    
    if (indexPath.row == rowItemSelected) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    cell.textLabel.text =mrShipping.name;
    
    cell.detailTextLabel.text = [Price format:mrShipping.price];
    
    return cell;
}

- (void)updateShipped:(id)sender
{
    [Quote sharedQuote].isShipped = [(UISwitch *)sender isOn];
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section) {
        return NSLocalizedString(@"Shipping Method", nil);
    }
    return NSLocalizedString(@"Shipping", nil);
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:view.bounds];
    backgroundView.backgroundColor =  [UIColor groupTableViewBackgroundColor]; //[UIColor borderColor];
    ((UITableViewHeaderFooterView *)view).backgroundView = backgroundView;
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height -1, view.bounds.size.width, 1)];
    separator.backgroundColor = [UIColor lightBorderColor];
    [backgroundView addSubview:separator];
    separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 1)];
    separator.backgroundColor = [UIColor lightBorderColor];
    [backgroundView addSubview:separator];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return;
    }
    
    rowItemSelected = indexPath.row;
    MRShipping * mrShipping = [self.collection objectAtIndex:[indexPath row]];
    
    [Quote sharedQuote].mrShipping =mrShipping;
    
    [tableView reloadData];
}

@end
