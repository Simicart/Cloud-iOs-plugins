//
//  SendEmailVC.h
//  SimiPOS
//
//  Created by mac on 3/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface SendEmailVC : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextField *txtSend;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (strong, nonatomic) Order * order;

@end
