//
//  XReportVC.h
//  SimiPOS
//
//  Created by Nguyen Duc Chien on 2/25/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XReportVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

-(void)initData;

@end
