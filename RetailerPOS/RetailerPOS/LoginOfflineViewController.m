//
//  LoginOfflineViewController.m
//  RetailerPOS
//
//  Created by mac on 4/23/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "LoginOfflineViewController.h"
#import "JJMaterialTextfield.h"

#import "ActivateKeyViewController.h"
#import "UIViewController+MJPopupViewController.h"

#import "MRDemoInfo.h"
#import "UserStoreSettingVC.h"

//Model database
#import "Stores.h"
#import "CashDrawer.h"

@interface LoginOfflineViewController ()<UITextFieldDelegate,ActivateKeyViewControllerDelegate>

@property (strong, nonatomic)  JJMaterialTextfield *userNameTextfield;
@property (strong, nonatomic)  JJMaterialTextfield *passTextField;
@property (strong, nonatomic)  UIButton *loginButton;
@property (strong, nonatomic) UIPopoverController * popOverController;

@property (weak, nonatomic) IBOutlet UIButton *moreDetailButton;

@end

@implementation LoginOfflineViewController
@synthesize userNameTextfield,passTextField,loginButton;
@synthesize popOverController;

static LoginOfflineViewController *_sharedInstance = nil;

+(LoginOfflineViewController*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.navigationController.navigationBarHidden =YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Installation Guide", nil)];
    [attString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:NSMakeRange(0, attString.length)];
    [attString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, attString.length)];
    [self.moreDetailButton setAttributedTitle:attString forState:UIControlStateNormal];
    
    //JJMaterialTextfield *userNameTextfield =[[JJMaterialTextfield alloc] initWithFrame:CGRectMake(40, 150, self.view.frame.size.width-80, 34)];
    userNameTextfield =[[JJMaterialTextfield alloc] initWithFrame:CGRectMake(self.view.center.x-150, 200, 300, 34)];
    
    
    userNameTextfield.textColor=[UIColor whiteColor];
    
    userNameTextfield.enableMaterialPlaceHolder = YES;
    userNameTextfield.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    userNameTextfield.lineColor=[UIColor colorWithRed:0.482 green:0.800 blue:1.000 alpha:1.000];
    userNameTextfield.tintColor=[UIColor colorWithRed:0.482 green:0.800 blue:1.000 alpha:1.000];
    userNameTextfield.placeholder=@"Username";
    userNameTextfield.delegate=self;
    userNameTextfield.returnKeyType=UIReturnKeyNext;
    userNameTextfield.tag=1;
    userNameTextfield.font = [UIFont systemFontOfSize:20];
    
    [self.view addSubview:userNameTextfield];
    
    //JJMaterialTextfield *passTextField =[[JJMaterialTextfield alloc] initWithFrame:CGRectMake(40, 220, self.view.frame.size.width-80, 34)];
    passTextField =[[JJMaterialTextfield alloc] initWithFrame:CGRectMake(self.view.center.x-150, 270, 300, 34)];
    passTextField.textColor=[UIColor whiteColor];
    
    passTextField.enableMaterialPlaceHolder = YES;
    passTextField.errorColor=[UIColor colorWithRed:0.910 green:0.329 blue:0.271 alpha:1.000]; // FLAT RED COLOR
    passTextField.lineColor=[UIColor colorWithRed:0.482 green:0.800 blue:1.000 alpha:1.000];
    passTextField.tintColor=[UIColor colorWithRed:0.482 green:0.800 blue:1.000 alpha:1.000];
    passTextField.placeholder=@"Password";
    passTextField.delegate=self;
    passTextField.secureTextEntry=YES;
    passTextField.returnKeyType=UIReturnKeyDone;
    passTextField.tag=2;
    passTextField.font = [UIFont systemFontOfSize:20];
    passTextField.textColor = [UIColor whiteColor];
    passTextField.placeholderAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:20],
                                            NSForegroundColorAttributeName : [[UIColor lightTextColor] colorWithAlphaComponent:.8]};
    [self.view addSubview:passTextField];
    

}


