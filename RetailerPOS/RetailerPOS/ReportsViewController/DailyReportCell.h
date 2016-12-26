//
//  DailyReportCell.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 2/26/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyReportCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *incrementId;
@property (weak, nonatomic) IBOutlet UILabel *cashierName;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *billingName;
@property (weak, nonatomic) IBOutlet UILabel *grandTotal;
@property (weak, nonatomic) IBOutlet UILabel *createdAt;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *cashDrawer;

-(void)setData:(NSDictionary *)dict;


@end
