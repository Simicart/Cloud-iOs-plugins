//
//  CashDrawerViewController.m
//  SimiPOS
//
//  Created Nguyen Duc Chien on 2/24/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import "ReportsViewController.h"
#import "XMComboBoxView.h"

//sub reports
#import "ZReportVC.h"
#import "XReportVC.h"
#import "DailyReportVC.h"

#define REPORT_NAME_X_REPORT @"X-Report (Mid-day report)"
#define REPORT_NAME_Z_REPORT @"Z-Report (End-of-day report)"
#define REPORT_NAME_DAILY_REPORT @"Daily Report on POS Orders"

@interface ReportsViewController ()<UIDropDownMenuDelegate>

@property (weak, nonatomic) IBOutlet XMComboBoxView *listReportType;
@property (weak, nonatomic) IBOutlet UIButton *btnRefresh;
@property (weak, nonatomic) IBOutlet UILabel *titleReport;

@property (weak, nonatomic) IBOutlet UIView *hearderView;

@end

@implementation ReportsViewController{
    ZReportVC * zReportVC;
    XReportVC * xReportVC;
    DailyReportVC * dailyReport;
    NSString * currentReportName;
    Permission * permission;
}

static ReportsViewController *_sharedInstance = nil;

+(ReportsViewController*)sharedInstance
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


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self initData];
    
    [self hideAllReport];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.btnRefresh setTitle:NSLocalizedString(@"Refresh", nil) forState:(UIControlStateNormal)];
    _sharedInstance=self;
    [self initStyle];
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

-(void)initStyle{
    
    self.btnRefresh.layer.cornerRadius =4.0;
    
    //set color
    self.btnRefresh.backgroundColor = [UIColor barBackgroundColor];
    self.hearderView.backgroundColor = [UIColor barBackgroundColor];
    
    [XMComboBoxView setButtonImage:@"dropdown-arrow-icon"];
    
    [self.listReportType makeMenu:self.view andIdentifier:@"listReportType" caption:nil data:nil section:nil];
    self.listReportType.delegate = self;
}


-(void)initData{
    NSArray *allowReports = [[NSArray alloc] initWithObjects:@"-- Please select report type --", nil];
    permission =[Permission MR_findFirst];
    if(permission.all_reports.boolValue || permission.x_report.boolValue){
        allowReports = [allowReports arrayByAddingObject:REPORT_NAME_X_REPORT];
    }
    if(permission.all_reports.boolValue || permission.z_report.boolValue){
        allowReports = [allowReports arrayByAddingObject:REPORT_NAME_Z_REPORT];
    }
    
    if(permission.all_reports.boolValue || permission.eod_report.boolValue){
        allowReports = [allowReports arrayByAddingObject:REPORT_NAME_DAILY_REPORT];
    }
    if(permission.all_reports.boolValue || permission.sales_report.boolValue){
        
    }
    NSMutableArray * listItem =[[NSMutableArray alloc] initWithArray:allowReports];
    [self.listReportType loadData:listItem data:listItem section:nil];
}

- (IBAction)showMenuButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOW_LEFT_SIDE_BAR_MENU object:nil];
}


#pragma mark - Implementation UIDropDownMenuDelegate
- (void)DropDownMenuDidChange:(NSString *)identifier selectedString:(NSString *)ReturnValue{
    [self.view endEditing:YES];
    
    currentReportName = [ReturnValue copy];
    
    DLog(@"DropDownMenuDidChange identifer:%@   returnValue:%@",identifier,ReturnValue);
    
    if([ReturnValue isEqualToString:REPORT_NAME_X_REPORT]){
        [self showReportX];
        return;
    }
    
    if([ReturnValue isEqualToString:REPORT_NAME_Z_REPORT]){
        [self showReportZ];
        return;
    }
    
    if([ReturnValue isEqualToString:REPORT_NAME_DAILY_REPORT]){
        [self showReportDaily];
        return;
    }
    
    //Please select report type
    [self hideAllReport];
}

