//
//  ManualCountCellTableViewCell.h
//  SimiPOS
//
//  Created by mac on 2/28/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Denomination.h"

@interface ManualCountCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *noteName;
@property (weak, nonatomic) IBOutlet UILabel *noteValue;
@property (weak, nonatomic) IBOutlet UITextField *countTextField;
@property (weak, nonatomic) IBOutlet UITextField *sumTextField;

-(void)setData:(Denomination *) denomination;


@end
