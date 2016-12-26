//
//  XReportVC.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 2/25/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSReportType) {
    REPORT_MIDDAY,
    REPORT_ENDDAY,
    REPORT_DAILY
};

@interface ZReportVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

#pragma mark -set report type
-(void)setReportType:(MSReportType)type;

-(void)initData;

@end
