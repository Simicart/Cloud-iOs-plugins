//
//  CartInformation.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/10/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CartInformation.h"
#import "Product.h"
#import "Price.h"

#import "CartItemCell.h"
#import "CartViewController.h"
#import "CustomerEditViewController.h"

#import "MSFramework.h"

#import "SearchCustomerVC.h"

@interface CartInformation()
@property (strong, nonatomic) NSArray *totals;

@property (nonatomic) NSUInteger numberRequest;
@property (strong, nonatomic) UIControl *loadingMask;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@end

@implementation CartInformation
{
    SearchCustomerVC * searchCustomerVC;
}
@synthesize currentPage;

@synthesize quote;

@synthesize customersPopover;
@synthesize cartItemPopover;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.quote = [Quote sharedQuote];
    
    self.tableView.sectionHeaderHeight = 1;
    self.tableView.backgroundColor = [UIColor backgroundColor];
    self.tableView.separatorColor = self.tableView.backgroundColor;
    
    // Event for change shopping cart
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimation) name:QuoteWillRequestNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnimation) name:QuoteDidRequestNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshShoppingCart) name:QuoteEndRequestNotification object:nil];
    
    // Animation
    self.numberRequest = 0;
    self.loadingMask = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 426, 702)];
    self.loadingMask.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    self.loadingMask.hidden = YES;
    
    self.animation = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 426, 320)];
    self.animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.loadingMask addSubview:self.animation];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    [parent.view addSubview:self.loadingMask];
}

- (void)startAnimation
{
    self.numberRequest++;
   // if (self.numberRequest == 1) {
        [[[NSThread alloc] initWithTarget:self selector:@selector(animationThread) object:nil] start];
   // }
}

- (void)animationThread
{
    self.loadingMask.hidden = NO;
    [self.animation startAnimating];
}

- (void)stopAnimation
{
    self.loadingMask.hidden = YES;
    [self.animation stopAnimating];
    
    return;
    
    if (self.numberRequest) {
        self.numberRequest--;
    }
    if (!self.numberRequest) {
        self.loadingMask.hidden = YES;
        [self.animation stopAnimating];
    }
}

- (void)refreshShoppingCart
{
    [self.animation startAnimating];
    
    self.quote = [Quote sharedQuote];
    
    self.totals = [self.quote getTotals];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if (indexPath && cartItemPopover && cartItemPopover.isPopoverVisible) {
        
        [[(EditItemViewController *)cartItemPopover.delegate tableView] reloadData];
    }
    
    self.loadingMask.hidden = YES;
    [self.animation stopAnimating];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{    
    if ([quote getAllItems] && [[quote getAllItems] count]) {
        return 4;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
        {            
           return quote.quoteItems.count;

        }
        case 2:
            return [self.totals count];
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return @" ";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            return [self customerViewCell:indexPath];
        case 1:
            return [self productViewCell:indexPath];
        default:
            return [self totalsViewCell:indexPath];
    }
}

- (UITableViewCell *)customerViewCell:(NSIndexPath *)indexPath
{
    static NSString *NibCustomerId = @"NibCustomerId";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NibCustomerId];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NibCustomerId];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    }
    if (quote.order) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    // Don't have customer
    if ([quote hasCustomer]) {
        cell.textLabel.text = [[quote objectForKey:@"customer_name"] isKindOfClass:[NSString class]] ? [quote objectForKey:@"customer_name"] : nil;
        if ([[quote objectForKey:@"customer_email"] isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = [quote objectForKey:@"customer_email"];
        } else {
            cell.detailTextLabel.text = [[quote objectForKey:@"customer_telephone"] isKindOfClass:[NSString class]] ? [quote objectForKey:@"customer_telephone"] : nil;
        }
        cell.imageView.image = [UIImage imageNamed:@"customer_avatar.png"];
    } else {
        cell.textLabel.text = NSLocalizedString(@"Add Customer", nil);
        cell.detailTextLabel.text = nil;
        cell.imageView.image =  [UIImage imageNamed:@"icon_white_user_male_circle.png"];
        cell.imageView.layer.cornerRadius =5.0;
        cell.imageView.backgroundColor =[UIColor barBackgroundColor];
        //[cell.imageView setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.imageView.clipsToBounds = YES;
    }
    return cell;
}

