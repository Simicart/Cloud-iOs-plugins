//
//  XReportVC.m
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 2/25/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import "ItemsShipVC.h"
#import "ItemsShipCell.h"


@interface ItemsShipVC ()<UITableViewDataSource,UITableViewDelegate,ItemsShipCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIActivityViewController *activityViewController;
@property (strong, nonatomic) UIActivityIndicatorView * animation;
@property (strong, nonatomic) UIBarButtonItem *shipButton;

@end

@implementation ItemsShipVC
{
    NSArray * listData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createMenuBarItem];
    
    [self initStyle];
    
    listData =[self.order objectForKey:@"items"];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:tap];    
    
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
    
//    for(ItemsShipCell * cell in [self.tableView visibleCells]){
//        [cell validateQtyShip];
//    }
    
}

-(void)createMenuBarItem{

    self.title = NSLocalizedString(@"Items to Ship", nil);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];

    UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    buttonCancel.layer.cornerRadius =3.0;
    buttonCancel.backgroundColor =[UIColor buttonCancelColor];
    [buttonCancel addTarget:self action:@selector(cancelShip) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton =[[UIBarButtonItem alloc] initWithCustomView:buttonCancel];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIButton *buttonShip = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [buttonShip setTitle:@"Ship" forState:UIControlStateNormal];
    buttonShip.backgroundColor =[UIColor buttonSubmitColor];
    buttonShip.layer.cornerRadius =3.0;
    [buttonShip addTarget:self action:@selector(shipButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton =[[UIBarButtonItem alloc] initWithCustomView:buttonShip];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)cancelShip{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)shipButtonClick{
    
    [self.animation startAnimating];
    
    NSMutableDictionary * items =[[NSMutableDictionary alloc] init];
    //NSArray * item;
    
    for(ItemsShipCell * cell in [self.tableView visibleCells]){
        [items setObject:cell.txtQtyShip.text forKey:cell.itemId];
    }

    if(items.allKeys.count == 0){
        return;
    }
    
    [[APIManager shareInstance] orderShipmentOrderId:[self.order getIncrementId] WithItems:items Callback:^(BOOL success, id result) {
        [self.animation stopAnimating];
        
        DLog(@"%@",result);
        if(success){
            
           // [self.parrentView.shipBtn setEnabled:NO];
            [self performSelectorOnMainThread:@selector(mainReloadData) withObject:nil waitUntilDone:NO];
                     
             [Utilities toastSuccessTitle:@"Ship" withMessage:MESSAGE_SUBMIT_SUCCESS withView:self.view];
            
        }else{
            [Utilities toastFailTitle:@"Ship" withMessage:MESSAGE_SUBMIT_FAIL withView:self.view];
        }
        
        [self performSelector:@selector(delayDismissView) withObject:nil afterDelay:1.0];
        
    }];
    
}

-(void)mainReloadData{

    [self.parrentView loadOrder];
    
    //loadOrder
}

-(void)delayDismissView{
      [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)initStyle{

    self.tableView.layer.borderColor =[UIColor lightGrayColor].CGColor;
    self.tableView.layer.borderWidth =0.5;
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    //activity indicator
    self.animation =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.animation.frame =CGRectMake(self.tableView.frame.origin.x/2, self.tableView.frame.origin.y/2, 54, 54);
    self.animation.center = CGPointMake(self.tableView.center.x, self.tableView.center.y-100);
    
    [self.tableView addSubview:self.animation];
    
}

#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(listData && listData.count >0){
        return listData.count ;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ItemsShipCell * cell = (ItemsShipCell *)[tableView dequeueReusableCellWithIdentifier:@"ItemsShipCell"];
    if (!cell)
    {
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"ItemsShipCell" owner:nil options:nil];
        for(id current in nib)
        {
            if([current isKindOfClass:[ItemsShipCell class]])
            {
                cell=(ItemsShipCell *) current;
                cell.delegate=self;
                break;
            }
        }
    }
    
//    if(indexPath.row%2==0){
//        cell.backgroundColor =[UIColor groupTableViewBackgroundColor];
//    }
    
    //set data
    [cell setData:[listData objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark - ItemsShipCellDelegate

-(void)enableShipButton:(BOOL)status{
    
    if(status){
        [self.shipButton setEnabled:YES];
    }else{
        [self.shipButton setEnabled:NO];
    }
}

@end
