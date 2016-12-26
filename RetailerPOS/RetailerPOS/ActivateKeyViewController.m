//
//  ActivateKeyViewController.m
//  RetailerPOS
//
//  Created by mac on 3/11/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ActivateKeyViewController.h"
#import "Configuration.h"
#import "UrlDomainConfig.h"

#import "Configuration.h"
//#import "PDKeychainBindings.h"

#define kWidthViewInput 400
#define kWidthViewDomain 650

@interface ActivateKeyViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *groupInputActiveKey;
@property (strong, nonatomic) UIActivityIndicatorView * animation;

@end

@implementation ActivateKeyViewController{
    BOOL isActivateNewKey;
    UrlDomainConfig * urlConfigItems;
}
@synthesize animation;

-(void)hideRegisterTrialFormAction{
    self.registerTrialForm.hidden = YES;
    self.groupInputActiveKey.hidden = NO;
    self.tblView.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer * hideRegisterTrialForm =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideRegisterTrialFormAction)];
    hideRegisterTrialForm.numberOfTapsRequired=1;
    [self.btnRegisterBack addGestureRecognizer:hideRegisterTrialForm];
    
    self.btnRegisterBack.layer.cornerRadius = 5.0;
    self.btnSubmitRegister.layer.cornerRadius = 5.0;
    
    self.registerTrialEmail.placeholder = @"email@example.com";
    self.registerTrialDomain.placeholder = @"http://yourdomain.com";
    
    self.btnActivateNewKey.backgroundColor = [UIColor barBackgroundColor];
    self.txtActivateKey.delegate=self;
    self.groupInputActiveKey.hidden=YES;
    self.btnClear.hidden=YES;
    urlConfigItems =[[UrlDomainConfig MR_findAll] firstObject];
    
    if(!urlConfigItems){
        [self  setActivateKeyInputStyle];
    }
    
    self.registerTrialForm.hidden = YES;
    
    animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    animation.frame = CGRectMake(0, 0, 54, 54);
    animation.center = CGPointMake(self.view.center.x, CGRectGetMaxY(self.registerTrialForm.frame) - 30);
    
    [self.view addSubview:animation];

    self.btnSubmitRegister.backgroundColor = [UIColor barBackgroundColor];
    self.btnRegisterBack.backgroundColor = [UIColor barBackgroundColor];

    /*
     PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
     bool  isUsedTrial =[[bindings stringForKey:KEY_CHECK_USE_TRIAL] boolValue];
     
     if(isUsedTrial){
     self.btnRegisterTrial.hidden = YES;
     }else{
     self.btnRegisterTrial.hidden = NO;
     }
     */
}

#pragma mark - TableDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Please choice your domain ?";
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdentify =@"activateCell";
    
    UITableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:cellIdentify];
    
    if(!cell){
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:cellIdentify];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.lineBreakMode =NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines=0;
    
    //live
    if(indexPath.row == 0){
        
        if(urlConfigItems){
            cell.textLabel.text =urlConfigItems.domain_live;
        }else{
            cell.textLabel.text=@"";
        }
        
        cell.detailTextLabel.text =@"Live site Domain";
        
        if([urlConfigItems.domain_active isEqualToString:@"domain_live"]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
        //demo
    }else{
        if(urlConfigItems){
            cell.textLabel.text =urlConfigItems.domain_dev;
        }else{
            cell.textLabel.text=@"";
        }
        cell.detailTextLabel.text =@"Dev site Domain";
        
        if([urlConfigItems.domain_active isEqualToString:@"domain_dev"]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.row==0){
        urlConfigItems.domain_active =@"domain_live";
    }else{
        urlConfigItems.domain_active =@"domain_dev";
    }

     [[NSManagedObjectContext MR_defaultContext]saveToPersistentStoreAndWait];
    [[Configuration globalConfig] readDomainFromActivateKey];
    
    if(self.popOverController){
      [self.popOverController dismissPopoverAnimated:NO];
    }
   
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(activeKeyButtonClickDelegate)]){
        [self.delegate activeKeyButtonClickDelegate];
    }
}


#pragma mark - Hide / show groupView
-(void)setActivateKeyInputStyle{
    [self.btnActivateNewKey setTitle:@"Use this key" forState:UIControlStateNormal];
    self.groupInputActiveKey.hidden=NO;

    if(self.txtActivateKey.text.length==0){
        self.btnClear.hidden =YES;
    }else{
        self.btnClear.hidden =NO;
    }
    
    self.tblView.hidden =YES;
    isActivateNewKey =YES;
}

-(void)setActivateKeyShowInfo{
    [self.btnActivateNewKey setEnabled:NO ];
    [self.btnActivateNewKey setTitle:@"Submit API key" forState:UIControlStateNormal];
    self.groupInputActiveKey.hidden=YES;
    self.btnClear.hidden=YES;
    self.tblView.hidden =NO;
    isActivateNewKey =NO;
}

