//
//  XReportVC.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 2/25/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import "DailyReportVC.h"
#import "DailyReportCell.h"


@interface DailyReportVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnShareData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIActivityViewController *activityViewController;
@property (strong, nonatomic) UIActivityIndicatorView * animation;
@property (weak, nonatomic) IBOutlet UIView *viewExportImage;

@end

@implementation DailyReportVC
{
    NSArray * listData;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
      [self initData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initStyle];
    
}


-(void)initStyle{
    self.btnShareData.layer.cornerRadius=5.0;
    self.btnShareData.backgroundColor = [UIColor barBackgroundColor];
    
    self.tableView.layer.borderColor =[UIColor lightGrayColor].CGColor;
    self.tableView.layer.borderWidth =0.5;
    
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    
    //activity indicator
    self.animation =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.animation.frame =CGRectMake(self.view.frame.origin.x/2, self.view.frame.origin.y/2, 54, 54);
    self.animation.center = CGPointMake(WINDOW_WIDTH/2, self.tableView.center.y-100);
    [self.tableView addSubview:self.animation];
    
    [self.animation startAnimating];
}

#pragma mark - init data
-(void)initData{
    
    [self.animation startAnimating];
    
    [[APIManager shareInstance] getDailyReport:^(BOOL success, id result) {
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

#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(listData && listData.count >0){
        return listData.count ;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DailyReportCell * cell = (DailyReportCell *)[tableView dequeueReusableCellWithIdentifier:@"DailyReportCell"];
    if (!cell)
    {
        NSArray *nib=[[NSBundle mainBundle] loadNibNamed:@"DailyReportCell" owner:nil options:nil];
        for(id current in nib)
        {
            if([current isKindOfClass:[DailyReportCell class]])
            {
                cell=(DailyReportCell *) current;
                break;
            }
        }
    }
    
    if(indexPath.row%2==0){
        cell.backgroundColor =[UIColor groupTableViewBackgroundColor];
    }
    
    //set data
    [cell setData:[listData objectAtIndex:indexPath.row]];
    
    return cell;
}

- (IBAction)shareDataButtonClick:(id)sender {
    
    //to attach the image and text with sharing
    UIImage *image=[Utilities imageWithView:self.viewExportImage];
    NSString *str=@"Daily Reports";
    NSArray *postItems=@[str,image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    
    // Change Rect to position Popover
    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 1, 1)inView:self.view permittedArrowDirections:0 animated:YES];
    
}


@end