#pragma mark - create sub report
-(void)createXReport{
    if(!xReportVC){
        xReportVC =[[XReportVC alloc] initWithNibName:@"XReportVC" bundle:nil];
        xReportVC.view.frame=CGRectMake(0, 127, self.view.frame.size.width, WINDOW_HEIGHT -127);
        
        [self addChildViewController:xReportVC];
        [self.view addSubview:xReportVC.view];
    }
    xReportVC.view.hidden =NO;
}


#pragma mark - create sub report
-(void)createZReport{
    if(!zReportVC){
        zReportVC =[[ZReportVC alloc] initWithNibName:@"ZReportVC" bundle:nil];
        zReportVC.view.frame=CGRectMake(0, 127, self.view.frame.size.width, WINDOW_HEIGHT -127);
        
        [self addChildViewController:zReportVC];
        [self.view addSubview:zReportVC.view];
    }
    zReportVC.view.hidden =NO;
}


-(void)createDailyReport{
    
    if(!dailyReport){
        dailyReport =[[DailyReportVC alloc] initWithNibName:@"DailyReportVC" bundle:nil];
        dailyReport.view.frame=CGRectMake(0, 127, self.view.frame.size.width, WINDOW_HEIGHT -127);
        
        [self addChildViewController:dailyReport];
        [self.view addSubview:dailyReport.view];
    }
    
    dailyReport.view.hidden=NO;
}

#pragma mark - Create SubReports
-(void)showReportX{
    
    self.titleReport.text = NSLocalizedString(@"X-REPORT", nil);
    
    if(dailyReport){
        dailyReport.view.hidden =YES;
    }
    
    if(zReportVC){
        zReportVC.view.hidden =YES;
    }
    
    [self createXReport];
    
}

-(void)showReportZ{
    
    self.titleReport.text = NSLocalizedString(@"Z-REPORT", nil);
    if(dailyReport){
        dailyReport.view.hidden =YES;
    }
    
    if(xReportVC){
        xReportVC.view.hidden =YES;
    }
    
    
    [self createZReport];
    [zReportVC setReportType:REPORT_ENDDAY];
    
    
}

-(void)showReportDaily{
    
    self.titleReport.text = NSLocalizedString(@"DAILY-REPORTS", nil);
    
    if(zReportVC){
        zReportVC.view.hidden =YES;
    }
    
    if(xReportVC){
        xReportVC.view.hidden =YES;
    }
    
    [self createDailyReport];
}

-(void)hideAllReport{
    
    self.titleReport.text = NSLocalizedString(@"REPORT", nil);
    if(dailyReport){
        dailyReport.view.hidden =YES;
    }
    if(zReportVC){
        zReportVC.view.hidden =YES;
    }
    if(xReportVC){
        xReportVC.view.hidden =YES;
    }
}

- (IBAction)refreshData:(id)sender {
    if([currentReportName isEqualToString:REPORT_NAME_X_REPORT]){
        if(xReportVC){
            NSString *keyParams = [[Configuration globalConfig].productCache objectForKey:@"report.zreport"];
            [[Configuration globalConfig].productCache removeObjectForKey:keyParams];
            [xReportVC initData];
        }
        
    }else if([currentReportName isEqualToString:REPORT_NAME_Z_REPORT]){
        if(zReportVC){
            NSString *keyParams = [[Configuration globalConfig].productCache objectForKey:@"report.zreport"];
            [[Configuration globalConfig].productCache removeObjectForKey:keyParams];
            [zReportVC initData];
        }
        
    }else{
        if(dailyReport){
            NSString *keyParams = [[Configuration globalConfig].productCache objectForKey:@"report.dailyReport"];
            [[Configuration globalConfig].productCache removeObjectForKey:keyParams];
            [dailyReport initData];
        }
    }
    
}


@end
