//
//  SynchronizationVC.m
//  RetailerPOS
//
//  Created by mac on 4/13/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SynchronizationVC.h"
#import "SynchronizationCell.h"

@interface SynchronizationVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *hearderView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SynchronizationVC
{
    SynchronizationCell * cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    [self initStyle];
    
    cell = (SynchronizationCell *)[[[NSBundle mainBundle] loadNibNamed:@"SynchronizationCell" owner:nil options:nil] firstObject];
}

-(void)initStyle{
    
    self.hearderView.backgroundColor = [UIColor barBackgroundColor];
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 708;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell;
}



- (IBAction)showMenuButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOW_LEFT_SIDE_BAR_MENU object:nil];
}

- (IBAction)synchronationButtonClick:(id)sender {
    
    DLog(@"synchronationButtonClick");
    
    [cell synchronizationAll];
}


@end
