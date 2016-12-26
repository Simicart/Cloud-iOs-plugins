//
//  UserStoreSettingVC.m
//  RetailerPOS
//
//  Created by mac on 3/2/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "UserStoreSettingVC.h"
#import "XMComboBoxView.h"
#import "CatalogViewController.h"
#import "Stores.h"
#import "CashDrawer.h"
#import "APIManager.h"
#import "UserInfo.h"

@interface UserStoreSettingVC ()

@property (weak, nonatomic) IBOutlet XMComboBoxView *storeList;
@property (weak, nonatomic) IBOutlet XMComboBoxView *cashDrawerList;

@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
@property (strong, nonatomic) UIActivityIndicatorView * animation;

@property (weak, nonatomic) IBOutlet UIView *groupScaleView;
@property (strong, nonatomic) IBOutlet UIView *groupBoxView;


@property (weak, nonatomic) IBOutlet UILabel *cashDrawerLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *cashDrawerIcon;
@property (strong, nonatomic) IBOutlet UIImageView *storeIcon;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation UserStoreSettingVC
{
    NSString * storeID;
    NSString * tillID;
    
    NSString * _storeName;
    NSString * _tillName;
    
    BOOL enableCashDrawer;
    
    CGRect cashDrawerFrame ;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
     [self.btnUpdate setEnabled:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initDefault];
    
    [self initStoreList];
    
    [self initCashDrawerList];
    
//    CGRect frameListCashDrawer =self.cashDrawerList.frame;
//    frameListCashDrawer.origin.x = self.cashDrawerLabel.frame.origin.x + 10;
//    frameListCashDrawer.origin.y = self.cashDrawerLabel.frame.origin.y;
//    
//    self.cashDrawerList.dropdownTable.frame =frameListCashDrawer;
//        self.cashDrawerList.selectedTextField.frame =frameListCashDrawer;
}

-(void)initDefault{
    
    self.storeIcon.layer.cornerRadius =2.0;
    self.storeIcon.backgroundColor =[UIColor barBackgroundColor];

    self.cashDrawerIcon.layer.cornerRadius =2.0;
    self.cashDrawerIcon.backgroundColor =[UIColor barBackgroundColor];
    
    self.groupBoxView.layer.borderWidth =1.0;
    self.groupBoxView.layer.cornerRadius=10;
    self.groupBoxView.layer.borderColor =  [UIColor barBackgroundColor].CGColor;
    
    //self.btnUpdate.layer.cornerRadius =4.0;
    self.btnUpdate.backgroundColor =[UIColor barBackgroundColor];
    
    self.headerView.backgroundColor = [UIColor barBackgroundColor];
    
    //[XMComboBoxView setButtonImage:@"dropdown-arrow-icon"];
    [XMComboBoxView setButtonImage:@""];
    
    
    [self.storeList makeMenu:self.groupScaleView andIdentifier:@"storeList" caption:nil data:nil section:nil];
    self.storeList.delegate = self;
    
    
    [self.cashDrawerList makeMenu:self.groupScaleView andIdentifier:@"cashDrawerList" caption:nil data:nil section:nil];
    self.cashDrawerList.delegate = self;
    
    cashDrawerFrame =self.cashDrawerList.frame;
    
    //activity indicator
    self.animation =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.animation.frame =CGRectMake(WINDOW_WIDTH/2, WINDOW_HEIGHT/2, 54, 54);
  //  self.animation.center =self.view.center;
    [self.view addSubview:self.animation];
    
}

-(void)initStoreList{
    NSArray * items =[Stores MR_findAllSortedBy:@"store_id" ascending:YES];
    if(items && items.count >0){
        NSMutableArray *  names =[[NSMutableArray alloc] init];
        
        for (Stores * item in items) {
            [names addObject:item.store_name];
        }
        
        [self.storeList loadData:names data:names section:nil];
        
        NSString * firstStoreName =[names objectAtIndex:0];
        [self checkStoreAndCashDrawer:firstStoreName];
    }
}

-(void)initCashDrawerList{
    NSArray * items =[CashDrawer MR_findAllSortedBy:@"cash_drawer_id" ascending:YES];
    if(items && items.count >0){
        NSMutableArray *  names =[[NSMutableArray alloc] init];
        
        for (CashDrawer * item in items) {
            [names addObject:item.cash_drawer_name];
        }
        
        [self.cashDrawerList loadData:names data:names section:nil];
    }
}