- (UITableViewCell *)productViewCell:(NSIndexPath *)indexPath
{
    static NSString *NibItemView = @"NibItemView";
    CartItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NibItemView];
    if (cell == nil) {
        cell = [[CartItemCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NibItemView];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
        // Cell style
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
        cell.imageView.transform = CGAffineTransformMakeScale(0.61, 0.61);
        // Price label
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
        priceLabel.font = [UIFont boldSystemFontOfSize:17];
        priceLabel.textAlignment = NSTextAlignmentRight;
        priceLabel.tag = 1;
        //        priceLabel.textColor = [UIColor buttonPressedColor];
        priceLabel.highlightedTextColor = [UIColor whiteColor];
        
        UILabel *regPrice = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 100, 18)];
        regPrice.font = [UIFont boldSystemFontOfSize:13];
        regPrice.textAlignment = NSTextAlignmentRight;
        regPrice.tag = 2;
        regPrice.textColor = [UIColor blueColor];
        regPrice.highlightedTextColor = [UIColor whiteColor];
        
        cell.accessoryView = [[UIView alloc] init];
        [cell.accessoryView addSubview:priceLabel];
        [cell.accessoryView addSubview:regPrice];
        
        /// Error Mark
        priceLabel.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        regPrice.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
        UIView *errorMark = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 427, 80)];
        errorMark.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.27];
        errorMark.tag = 201;
        [cell addSubview:errorMark];
    }
    if (currentPage == CHECKOUT_PAGE) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    QuoteItem *item = [[quote getAllItems] objectAtIndex:[indexPath row]];
    cell.textLabel.text = [item getName];
    if (item.options != nil) {
        cell.detailTextLabel.text = [item getOptionsLabel];
        
    } else {
        cell.detailTextLabel.text = nil;
    }
    [cell.imageView setImageWithURL:[NSURL URLWithString:[item.product objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"product_placeholder.png"]];
    [cell addBadgeQty:[item getQty]];
    
    UILabel *itemPrice = (UILabel *)[cell.accessoryView viewWithTag:1];
    UILabel *regPrice = (UILabel *)[cell.accessoryView viewWithTag:2];
    
    //ndchien :
    //itemPrice.text = [Price format:[item getPrice]];
    
    float  priceFloat =  [item getPrice].floatValue * [item getQty];
    
    itemPrice.text = [Price format:[NSNumber numberWithFloat:priceFloat]];
    
    if ([item hasSpecialPrice]) {                
        //regPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Reg. %@", nil), [Price format:[item getRegularPrice]]];
        float priceRegFloat =  [item getRegularPrice].floatValue * [item getQty];
        regPrice.text = [NSString stringWithFormat:NSLocalizedString(@"Reg. %@", nil), [Price format:[NSNumber numberWithFloat:priceRegFloat]]];
        
        cell.accessoryView.frame = CGRectMake(0, 0, 100, 42);
        regPrice.hidden = NO;
    } else {
        cell.accessoryView.frame = CGRectMake(0, 0, 100, 24);
        regPrice.hidden = YES;
    }
    
    UIView *errorMark = [cell viewWithTag:201];
    if ([MSValidator isEmptyString:[item objectForKey:@"message"]]) {
        errorMark.hidden = YES;
    } else {
        errorMark.hidden = NO;
    }
    return cell;
}