- (IBAction)activateNewKeyButtonClick:(id)sender {

    [self.view endEditing:YES];
    
    if(!isActivateNewKey){
        [self setActivateKeyInputStyle];
        
    }else{
        
        if(self.txtActivateKey.text.length==0){
            [self.txtActivateKey showErrorIconForMsg:@"Key is not empty"];
            
            return;
        }
        
        [[APIManager shareInstance] getStoreUrl:self.txtActivateKey.text Callback:^(BOOL success, id result) {
            DLog(@"result:%@",result);
            
          
            
            if(success){
                if([result isKindOfClass:[NSDictionary class]]){
                    NSDictionary * dict =[result objectForKey:@"data"];
                    {
                        if(dict && [dict objectForKey:@"main_url"]){
                            
                            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
                            dispatch_async(backgroundQueue, ^{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
//                                    NSString * keyType =[dict objectForKey:@"key_type"];
//                                    
//                                    if(keyType && [keyType.lowercaseString isEqualToString:@"demo"]){
//                                        PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
//                                        [bindings setString:@"1" forKey:KEY_CHECK_USE_TRIAL];
//                                    }

                                    [UrlDomainConfig truncateAll];
                                    urlConfigItems =[UrlDomainConfig MR_createEntity];
                                    urlConfigItems.api_key = self.txtActivateKey.text;
                                    urlConfigItems.domain_live =[NSString stringWithFormat:@"%@",[dict objectForKey:@"main_url"]];
                                    urlConfigItems.domain_dev =[NSString stringWithFormat:@"%@",[dict objectForKey:@"dev_url"]];
                                    urlConfigItems.domain_active =@"domain_live";
                                    urlConfigItems.main_api_url =[NSString stringWithFormat:@"%@",[dict objectForKey:@"main_api_url"]];
                                    urlConfigItems.dev_api_url =[NSString stringWithFormat:@"%@",[dict objectForKey:@"dev_api_url"]];
                                    
                                    [[NSManagedObjectContext MR_defaultContext]saveToPersistentStoreAndWait];
                                    
                                    [[Configuration globalConfig] readDomainFromActivateKey];
                                    
                                    [Utilities toastSuccessTitle:nil withMessage:MESSAGE_ACTIVATE_KEY_SUCCESS withView:self.view];
                                    
                                    [self.tblView reloadData];
                                    [self setActivateKeyShowInfo];
                                    [[NSNotificationCenter defaultCenter]postNotificationName:@"activeSuccess" object:nil];
                                });
                            });
                            
                        }
                    }
                }else{
                    [Utilities toastSuccessTitle:nil withMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"data"]] withView:self.view];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"activeFail" object:nil];
                }
            }else{
                 [Utilities toastSuccessTitle:nil withMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"data"]] withView:self.view];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"activeFail" object:nil];
            }
            
        }];
    }
    
//    if(self.delegate){
//        [self.delegate activeKeyButtonClickDelegate];
//    }
}

-(void)delayDismissPopUp{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - text field delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if([string isEqualToString:@""] && textField.text.length==1){
        self.btnClear.hidden =YES;
    }else{
        self.btnClear.hidden =NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    //[self checkValueInput];
    
    if(textField.text.length==0){
        self.btnClear.hidden =YES;
    }else{
        self.btnClear.hidden =NO;
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    if(self.txtActivateKey.text.length==0){
        [self.txtActivateKey showErrorIconForMsg:@"Key is not empty"];
    }
    
    if(textField.text.length==0){
        self.btnClear.hidden =YES;
    }else{
        self.btnClear.hidden =NO;
    }
    
    return YES;
}


- (IBAction)clearButtonClick:(id)sender {
    self.txtActivateKey.text =@"";
}

- (IBAction)showRegisterTrialForm:(id)sender {
    self.registerTrialForm.hidden = NO;
    self.groupInputActiveKey.hidden=YES;
    self.tblView.hidden =YES;
}

- (IBAction)submitRegister:(id)sender {
    [animation startAnimating];
    [[APIManager shareInstance] requestTrial:self.registerTrialEmail.text Domain:self.registerTrialDomain.text Callback:^(BOOL success, id result) {
        if(success){
            if([result isKindOfClass:[NSDictionary class]]){
                NSDictionary * dict =[result objectForKey:@"data"];
                {
                    /*
                    if(dict && [dict objectForKey:@"trial_id"]){
                        PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
                        [bindings setObject:[dict objectForKey:@"trial_id"] forKey:KEY_DEVICE_TRIAL_ID];
                        
                    }
                     */
                    
                    if(dict && [dict objectForKey:@"message"]){
                        [Utilities toastSuccessTitle:nil withMessage:[NSString stringWithFormat:@"%@",[dict objectForKey:@"message"]] withView:self.view];
                    }
                }
                
            }else{
                [Utilities toastSuccessTitle:nil withMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"data"]] withView:self.view];
            }
        }else{
            [Utilities toastSuccessTitle:nil withMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"data"]] withView:self.view];            
        }
        [animation stopAnimating];
    }];
}
@end