- (void) DropDownMenuDidChange:(NSString *)identifier selectedString:(NSString *)ReturnValue{
    
    if ([identifier isEqualToString:@"storeList"]) {
        
        _storeName =ReturnValue;
        [self checkStoreAndCashDrawer:_storeName];
        
    }else{
        _tillName =ReturnValue;
        [self checkCashDrawer:_tillName];
    }
}


-(void)checkStoreAndCashDrawer:(NSString *)storeName{
    
    if(!storeName) return;
    
    Stores * store =[[Stores MR_findByAttribute:@"store_name" withValue:storeName] firstObject];
    if(store){
        storeID =store.store_id;
        if(store.enable_cash_drawer.boolValue){
            
            [self showCashList];
            enableCashDrawer =YES;
            
        }else{
            
            [self hideCashList];
            enableCashDrawer =NO;
            tillID =@"";
        }
    }
}

-(void)checkCashDrawer:(NSString *)drawerName{
    
    if(!drawerName) return;
    
    CashDrawer * cashDrawer =[[CashDrawer MR_findByAttribute:@"cash_drawer_name" withValue:drawerName] firstObject];
    if(cashDrawer){
        tillID =cashDrawer.cash_drawer_id;
    }
}


-(void)showCashList{
    
    self.cashDrawerList.frame =cashDrawerFrame;
    self.cashDrawerList.hidden =NO;
    [self.cashDrawerList showDropDownMenu];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect btnFrame =self.btnUpdate.frame;
        btnFrame.origin.y =cashDrawerFrame.origin.y + 45;
        self.btnUpdate.frame=btnFrame;
        
        self.cashDrawerIcon.hidden =NO;
        self.cashDrawerLabel.hidden =NO;
    }];
    
}

-(void)hideCashList{
    
    [self.cashDrawerList hideDropDownMenu];
    self.cashDrawerList.hidden =YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect btnFrame =self.btnUpdate.frame;
        btnFrame.origin.y =cashDrawerFrame.origin.y;
        
        self.btnUpdate.frame=btnFrame;
        
        self.cashDrawerLabel.hidden =YES;
        self.cashDrawerIcon.hidden =YES;
    }];
    
}

- (IBAction)updateButtonClick:(id)sender {
    
    [Utilities showIndicator:self.view setCenter:self.view.center];
    
    [self updateStoreConfig];
    
    [self setAllFullPermission];
    //NO Internet
//    [self openCatelogViewController];
    
    [self performSelector:@selector(openCatelogViewController)];
    
    [Utilities hideIndicator];
    
    return;

    /*
    [self.btnUpdate setEnabled:NO];
    
    [self.animation startAnimating];
    
    if(!enableCashDrawer){
        tillID =@"0";
    }
    
    [[APIManager shareInstance] setStoreData:storeID TillId:tillID Callback:^(BOOL success, id result) {
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
        [self.animation stopAnimating];
        
        if(success){
            
            [self updateStoreConfig];
            
            NSDictionary * data =[result objectForKey:@"data"];
            
           // DLog(@"data:%@",data);
            
            if(data && [data isKindOfClass:[NSDictionary class]]){
                
                // chinh mau sac theme app theo setting
                NSString * appColor =[data objectForKey:@"app_color"];
                if(appColor){
                    [[NSUserDefaults standardUserDefaults] setObject:appColor forKey:THEME_COLOR_DEFAULT];
                }
                
                //Phan quyen
                NSDictionary * permissionDict =[data objectForKey:@"permissions"];
                if(permissionDict){
                    [self updatePermission:permissionDict];
                }
                
                //get default payment method
                NSString * defautPayment = [NSString stringWithFormat:@"%@" ,[data objectForKey:KEY_DEFAULT_PAYMENT_METHOD]];
                SetStringValue(defautPayment,KEY_DEFAULT_PAYMENT_METHOD);                
            }
            
            [self openCatelogViewController];
        }else{
            [Utilities alert:@"Message" withMessage:@"Update false , Please try again !"];
        }
        
        
            });
        });
        
        
    }];
     
     */
}