- (IBAction)installationGuideButtonClick:(id)sender {
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.magestore.com/productfile/index/view/fileid/311/"]];
}

#pragma mark - UITextField Delegate
-(void)textFieldDidEndEditing:(JJMaterialTextfield *)textField{
    if (textField.text.length==0) {
        [textField showError];
    }else{
        [textField hideError];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    UIView *view = [self.view viewWithTag:textField.tag + 1];
    if (!view)
        [textField resignFirstResponder];
    else
        [view becomeFirstResponder];
    return YES;
    
}

-(void)closePopUp{
    [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationSlideBottomBottom];

}

- (IBAction)activeKeyButtonClick:(id)sender {
    
    MJPopupAllowDismissViewController =YES;
    ActivateKeyViewController * activateKeyVC =[[ActivateKeyViewController alloc] initWithNibName:@"ActivateKeyViewController" bundle:nil] ;
    activateKeyVC.delegate =self;
    [self presentPopupViewController:activateKeyVC animationType:MJPopupViewAnimationSlideTopBottom];
    
}

#pragma mark -  ActivateKeyViewControllerDelegate

-(void)activeKeyButtonClickDelegate{
    [self closePopUp];
}
-(void)activeKeySelectItem:(NSString *)url{
    DLog(@"url:%@",url);
}

#pragma mark - SHOW/HIDE INDICATOR

-(void)showIndicatorView{
    CGPoint centerIndicator =self.view.center;
    centerIndicator.y += 100;
    [Utilities showIndicator:self.view setCenter:centerIndicator];
}

-(void)hideIndicatorView{
      [Utilities hideIndicator];
}

#pragma mark - LOGIN BUTTON CLICK
- (IBAction)tryDemoButtonClick:(id)sender {
    
    [self showIndicatorView];
    
    if(![InternetConnection canAccess]){
        //No Internet login Offline
        
        //b1: Cap nhat URL Demo
        MRDemoInfo * mrDemoInfo =[MRDemoInfo findFirst];
        if(mrDemoInfo){
            
            [[Configuration globalConfig] setObject:mrDemoInfo.demo_url forKey:API_URL_NAME];
            [self openStoreSetting];
            
            
        }else{
            [Utilities alert:@"Alert" withMessage:@"Internet connection can not access"];
        }
        
        return ;
    }
    

    [[APIManager shareInstance] getDemoDataCallback:^(BOOL success, id result) {
       
        [self hideIndicatorView];
        
        if (success) {
            
            // DLog(@"result:%@",result);
            
            NSDictionary * data =[result objectForKey:@"data"];
            
            if(data && [data isKindOfClass:[NSDictionary class]]){
                
                NSString * demo_url =[NSString stringWithFormat:@"%@",[data objectForKey:@"demo_url"]];
                [[Configuration globalConfig] setObject:demo_url forKey:API_URL_NAME];
                
                NSString * demo_user =[NSString stringWithFormat:@"%@",[data objectForKey:@"demo_user"]];
                NSString * demo_pass =[NSString stringWithFormat:@"%@",[data objectForKey:@"demo_pass"]];
                
                //Cap nhat database
                [MRDemoInfo MR_truncateAll];
                
                MRDemoInfo * mrDemoInfo =[MRDemoInfo MR_createEntity];
                mrDemoInfo.demo_url =demo_url;
                mrDemoInfo.demo_user =demo_user;
                mrDemoInfo.demo_pass =demo_pass;
                
                SAVE_DATABASE;
                
                
                SetBoolValue(YES, KEY_CHECK_USE_TRY_DEMO); //DUNG DE KIEM TRA PHAN QUYEN TRONG PHAN SETTING ACCOUNT
                
                dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
                dispatch_async(backgroundQueue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self goToTryDemo:demo_user Password:demo_pass];
                        
                    });
                });
                
            }
            
        } else {
            
            if([result isKindOfClass:[NSString class]]){
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:MESSAGE_CONNECTOR_ERROR];
                return ;
                
            }else if([result isKindOfClass:[NSDictionary class]]){
                NSString * message =[result objectForKey:@"data"];
                if(message){
                    [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:message];
                    return ;
                }
                
            }else{
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:MESSAGE_SUBMIT_FAIL];
            }
            
        }
    }];
    
    
}


