//
//  ActivateKeyViewController.h
//  SimiPOS
//
//  Created by mac on 3/11/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldValidator.h"

@protocol ActivateKeyViewControllerDelegate <NSObject>

@required
-(void)activeKeyButtonClickDelegate;
-(void)activeKeySelectItem:(NSString *)url;
@end
@interface ActivateKeyViewController : UIViewController

@property (weak, nonatomic) id<ActivateKeyViewControllerDelegate> delegate;
@property (strong, nonatomic) UIPopoverController * popOverController;
@property (weak, nonatomic) IBOutlet UITableView *tblView;

@property (weak, nonatomic) IBOutlet UIButton *btnActivateNewKey;
@property (weak, nonatomic) IBOutlet TextFieldValidator *txtActivateKey;


@property (strong, nonatomic) IBOutlet UIButton *btnClear;
@property (weak, nonatomic) IBOutlet UIButton *btnRegisterTrial;
@property (weak, nonatomic) IBOutlet UIView *registerTrialForm;
@property (weak, nonatomic) IBOutlet TextFieldValidator *registerTrialEmail;
@property (weak, nonatomic) IBOutlet TextFieldValidator *registerTrialDomain;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmitRegister;
@property (weak, nonatomic) IBOutlet UIImageView *btnRegisterBack;

-(void)setActivateKeyInputStyle;
-(void)setActivateKeyShowInfo;
- (IBAction)showRegisterTrialForm:(id)sender;
- (IBAction)submitRegister:(id)sender;

@end
