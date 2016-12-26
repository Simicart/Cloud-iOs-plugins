//
//  CashDrawerViewController.m
//  RetailerPOS
//
//  Created by mac on 2/24/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import "CashDrawerViewController.h"
#import "XMComboBoxView.h"
#import "CashDrawerTableViewCell.h"
#import "ShowContentDetail.h"

@interface CashDrawerViewController ()<UIDropDownMenuDelegate,UITableViewDataSource,UITableViewDelegate ,UITextFieldDelegate,UITextViewDelegate,CashDrawerTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet XMComboBoxView *listCashIn;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIView *groupCurrentBalanceView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *groupNoteView;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIView *groupTableView;
@property (weak, nonatomic) IBOutlet UITextField *cashAmountTextField;
@property (strong, nonatomic) UIActivityIndicatorView * animation;
@property (weak, nonatomic) IBOutlet UILabel *currentBalanceLabel;
@property (weak, nonatomic) IBOutlet UIView *headerView;


@end

@implementation CashDrawerViewController
{
    NSArray * listData;
    NSString * cashTypeSelected;
}

static CashDrawerViewController *_sharedInstance = nil;

+(CashDrawerViewController*)sharedInstance
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
    
    [self hideNote];
    
    [self initDefault];
    
    [self initData];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    //_sharedInstance=self;
    
   // [self hideNote];
    
   // [self initDefault];
    
   // [self initData];
}

-(void)initDefault{
    
    self.cashAmountTextField.delegate=self;
    
    self.btnSubmit.layer.cornerRadius =4.0;
    self.groupCurrentBalanceView.layer.cornerRadius=5.0;
    
    self.noteTextView.layer.cornerRadius=5.0;
    self.noteTextView.layer.borderWidth=0.5;
    self.noteTextView.text=@"";
    self.noteTextView.delegate=self;
    
    //set color
    self.btnSubmit.backgroundColor = [UIColor barBackgroundColor];
    self.headerView.backgroundColor = [UIColor barBackgroundColor];
    self.groupCurrentBalanceView.backgroundColor = [UIColor barBackgroundColor];
    
    [XMComboBoxView setButtonImage:@"dropdown-arrow-icon"];
    
    [self.listCashIn makeMenu:self.view andIdentifier:@"listCashIn" caption:nil data:nil section:nil];
    self.listCashIn.delegate = self;
    
   // UITapGestureRecognizer * tapGesture =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHideKeyboard)];
   // [self.view addGestureRecognizer:tapGesture];
    
    //activity indicator
    self.animation =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.animation.frame =CGRectMake(self.view.frame.origin.x/2, self.view.frame.origin.y/2, 54, 54);
    self.animation.center = CGPointMake(self.tableView.center.x, self.tableView.center.y-100);
    [self.tableView addSubview:self.animation];
    
    [self.animation startAnimating];
    
    //Drop down list
    NSMutableArray * listItem =[[NSMutableArray alloc] initWithObjects:@"Cash In",@"Cash Out", nil];
    [self.listCashIn loadData:listItem data:listItem section:nil];
    
}

-(void)tapHideKeyboard{
    [self.view endEditing:YES];
}


#pragma mark - Call API get Data
-(void)initData{
    
    [self getCurrentBalance];
    
    [self getTransctionList];
}


-(void)getTransctionList{
    
    [self.animation startAnimating];
    
    [[APIManager shareInstance] getTransactionList:^(BOOL success, id result) {
        
        [self.animation stopAnimating];
        
        if(success && [result objectForKey:@"data"]){
            dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    listData =[result objectForKey:@"data"];
                        [self.tableView reloadData];
                    
                });
            });
            
        }
    }];
}

-(void)getCurrentBalance{
    
    [self.animation startAnimating];
    
    [[APIManager shareInstance] getCurrentBalance:^(BOOL success, id result) {
        
        [self.animation stopAnimating];
        
        if(success && [result objectForKey:@"data"]){
            dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSString * currentBalance =[result objectForKey:@"data"];
                    
                    if(currentBalance){
                        self.currentBalanceLabel.text =currentBalance;
                    }
                });
            });
            
        }
    }];
}


- (IBAction)showMenuButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOW_LEFT_SIDE_BAR_MENU object:nil];
}


