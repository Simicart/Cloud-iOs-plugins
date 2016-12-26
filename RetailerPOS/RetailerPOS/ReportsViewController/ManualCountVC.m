//
//  ManualCountVCViewController.m
//  RetailerPOS
//
//  Created by NGUYEN DUC CHIEN on 2/28/16.
//  Copyright © 2016 MARCUS Nguyen. All rights reserved.
//

#import "ManualCountVC.h"
#import "ManualCountCell.h"
#import "Denomination.h"
#import "SumTotalCountCell.h"

@interface ManualCountVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnTotal;
@property (strong, nonatomic) IBOutlet UIView *headerView;


@end

@implementation ManualCountVC
{
    NSArray * listCountManualArray;
    float totalSumManual;
    SumTotalCountCell * footerCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initStyle];
    
    [self loadDataLocal];
    
    [self initData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCaculateSumManualCount) name:@"NOTIFY_CACULATE_SUM_MANUAL" object:nil];
    
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureView)];
    tap.numberOfTapsRequired =1;
    
    [self.view addGestureRecognizer:tap];
    
    footerCell =(SumTotalCountCell *)[[[NSBundle mainBundle] loadNibNamed:@"SumTotalCountCell" owner:nil options:nil] firstObject];
    
}

-(void)initStyle{
    self.btnClear.layer.cornerRadius=5.0;
    self.btnTotal.layer.cornerRadius=5.0;
    
    //color
    self.headerView.backgroundColor = [UIColor barBackgroundColor];
    self.btnTotal.backgroundColor = [UIColor barBackgroundColor];
    
}

-(void)loadDataLocal{
    listCountManualArray =[Denomination MR_findAllSortedBy:@"deno_id" ascending:YES];
    if(listCountManualArray && listCountManualArray.count >0){
        [self.tableView reloadData];
    }
}

-(void)initData{
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    [[APIManager shareInstance] getListManualCount:^(BOOL success, id result) {
        
        if(success && [result objectForKey:@"data"]){
            NSArray * items =[result objectForKey:@"data"];
            if(items && [items isKindOfClass:[NSArray class]]){
                
                dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
                dispatch_async(backgroundQueue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self insertDatabase:items];
                        
                    });
                });
            }
        }
    }];
}


#pragma mark - show caulate sum manual count
-(void)showCaculateSumManualCount{
    
    totalSumManual=0;
    NSArray * cells =[self.tableView visibleCells];
    for (id cell in cells)
    {
        if([cell isKindOfClass:[ManualCountCell class]]){
            CGFloat sumItem =((ManualCountCell *)cell).sumTextField.text.floatValue;
            totalSumManual +=sumItem;
        }
    }
    
    if(footerCell.sumTotalLabel){
        footerCell.sumTotalLabel.text =[NSString stringWithFormat:@"%.02f",totalSumManual];
    }
}

#pragma mark - table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(listCountManualArray){
        return  listCountManualArray.count +1;
        
    }else{
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == listCountManualArray.count){
        return footerCell;
    }
    
    static  NSString * identifyCell =@"ManualCountCell";
    ManualCountCell * cell  =[tableView dequeueReusableCellWithIdentifier:identifyCell];
    if(!cell){
        NSArray * nib =[[NSBundle mainBundle] loadNibNamed:identifyCell owner:nil options:nil];
        if(nib && nib.count>0){
            cell =( ManualCountCell *)nib[0];
        }
    }
    
    Denomination * denomination =[listCountManualArray objectAtIndex:indexPath.row];
    [cell setData:denomination];
    
    return cell;
}

- (IBAction)clearButtonClick:(id)sender {
    
    NSArray * cells =[self.tableView visibleCells];
    
    for (id cell in cells)
    {
        if([cell isKindOfClass:[ManualCountCell class]]){
            ((ManualCountCell *)cell).sumTextField.text =@"";
            ((ManualCountCell *)cell).countTextField.text=@"";
        }
    }
    
    footerCell.sumTotalLabel.text =@"0.00";
    
    totalSumManual =0;
    
}

- (IBAction)totalButtonClick:(id)sender {
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(getTotalManualCount:)]){
        
        [self.delegate getTotalManualCount:totalSumManual];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)insertDatabase:(NSArray *)items{
    if(items && items.count>0){
        for(NSDictionary * dict in items){
            
            NSNumber * denoId =[NSNumber numberWithInt:[[dict objectForKey:@"deno_id"] intValue]];
            
            Denomination * denomination =[[Denomination MR_findByAttribute:@"deno_id" withValue:denoId] firstObject];
            if(!denomination){
                denomination =[Denomination MR_createEntity];
                denomination.deno_id =denoId;
            }
            
            denomination.deno_name =[NSString stringWithFormat:@"%@",[dict objectForKey:@"deno_name"]];
            denomination.deno_value =[NSString stringWithFormat:@"%@",[dict objectForKey:@"deno_value"]];
        }
        
        //save database
        [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreAndWait];
        
        [self loadDataLocal];
    }
}

#pragma mark - Tap for View
-(void)tapGestureView{
    [self.view endEditing:YES];
    [self showCaculateSumManualCount];
}

@end