-(void)updateUserInfo{
    [UserInfo truncateAll];
    
    UserInfo * userInfo =[UserInfo MR_createEntity];
    
    userInfo.username =[NSString stringWithFormat:@"%@",[[Configuration globalConfig] objectForKey:@"username"]];
    userInfo.store_id =storeID;
    userInfo.session =[NSString stringWithFormat:@"%@",[[Configuration globalConfig] objectForKey:@"session"]];
    userInfo.cash_drawer_id =tillID;
    userInfo.enable_cash_drawer =  enableCashDrawer ? @"YES": @"NO";
    
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

#pragma mark - cap nhat thong tin phan quyen nguoi dung
-(void)updatePermission:(NSDictionary*)permissionDict{
    
    [Permission truncateAll];
    
    Permission * permisson =[Permission MR_createEntity];
    
    //Check null & convert bool
    NSString * all_cart_discount =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"all_cart_discount"]];
    permisson.all_cart_discount = [NSNumber numberWithInt:all_cart_discount.intValue];
    
    NSString * all_reports =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"all_reports"]];
    permisson.all_reports = [NSNumber numberWithInt:all_reports.intValue];
    
    NSString * cart_coupon =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"cart_coupon"]];
    permisson.cart_coupon = [NSNumber numberWithInt:cart_coupon.intValue];
    
    NSString * cart_custom_discount =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"cart_custom_discount"]];
    permisson.cart_custom_discount = [NSNumber numberWithInt:cart_custom_discount.intValue];
    
    NSString * eod_report =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"eod_report"]];
    permisson.eod_report = [NSNumber numberWithInt:eod_report.intValue];
    
    NSString * items_custom_price =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"items_custom_price"]];
    permisson.items_custom_price = [NSNumber numberWithInt:items_custom_price.intValue];
    
    NSString * items_discount =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"items_discount"]];
    permisson.items_discount = [NSNumber numberWithInt:items_discount.intValue];
    
    NSString * manage_cash_drawer =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"manage_cash_drawer"]];
    permisson.manage_cash_drawer = [NSNumber numberWithInt:manage_cash_drawer.intValue];
    
    NSString * manage_order =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"manage_order"]];
    permisson.manage_order = [NSNumber numberWithInt:manage_order.intValue];
    
    NSString * manage_order_refund =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"manage_order_refund"]];
    permisson.manage_order_refund = [NSNumber numberWithInt:manage_order_refund.intValue];
    
    NSString * maximum_discount_percent =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"maximum_discount_percent"]];
    permisson.maximum_discount_percent = [NSNumber numberWithInt:maximum_discount_percent.intValue];
    
    NSString * sales_report =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"sales_report"]];
    permisson.sales_report = [NSNumber numberWithInt:sales_report.intValue];
    
    NSString * x_report =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"x_report"]];
    permisson.x_report = [NSNumber numberWithInt:x_report.intValue];
    
    NSString * z_report =[NSString stringWithFormat:@"%@",[permissionDict objectForKey:@"z_report"]];
    permisson.z_report = [NSNumber numberWithInt:z_report.intValue];
    
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    
}

-(void)setAllFullPermission{
    
    [Permission truncateAll];
    
    Permission * permisson =[Permission MR_createEntity];
    
    permisson.all_cart_discount = [NSNumber numberWithInt:1];
    permisson.all_reports = [NSNumber numberWithInt:1];
    permisson.cart_coupon = [NSNumber numberWithInt:1];
    permisson.cart_custom_discount = [NSNumber numberWithInt:1];
    permisson.eod_report = [NSNumber numberWithInt:1];
    permisson.items_custom_price = [NSNumber numberWithInt:1];
    permisson.items_discount = [NSNumber numberWithInt:1];
    permisson.manage_cash_drawer = [NSNumber numberWithInt:1];
    permisson.manage_order = [NSNumber numberWithInt:1];
    permisson.manage_order_refund = [NSNumber numberWithInt:1];
    permisson.maximum_discount_percent = [NSNumber numberWithInt:1];
    permisson.sales_report = [NSNumber numberWithInt:1];
    permisson.x_report = [NSNumber numberWithInt:1];
    permisson.z_report = [NSNumber numberWithInt:1];
    
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    
}

#pragma mark - Luu lai cau hinh store & cash drawer name de hien thi trong phan setting
-(void)updateStoreConfig{
    
    [[NSUserDefaults standardUserDefaults] setObject:_storeName forKey:KEY_STORE_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:_tillName forKey:KEY_TILL_NAME];
    
}

-(void)openCatelogViewController{
    [self.navigationController pushViewController:[CatalogViewController sharedInstance] animated:YES];
}

@end
