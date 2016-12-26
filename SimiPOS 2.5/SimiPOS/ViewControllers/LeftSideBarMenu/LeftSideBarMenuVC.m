//
//  LeftSideBarMenuVC.m
//  SimiPOS
//
//  Created by mac on 3/7/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "LeftSideBarMenuVC.h"
#import "LeftSideBarMenuCell.h"

//ViewControllers
#import "OrdersViewController.h"
#import "HoldOrdersViewController.h"
#import "CashDrawerViewController.h"
#import "CatalogViewController.h"
#import "ReportsViewController.h"
#import "SettingsViewController.h"
#import "CustomersViewController.h"
#import "JKLLockScreenViewController.h"

#import "AccountViewController.h"
#import "LeftSideBarMenuCell.h"

@interface LeftSideBarMenuVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (strong, nonatomic) IBOutlet UIPopoverController *popOverController;

@end


@implementation LeftSideBarMenuVC
{
    NSArray * keyArray;
    NSArray * titleArray ;
    NSArray * imageArray;
    
    Permission * permission;
}

@synthesize popOverController;

static LeftSideBarMenuVC *_sharedInstance = nil;

+(LeftSideBarMenuVC*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDefault];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openMenuProduct) name:@"NOTIFY_OPEN_PRODUCT" object:nil];
    
}

-(void)initDefault{
    
    _sharedInstance =self;
    
    permission =[Permission MR_findFirst];
    
    [self.tblView setBackgroundColor:[UIColor clearColor]];
    
    NSArray *tempKeyArray = [[NSArray alloc] initWithObjects:@"account",@"products", nil];
    NSArray *tempTitleArr = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Account", nil),NSLocalizedString(@"Products", nil), nil];
    NSArray *tempImgArr = [[NSArray alloc] initWithObjects:@"menu_account",@"menu_product", nil];
    if(permission.manage_order.boolValue || permission.manage_order_refund.boolValue){
        tempKeyArray = [tempKeyArray arrayByAddingObject:@"orders"];
        tempTitleArr = [tempTitleArr arrayByAddingObject:NSLocalizedString(@"Orders", nil)];
        tempImgArr = [tempImgArr arrayByAddingObject:@"menu_order"];
    }
    tempKeyArray = [tempKeyArray arrayByAddingObject:@"orders_onhold"];
    tempTitleArr = [tempTitleArr arrayByAddingObject:NSLocalizedString(@"On Hold Orders", nil)];
    tempImgArr = [tempImgArr arrayByAddingObject:@"menu_hold_order"];
    if(permission.manage_cash_drawer.boolValue){
        tempKeyArray = [tempKeyArray arrayByAddingObject:@"cash_drawer"];
        tempTitleArr = [tempTitleArr arrayByAddingObject:NSLocalizedString(@"Cash Drawer", nil)];
        tempImgArr = [tempImgArr arrayByAddingObject:@"menu_cash_drawer"];
    }
    if(permission.all_reports.boolValue || permission.x_report.boolValue|| permission.z_report.boolValue|| permission.eod_report.boolValue){
        tempKeyArray = [tempKeyArray arrayByAddingObject:@"reports"];
        tempTitleArr = [tempTitleArr arrayByAddingObject:NSLocalizedString(@"Reports", nil)];
        tempImgArr = [tempImgArr arrayByAddingObject:@"menu_report"];
    }
    tempKeyArray = [tempKeyArray arrayByAddingObject:@"customers"];
    tempKeyArray = [tempKeyArray arrayByAddingObject:@"settings"];
    tempTitleArr = [tempTitleArr arrayByAddingObject:NSLocalizedString(@"Customers", nil)];
    tempTitleArr = [tempTitleArr arrayByAddingObject:NSLocalizedString(@"Settings", nil)];
    titleArray =[[NSArray alloc] initWithArray:tempTitleArr];
    
    tempImgArr = [tempImgArr arrayByAddingObject:@"menu_customer"];
    tempImgArr = [tempImgArr arrayByAddingObject:@"menu_setting"];
    imageArray =[[NSArray alloc] initWithArray:tempImgArr];
    
    keyArray =[[NSArray alloc] initWithArray:tempKeyArray];
    [self.tblView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}

#pragma mark - table view delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArray.count ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString * CellIdentify =@"LeftSideBarMenuCell";
    
    LeftSideBarMenuCell * cell =(LeftSideBarMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentify];
    
    if(!cell){
        cell  =  (LeftSideBarMenuCell *)[[[NSBundle mainBundle] loadNibNamed:CellIdentify owner:nil options:nil] firstObject];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    [cell setTitleMenu:[titleArray objectAtIndex:indexPath.row] ImageName:[imageArray objectAtIndex:indexPath.row] MenuKey:[keyArray objectAtIndex:indexPath.row]];
    
    UIImageView * bkImage =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_cell_selected"]];
    [cell setSelectedBackgroundView:bkImage];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LeftSideBarMenuCell *menuCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *menuKey = menuCell.menuKey;
    
    UIViewController * viewController =nil;
    
    if ([menuKey isEqualToString:@"account"]) {
        UITableViewCell * cell =[self.tblView cellForRowAtIndexPath:indexPath];
        [self openAccountMenu:cell];
        return;
        
    }else if([menuKey isEqualToString:@"products"]){
        viewController =[CatalogViewController sharedInstance];
    }else if([menuKey isEqualToString:@"orders"]){
        viewController =[OrdersViewController sharedInstance];
    }else if([menuKey isEqualToString:@"orders_onhold"]){
        viewController =[HoldOrdersViewController sharedInstance];
    }else if([menuKey isEqualToString:@"cash_drawer"]){
        viewController =[CashDrawerViewController sharedInstance];
    }else if([menuKey isEqualToString:@"reports"]){
        viewController =[ReportsViewController sharedInstance];
    }else if([menuKey isEqualToString:@"customers"]){
        viewController =[CustomersViewController sharedInstance];
    }else if([menuKey isEqualToString:@"settings"]){
        viewController =[SettingsViewController sharedInstance];
    }
    
    [self.revealSideViewController popViewControllerWithNewCenterController:viewController animated:YES];
    
}


-(void)openMenuProduct{
    [self.revealSideViewController popViewControllerWithNewCenterController:[CatalogViewController sharedInstance] animated:NO];
    [self.tblView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}

-(void)openAccountMenu:(UITableViewCell *) cell{
    
    if(!popOverController){
        popOverController =[[UIPopoverController alloc] initWithContentViewController:[AccountViewController sharedInstance]];
    }
    popOverController.popoverContentSize =CGSizeMake(280, 210);
    [popOverController presentPopoverFromRect:CGRectMake(260, 100, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    
}


#pragma mark - Button Action
- (void)lockScreen
{
    JKLLockScreenViewController * lockScreen =[[JKLLockScreenViewController alloc] initWithNibName:@"JKLLockScreenViewController" bundle:nil];
    lockScreen.parrentVC=self;
    [_sharedInstance presentViewController:lockScreen animated:NO completion:nil];
}

- (void)logout
{
    [self dismissViewControllerAnimated:NO completion:nil];
    [[Configuration globalConfig] removeObjectForKey:@"session"];
    [[Configuration globalConfig] removeObjectForKey:@"password"];
    [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFY_LOGOUT object:nil];
    
}

@end