-(void)goToTryDemo:(NSString *)userDemo Password:(NSString *)passwordDemo{
    
    [[APIManager shareInstance] loginWithUsername:userDemo Password:passwordDemo Callback:^(BOOL success, id result) {
        
        if (success) {
            
            //  DLog(@"result:%@",result);
            
            NSDictionary * data =[result objectForKey:@"data"];
            NSString * session =[NSString stringWithFormat:@"%@",[data objectForKey:@"session"]];
            
            NSLog(@"session:%@",session);
            
            [[Configuration globalConfig] setObject:session forKey:@"session"];
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //insert store , cash drawer in database
                    [self updateUserInfo:data];
                    
                    [self openStoreSetting];
                    
                });
            });
            
        } else {
            
            
            if([result isKindOfClass:[NSString class]]){
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:result];
                return ;
            }
            
            NSString * message =[result objectForKey:@"data"];
            if(message){
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:message];
                return ;
            }else{
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:@"Please check your domain"];
            }
            
        }
    }];
}

#pragma mark - Setting Store & Cash Drawer
- (void)openStoreSetting
{
    UserStoreSettingVC *storeSetting = [[UserStoreSettingVC alloc] initWithNibName:@"UserStoreSettingVC" bundle:nil];
    [self.navigationController pushViewController:storeSetting animated:YES];
}

#pragma mark - insert store , cash drawer in database
-(void)updateUserInfo:(NSDictionary *)dict{
    if(!dict){
        return;
    }
    
    //update stores
    NSArray * stores =[dict objectForKey:@"stores"];
    [Stores syncData:stores];
    
    //update cash drawer
    NSArray * cashDrawers =[dict objectForKey:@"cash_drawer"];
    [CashDrawer syncData:cashDrawers];
    //Update user
    NSDictionary * userInfoDict =[dict objectForKey:@"user_info"];
    [UserInfo syncData:userInfoDict];
}

#pragma mark - LOGIN BUTTON CLICK
- (IBAction)loginButtonClick:(id)sender {

    if(userNameTextfield.text.length == 0){
        //[Utilities alert:@"Alert" withMessage:@"Please insert your username"];
        [Utilities toastFailTitle:@"Alert" withMessage:@"Please insert your username" withView:self.view];
        [userNameTextfield becomeFirstResponder];
        return;
    }
    
    if(passTextField.text.length == 0){
        //[Utilities alert:@"Alert" withMessage:@"Please insert your password"];
        [Utilities toastFailTitle:@"Alert" withMessage:@"Please insert your password" withView:self.view];
        [passTextField becomeFirstResponder];
        return;
    }
    
    [self showIndicatorView];
    
    [self performSelector:@selector(checkLoginMageStore)];

}


-(void)checkLoginMageStore{

    [[APIManager shareInstance] loginWithUsername:userNameTextfield.text Password:passTextField.text Callback:^(BOOL success, id result) {
        
        [self hideIndicatorView];
        
        if (success) {
            
            NSDictionary * data =[result objectForKey:@"data"];
            NSString * session =[NSString stringWithFormat:@"%@",[data objectForKey:@"session"]];
            
            [[Configuration globalConfig] setObject:session forKey:@"session"];
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //insert store , cash drawer in database
                    [self updateUserInfo:data];
                    
                    [self openStoreSetting];
                    
                });
            });
            
        } else {            
            
            if([result isKindOfClass:[NSString class]]){
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:MESSAGE_CONNECTOR_ERROR];
                
            }else if([result isKindOfClass:[NSDictionary class]] && [result objectForKey:@"data"]){
                NSString * message = [NSString stringWithFormat:@"%@",[result objectForKey:@"data"]];
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:message];
            }else{
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:@"Please check your domain"];
            }
            
        }
    }];
}


@end
