//
//  XReportVC.m
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 2/25/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import "ZReportVC.h"
#import "ZReportTableViewCell.h"
#import "ZReportCashInfoCell.h"
#import "ManualCountVC.h"
#import "ZReportModel.h"
#import "CloseStoreModel.h"

CGFloat keyboardHeight = 352;

@interface ZReportVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ZReportCashInfoCellDelegate,ManualCountVCDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnCloseStore;
@property (weak, nonatomic) IBOutlet UIView *cashAmountInputView;
@property (weak, nonatomic) IBOutlet UITextField *cashAmountInputTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *viewExportImage;
@property (weak, nonatomic) IBOutlet UILabel *lblManualCountHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblDefferenceHeader;
//store info

@property (weak, nonatomic) IBOutlet UILabel *storeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cashierLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (strong, nonatomic) UIActivityIndicatorView * animation;

@end

@implementation ZReportVC
{
    CGRect frameCashAmountInputView;
    UITextField * activeField;
    MSReportType reportType;
    ZReportCashInfoCell * cashInfoCell;
    NSDictionary * storeInfoDict;
    NSArray * paymentInfoArray;
    BOOL allowScrollView;
    // Johan
    ZReportModel *zReportModel;
    CloseStoreModel *closeStoreModel;
    // End
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initStyle];
    
    [self initTableViewCell];
    
    [self registerForKeyboardNotifications];

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
    
    frameCashAmountInputView=self.cashAmountInputView.frame;
    self.cashAmountInputTextField.delegate=self;
    
    CGSize sizeScrollView=self.scrollView.contentSize;
    sizeScrollView.height +=keyboardHeight;
    self.scrollView.contentSize=sizeScrollView;
    
    //activity indicator
        self.animation =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.animation.frame =CGRectMake(self.view.frame.origin.x/2, self.view.frame.origin.y/2, 54, 54);
        self.animation.center = CGPointMake(WINDOW_WIDTH/2, self.tableView.center.y-100);
        //self.animation.color =[UIColor colorWithRed:0.106f green:0.557f blue:0.490f alpha:1.00f];
    
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
            cashInfoCell.delegate=self;
            break;
        }
    }
    
}

#pragma mark - init data
-(void)initData{
    
    [self.animation startAnimating];
    
    self.cashAmountInputTextField.text =@"";
    if(cashInfoCell){
        cashInfoCell.manualCountTextField.text =@"";
        cashInfoCell.manualCountLabel.text =@"";
    }
    
    // Johan
    zReportModel = [ZReportModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didZReport:) name:@"DidGetZReport" object:zReportModel];
    [zReportModel getZReport];
    // End
}

// Johan
-(void) didZReport:(NSNotification *) noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidGetZReport" object:zReportModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    [self.animation stopAnimating];
    if([respone.status isEqualToString:@"SUCCESS"]){
        NSDictionary * data =[zReportModel objectForKey:@"data"];
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                storeInfoDict =[data objectForKey:@"store_info"];
                
                if(storeInfoDict){
                    //show store info
                    self.storeLabel.text =[storeInfoDict objectForKey:@"store_name"];
                    self.cashierLabel.text =[storeInfoDict objectForKey:@"cashier"];
                    self.fromLabel.text =[storeInfoDict objectForKey:@"from"];
                    self.toLabel.text =[storeInfoDict objectForKey:@"to"];
                }
                
                //show default opening
                NSString * defaultCashAmount =[data objectForKey:@"default_opening_cash"];
                if(defaultCashAmount && defaultCashAmount.length >0){
                    self.cashAmountInputTextField.text =defaultCashAmount;
                }
                
                // show cash info
                paymentInfoArray =[data objectForKey:@"payment_info"];
                [self.tableView reloadData];
            });
        });
    }
}
// End

#pragma mark -set report type
-(void)setReportType:(MSReportType)type{
    reportType = type;
    
    switch (type) {
        case REPORT_MIDDAY:
            [self initReportMidday];
            break;
        case REPORT_ENDDAY:
            [self initReportEndday];
            break;
        case REPORT_DAILY:
            //todo
            break;
            
        default:
            break;
    }
}

#pragma mark - todo set title miday
-(void)initReportMidday{
    
    //[self.btnCloseStore setTitle:@"PRINT REPORT" forState:UIControlStateNormal];
    [self.btnCloseStore setTitle:@"EXPORT DATA" forState:UIControlStateNormal];
    
    self.cashAmountInputView.hidden=YES;
    [cashInfoCell setHideManualCount];
    
    //Hide header
    self.lblManualCountHeader.hidden =YES;
    self.lblDefferenceHeader.hidden =YES;
    
    //hide in cell
    
    NSArray * cells =[self.tableView visibleCells];
    for(UITableViewCell * cell in cells){
        if([cell isKindOfClass:[ZReportTableViewCell class]]){
            ((ZReportTableViewCell*)cell).manualCountLabel.hidden =YES;
            ((ZReportTableViewCell*)cell).differenceLabel.hidden =YES;
        }
    }
    
    
}

-(void)initReportEndday{
    
    [self.btnCloseStore setTitle:@"CLOSE STORE" forState:UIControlStateNormal];
    self.cashAmountInputView.hidden=NO;
    [cashInfoCell setShowManualCount];
    
    self.lblManualCountHeader.hidden =NO;
    self.lblDefferenceHeader.hidden =NO;
    
    //show in cell
    NSArray * cells =[self.tableView visibleCells];
    for(UITableViewCell * cell in cells){
        if([cell isKindOfClass:[ZReportTableViewCell class]]){
            ((ZReportTableViewCell*)cell).manualCountLabel.hidden =NO;
            ((ZReportTableViewCell*)cell).differenceLabel.hidden =NO;
        }
    }
    

}

