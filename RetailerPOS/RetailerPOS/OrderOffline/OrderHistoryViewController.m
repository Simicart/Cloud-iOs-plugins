//
//  OrderHistoryViewController.m
//  RetailerPOS
//
//  Created by mac on 4/26/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "OrderHistoryViewController.h"
#import "OrderHistoryCell.h"

@interface OrderHistoryViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OrderHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
}

- (IBAction)showMenuButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOW_LEFT_SIDE_BAR_MENU object:nil];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 181;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static  NSString * cellID =@"OrderHistoryCell";
    OrderHistoryCell * cell =[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = (OrderHistoryCell *)[[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] firstObject];
    }
    
    return cell;
}

@end