#pragma mark - Implementation UIDropDownMenuDelegate
- (void)DropDownMenuDidChange:(NSString *)identifier selectedString:(NSString *)ReturnValue{
    
    [self.view endEditing:YES];
    
    if([ReturnValue isEqualToString:@"Cash In"]){
        cashTypeSelected =@"in";
    }else{
        cashTypeSelected =@"out";
    }
    
}

#pragma mark - Implementation tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(listData){
        return  listData.count;
    }
    
    return 0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString * cellIdentifier= @"CashDrawerTableViewCell";
    
    CashDrawerTableViewCell *cell = (CashDrawerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:nil options:nil];
        for(id current in nib)
        {
            if([current isKindOfClass:[CashDrawerTableViewCell class]])
            {
                cell=(CashDrawerTableViewCell *) current;
                break;
            }
        }
    }
    
    if(indexPath.row%2==0){
        cell.backgroundColor =[UIColor groupTableViewBackgroundColor];
    }
    
    [cell setData:[listData objectAtIndex:indexPath.row]];
    cell.delegate=self;
    
    return cell;
}


#pragma mark - clear note
- (IBAction)clearNoteButtonClick:(id)sender {
    self.noteTextView.text=@"";
}

#pragma mark - hide note
- (IBAction)hideNoteButtonClick:(id)sender {
    [self hideNote];
}

#pragma mark - text field delegate


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range  replacementString:(NSString *)string{
    
    return [Utilities validateNumber:textField currentStringInput:string];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [self showNote];
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self showNote];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - hide/show note
-(void)showNote{
    
    self.groupNoteView.hidden=NO;
    
    CGRect frameGroupTableView=self.groupTableView.frame;
    
    frameGroupTableView.origin.y =CGRectGetMaxY(self.groupNoteView.frame)+10;
    frameGroupTableView.size.height = fabs(CGRectGetHeight(self.view.frame) - frameGroupTableView.origin.y)-10;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.groupTableView.frame=frameGroupTableView;
    }];
}

-(void)hideNote{
    self.groupNoteView.hidden=YES;
    
    CGRect frameGroupTableView=self.groupTableView.frame;
    frameGroupTableView.origin.y =CGRectGetMaxY(self.groupCurrentBalanceView.frame)+10;
    frameGroupTableView.size.height = fabs(CGRectGetHeight(self.view.frame) - frameGroupTableView.origin.y)-10;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.groupTableView.frame=frameGroupTableView;
    }];
}

- (IBAction)submitButtonClick:(id)sender {
    
    if(self.cashAmountTextField.text.length ==0){
        [Utilities alert:@"Message" withMessage:@"Cash amount is not empty"];
        return;
    }
    
    [self.animation startAnimating];
    
    [[APIManager shareInstance] addTransactionAmount:self.cashAmountTextField.text Note:self.noteTextView.text Type:cashTypeSelected Callback:^(BOOL success, id result) {
        [self.animation stopAnimating];
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
        dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(success){
                    NSDictionary * dict =[result objectForKey:@"data"];
                    
                    if(dict && [dict objectForKey:@"msg"]){
                        
                        NSString * message =[NSString stringWithFormat:@"%@",[dict objectForKey:@"msg"]];
                        [Utilities alert:@"Message" withMessage:message];
                        
                    }
                    
                    [self clearDataInput];
                    
                }else{
                    
                    [Utilities alert:@"Message" withMessage:MESSAGE_SUBMIT_FAIL];
                }
                
            });
        });
        
    }];
}

-(void)clearDataInput{
    
    [self.view endEditing:YES];
    
    self.cashAmountTextField.text =@"";
    self.noteTextView.text=@"";
    
    [self hideNote];
    
    [self initData];
}

#pragma mark - text view delegate
- (void)textViewDidEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    [self.view endEditing:YES];
}


#pragma mark - CashDrawerTableViewCellDelegate
-(void)showContextDetail:(NSString *)context{
    
    if(context == nil || context.length == 0){
        return;
    }
    
    ShowContentDetail * detailVC =[[ShowContentDetail alloc] initWithNibName:@"ShowContentDetail" bundle:nil];
    detailVC.contentString=context;
    
    UIPopoverController * popOverController =[[UIPopoverController alloc] initWithContentViewController:detailVC];
    popOverController.popoverContentSize=detailVC.view.frame.size;
    [popOverController presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 1, 1) inView:self.view permittedArrowDirections:0 animated:YES];
}


@end