-(void)initReportDaily{
    
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
        
        static NSString * cellIdentify =@"ZReportTableViewCell";
        //Normal cell
        cell = (ZReportTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell)
        {
            NSArray *nib=[[NSBundle mainBundle] loadNibNamed:cellIdentify owner:nil options:nil];
            for(id current in nib)
            {
                if([current isKindOfClass:[ZReportTableViewCell class]])
                {
                    cell=(ZReportTableViewCell *) current;
                    break;
                }
            }
        }
        
    }
    
    
    [(ZReportTableViewCell*)cell setDataWithDict:dict];
    
    if(indexPath.row%2==0){
        cell.backgroundColor =[UIColor groupTableViewBackgroundColor];
    }

    
    
    if(reportType ==REPORT_MIDDAY){
        ((ZReportTableViewCell*)cell).manualCountLabel.hidden =YES;
        ((ZReportTableViewCell*)cell).differenceLabel.hidden =YES;
        
    }else{
        ((ZReportTableViewCell*)cell).manualCountLabel.hidden =NO;
        ((ZReportTableViewCell*)cell).differenceLabel.hidden =NO;
    }
    
    return cell;
}

#pragma mark - textFieldDelegate

#pragma mark Upcase String TextField Input
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range  replacementString:(NSString *)string{
    
    return [Utilities validateNumber:textField currentStringInput:string];
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    activeField =textField;
    allowScrollView =YES;
    return  YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - registerForKeyboardNotifications
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if(allowScrollView){
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your application might not need or want this behavior.
        CGRect aRect = self.view.frame;
        aRect.size.height -= kbSize.height;
        if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
            CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y+kbSize.height);
            
            [UIView animateWithDuration:0.5 animations:^{
                [self.scrollView setContentOffset:scrollPoint animated:YES];
            }];
            
        }
        
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
    }];
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
    
    if(reportType==REPORT_MIDDAY){
        [self exportSaveDataToImage];
        
    }else{
        
        //Close Store
        [self checkAndCloseStore];
    }
}

-(void)checkAndCloseStore{
    
    if(cashInfoCell.manualCountTextField.text.length==0){
        [self.animation stopAnimating];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Manual count" message:@"is empty ?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag =101;
        
        [alert show];
        
        [cashInfoCell.manualCountTextField becomeFirstResponder];
        
        return;
        
    }else if(self.cashAmountInputTextField.text.length==0){
        [self.animation stopAnimating];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"Cash amount kept in drawer must not empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
        
        [self.cashAmountInputTextField becomeFirstResponder];
        
        return;
    }
    
    else{
         [self.animation startAnimating];
        
        // Johan
        closeStoreModel = [CloseStoreModel new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCloseStore:) name:@"DidCloseStore" object:closeStoreModel];
        [closeStoreModel closeStore:cashInfoCell.manualCountTextField.text openingAmount:self.cashAmountInputTextField.text];
        // End
    }
}

// Johan
- (void) didCloseStore:(NSNotification *) noti {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidCloseStore" object:closeStoreModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    [self.animation stopAnimating];
    if([respone.status isEqualToString:@"SUCCESS"]){
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Close store successful!" message:@"Do you want to save data?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
                alert.tag=102;
                [alert show];
                NSString *keyParams = [[Configuration globalConfig].productCache objectForKey:@"report.zreport"];
                [[Configuration globalConfig].productCache removeObjectForKey:keyParams];
                [self initData];
            });
        });
    }
}
// End

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    //Export data
    if(alertView.tag ==102){
        
        if(buttonIndex ==1){
            [self exportSaveDataToImage];            
        }
        
        [self initData];
        return;
    }
    
    //Manual count
    if(alertView.tag ==101){
        if(buttonIndex ==1){
            cashInfoCell.manualCountTextField.text =@"0";
            [self.view endEditing:YES];
            return;
        }else{
            [cashInfoCell.manualCountTextField becomeFirstResponder];
        }
    }
    
}

#pragma mark - ZReportCashInfoCellDelegate
-(void)manualCountEventClick{
    ManualCountVC * countVC =[[ManualCountVC alloc] initWithNibName:@"ManualCountVC" bundle:nil];
    countVC.delegate=self;
    
    UIPopoverController * popOverController =[[UIPopoverController alloc] initWithContentViewController:countVC];
    popOverController.popoverContentSize=countVC.view.frame.size;
    [popOverController presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
    
}

-(void)disableScrollViewKeyboardShow{
    //textField in manual count then disable scroll
    allowScrollView =NO;
}

#pragma mark - export & save data to image
-(void)exportSaveDataToImage{
    //Gin edit
//    UIImage *image=  [Utilities imageWithView:self.viewExportImage];
    NSString *str=@"Export Reports";
    CGRect frame = self.tableView.frame;
    float height = frame.size.height;
    frame.size.height = self.tableView.contentSize.height;
    self.tableView.frame = frame;
    
    self.viewExportImage.backgroundColor = [UIColor whiteColor];
    UIImage *img = [Utilities imageWithView:self.viewExportImage];
    frame.size.height = height;
    self.tableView.frame = frame ;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, WINDOW_WIDTH, WINDOW_HEIGHT)];
    imgView.backgroundColor = [UIColor whiteColor];
    [imgView setImage:img];
    imgView.contentMode = UIViewContentModeTop|UIViewContentModeScaleAspectFit;
    [view addSubview:imgView];
    UIImage *image = [Utilities imageWithView:view];
    NSArray *postItems=@[str,image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    // Change Rect to position Popover
    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 1, 1)inView:self.view permittedArrowDirections:0 animated:YES];
}
//End
@end