- (UITableViewCell *)totalsViewCell:(NSIndexPath *)indexPath
{
    // Cart Total Section
    static NSString *NibTotalItem = @"NibTotalItem";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NibTotalItem];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NibTotalItem];
        cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
        // Cell style
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.backgroundColor = [UIColor whiteColor];
        // Price label
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
        priceLabel.font = [UIFont boldSystemFontOfSize:18];
        priceLabel.textAlignment = NSTextAlignmentRight;
        //        priceLabel.textColor = [UIColor buttonPressedColor];
        cell.accessoryView = priceLabel;
    }

    NSDictionary *total = [self.totals objectAtIndex:[indexPath row]];
    cell.textLabel.text = [total objectForKey:@"title"];
    
    UILabel *totalPrice = (UILabel *)cell.accessoryView;
    totalPrice.text = [Price format:[total objectForKey:@"amount"]];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [quote hasCustomer] && !quote.order) {
        return UITableViewCellEditingStyleDelete;
    }
    if ([indexPath section] == 1 && currentPage != CHECKOUT_PAGE) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([indexPath section] == 0) {
            // Remove current customer
            [[[NSThread alloc] initWithTarget:quote selector:@selector(assignCustomer:) object:nil] start];
            return;
        }
        // Remove Item
        QuoteItem *item = [[quote getAllItems] objectAtIndex:[indexPath row]];
        [[[NSThread alloc] initWithTarget:quote selector:@selector(removeItem:) object:[item getId]] start];
        // [quote removeItem:[item getId]];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (quote.order || ([indexPath section] && currentPage == CHECKOUT_PAGE)) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    if ([indexPath section] == 0) {
        if ([quote hasCustomer]) {
            // Customer Edit
            CustomerEditViewController *customerEdit = [[CustomerEditViewController alloc] init];
            MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:customerEdit];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES completion:nil];
            navController.view.superview.frame = CGRectMake(272, 119, 480, 529);
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        if(!searchCustomerVC){
            searchCustomerVC =[[SearchCustomerVC alloc] initWithNibName:@"SearchCustomerVC" bundle:nil];
            searchCustomerVC.itemTableView = tableView;
        }
        
        
        if (customersPopover == nil) {
            customersPopover =[[UIPopoverController alloc] initWithContentViewController:searchCustomerVC];
            customersPopover.delegate = searchCustomerVC;
            searchCustomerVC.listPopover = customersPopover;
            customersPopover.popoverContentSize=searchCustomerVC.view.frame.size;
        }
        
        CGRect frame = [[tableView cellForRowAtIndexPath:indexPath] frame];
        [customersPopover presentPopoverFromRect:frame inView:tableView permittedArrowDirections:(UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight) animated:YES];
        
        
    } else if ([indexPath section] == 1) {
        
        EditItemViewController *editItemView = [[EditItemViewController alloc] init];
        MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:editItemView];
        
        navController.delegate = editItemView;
        [navController setNavigationBarHidden:YES animated:NO];
        
        cartItemPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        cartItemPopover.delegate = editItemView;
        editItemView.cartItemPopover = cartItemPopover;
        
        editItemView.item = [[quote getAllItems] objectAtIndex:[indexPath row]];
        editItemView.itemIndexPath = indexPath;
        editItemView.itemTableView = tableView;
        editItemView.isShowedQtyInput = NO;
        editItemView.isShowedDiscountForm = NO;
        editItemView.isShowedItemOptions = NO;
        
        // Estimate size of popover
        cartItemPopover.popoverContentSize = [editItemView reloadContentSize];
        
        // Show popover
        CGRect frame = [[tableView cellForRowAtIndexPath:indexPath] frame];
        [cartItemPopover presentPopoverFromRect:frame inView:tableView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
        [editItemView.tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 2) {
        return 60;
    }
    return 80;
}

#pragma mark - ZReportCashInfoCellDelegate
-(void)openPopUpSearchCustomer{
    
    if(searchCustomerVC){
        UIPopoverController * popOverController =[[UIPopoverController alloc] initWithContentViewController:searchCustomerVC];
        popOverController.popoverContentSize=searchCustomerVC.view.frame.size;
        
        [popOverController presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
    }
    
}

@end
