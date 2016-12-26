//
//  CashDrawerTableViewCell.h
//  SimiPOS
//
//  Created by nguyen duc chien on 2/24/16.
//  Copyright © 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XReportTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *paymentMethodLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOrderLabel;
@property (weak, nonatomic) IBOutlet UILabel *recordGrandTotalLabel;

-(void)setDataWithDict:(NSDictionary*)dict;
@end
