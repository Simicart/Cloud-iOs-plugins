//
//  XReportVC.m
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 2/25/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import "XReportVC.h"
#import "XReportTableViewCell.h"
#import "ZReportCashInfoCell.h"
#import "ManualCountVC.h"

@interface XReportVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCloseStore;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewExportImage;

//store info

@property (weak, nonatomic) IBOutlet UILabel *storeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashierLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (strong, nonatomic) UIActivityIndicatorView * animation;

@end

@implementation XReportVC
{
    CGRect frameCashAmountInputView;
    UITextField * activeField;
    ZReportCashInfoCell * cashInfoCell;
    NSDictionary * storeInfoDict;
    NSArray * paymentInfoArray;
    
    BOOL allowScrollView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initStyle];
    
    [self initTableViewCell];
    
    [self initReportMidday];

}

-(void)viewWillAppear:(BOOL)animated{
    [self initData];
}

-(void)initStyle{
    
    self.storeLabel.text =@"";
    self.cashierLabel.text =@"";
    self.fromLabel.text =@"";
    self.toLabel.text =@"";
    
    
    self.btnCloseStore.layer.cornerRadius=5.0;
    self.btnCloseStore.backgroundColor = [UIColor barBackgroundColor];
    
    self.tableView.layer.borderColor =[UIColor lightGrayColor].CGColor;
    self.tableView.layer.borderWidth =0.5;
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    
    CGSize sizeScrollView=self.scrollView.contentSize;
    sizeScrollView.height +=352;
    self.scrollView.contentSize=sizeScrollView;
    
    //activity indicator
        self.animation =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.animation.frame =CGRectMake(self.view.frame.origin.x/2, self.view.frame.origin.y/2, 54, 54);
        self.animation.center = CGPointMake(WINDOW_WIDTH/2, self.tableView.center.y-100);
    
        [self.tableView addSubview:self.animation];
    
        [self.animation startAnimating];
    
}

-(void)initTableViewCell{
    NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"ZReportCashInfoCell" owner:nil options:nil];
    for(id current in nib)
    {
        if([current isKindOfClass:[ZReportCashInfoCell class]])
        {
            cashInfoCell=(ZReportCashInfoCell *) current;
           // cashInfoCell.delegate=self;
            break;
        }
    }
    
}

#pragma mark - init data
-(void)initData{
    
    [self.animation startAnimating];
    
    if(cashInfoCell){
        cashInfoCell.manualCountTextField.text =@"";
        cashInfoCell.manualCountLabel.text =@"";
    }
    
    [[APIManager shareInstance] loadReportMidAndEndOfDay:^(BOOL success, id result) {
        if(success && [result objectForKey:@"data"]){
            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.animation stopAnimating];
                    
                    storeInfoDict =[[result objectForKey:@"data"] objectForKey:@"store_info"];
                    
                    if(storeInfoDict){
                        //show store info
                        self.storeLabel.text =[storeInfoDict objectForKey:@"store_name"];
                        self.cashierLabel.text =[storeInfoDict objectForKey:@"cashier"];
                        self.fromLabel.text =[storeInfoDict objectForKey:@"from"];
                        self.toLabel.text =[storeInfoDict objectForKey:@"to"];
                    }
                    
                    // show cash info
                    paymentInfoArray =[[result objectForKey:@"data"] objectForKey:@"payment_info"];
                    [self.tableView reloadData];
                });
            });
            
        }
    }];
    
    
}


#pragma mark - todo set title miday
-(void)initReportMidday{
    
    [self.btnCloseStore setTitle:@"EXPORT DATA" forState:UIControlStateNormal];
    
    [cashInfoCell setHideManualCount];
    cashInfoCell.numberOrderLabel.hidden =NO;
    cashInfoCell.recordGrandTotalLabel.hidden =NO;
    
    CGRect numberOrderRect =cashInfoCell.numberOrderLabel.frame;
    numberOrderRect.origin.x +=362;
    cashInfoCell.numberOrderLabel.frame=numberOrderRect;

    
    CGRect recordGrandTotal =cashInfoCell.recordGrandTotalLabel.frame;
    recordGrandTotal.origin.x +=351;
    cashInfoCell.recordGrandTotalLabel.frame=recordGrandTotal;
    
    
    /*
     self.btnCount.hidden=YES;
     self.manualCountTextField.hidden=YES;
     self.manualCountLabel.hidden=YES;
     self.differenceLabel.hidden=YES;
     self.numberOrderLabel.hidden =YES;
     self.recordGrandTotalLabel.hidden =YES;
     */
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(paymentInfoArray && paymentInfoArray.count){
        return paymentInfoArray.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row==0){
        
        return 153;
    }
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell;
    NSDictionary * dict = [paymentInfoArray objectAtIndex:indexPath.row];
    
    if(indexPath.row==0){
        
        [cashInfoCell setDataWithDict:dict];
        return cashInfoCell;
        
    //Add Sum the last cell
    }else{
        
        static NSString * cellIdentify =@"XReportTableViewCell";
        //Normal cell
        cell = (XReportTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell)
        {
            NSArray *nib=[[NSBundle mainBundle] loadNibNamed:cellIdentify owner:nil options:nil];
            for(id current in nib)
            {
                if([current isKindOfClass:[XReportTableViewCell class]])
                {
                    cell=(XReportTableViewCell *) current;
                    break;
                }
            }
        }
        
    }
    
    
    [(XReportTableViewCell*)cell setDataWithDict:dict];
    
    if(indexPath.row%2==0){
        cell.backgroundColor =[UIColor groupTableViewBackgroundColor];
    }
    
    return cell;
}


#pragma mark - ManualCountVCDelegate
-(void)getTotalManualCount:(float)total{
    cashInfoCell.manualCountTextField.text = [NSString stringWithFormat:@"%.02f",total];
    cashInfoCell.manualCountLabel.text=[NSString stringWithFormat:@"%.02f",total];
    [cashInfoCell setDifferenceValue:total];
    [cashInfoCell.manualCountTextField becomeFirstResponder];
    
}

#pragma mark - Button Action Event
- (IBAction)shareDataButtonClick:(id)sender {
    
    [self exportSaveDataToImage];
}

#pragma mark - export & save data to image
-(void)exportSaveDataToImage{
    UIImage *image=  [Utilities imageWithView:self.viewExportImage];
    NSString *str=@"Export Reports";
    NSArray *postItems=@[str,image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    // Change Rect to position Popover
    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 1, 1)inView:self.view permittedArrowDirections:0 animated:YES];
}
@end
