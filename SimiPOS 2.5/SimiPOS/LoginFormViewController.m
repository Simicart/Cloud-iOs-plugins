
#import "LoginFormViewController.h"
#import "Reachability.h"
#import "UserStoreSettingVC.h"
#import "MSTextField.h"
#import "UIColor+SimiPOS.h"
#import "MSBlueButton.h"
#import "MSValidator.h"

//Model database
#import "Stores.h"
#import "CashDrawer.h"

//Active key
#import "ActivateKeyViewController.h"
#import "UserInfo.h"
#import "Account.h"
#import "UrlDomainConfig.h"
#import "ShowContentDetail.h"

//#import "PDKeychainBindings.h"

@interface LoginFormViewController ()<ActivateKeyViewControllerDelegate,UIPopoverControllerDelegate,UITextFieldDelegate>
@property (strong, nonatomic) MSTextField *username, *password, *storeUrl;
@property (strong, nonatomic) UILabel * tryDemoLabel;
@property (strong, nonatomic) UIButton *loginBtn, *demoBtn, *activeKeyBtn;
@property (strong, atomic) MSBlueButton * tryDemoBtn;
@property (strong, nonatomic) UIPopoverController * popOverController;
@property (strong, nonatomic) UIActivityIndicatorView * loginBtnAnimation;

@end

@implementation LoginFormViewController{
    UrlDomainConfig * urlDomainConfig;
    ActivateKeyViewController *activeKeyViewController;
}
@synthesize username, password, storeUrl;
@synthesize loginBtn, demoBtn ,activeKeyBtn,loginBtnAnimation;
@synthesize popOverController;
@synthesize tryDemoBtn;
@synthesize tryDemoLabel;

static LoginFormViewController *_sharedInstance = nil;

+(LoginFormViewController*)sharedInstance
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

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    return NO;
}

#pragma mark - Implementation viewcontroller delegate
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController  setNavigationBarHidden:YES];
    //self.view.backgroundColor =[UIColor whiteColor];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self checkActiveKeyStatus];
    
    if(BoolValue(KEY_HIDE_DEMO_BUTTON) == YES){
        if(tryDemoBtn){
            tryDemoBtn.hidden =YES;
            tryDemoLabel.hidden =YES;
        }
    }else{
        if(tryDemoBtn){
            tryDemoBtn.hidden =NO;
            tryDemoLabel.hidden =NO;
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //    PDKeychainBindings *bindings=[PDKeychainBindings sharedKeychainBindings];
    //    [bindings setString:@"0" forKey:KEY_CHECK_USE_TRIAL];
    //    [bindings setString:@"" forKey:KEY_DEVICE_TRIAL_ID];
    
    
    _sharedInstance = self ;
    
    self.username.delegate=self;
    self.password.delegate=self;
    
    // Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
    
    UITapGestureRecognizer *guestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboardInput)];
    [self.view addGestureRecognizer:guestureRecognizer];
    
    // Logo
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo_Magestore.png"]];
    //[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"simipos_logo.png"]];
    
    
    imageView.frame = CGRectMake(0, 0, 263, 100); //CGRectMake(0, 0, 400, 60);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = CGPointMake(WINDOW_WIDTH/2, 200);
    [self.view addSubview:imageView];
    
    // Username and password
    UIImageView *inputBackground = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"btn_segment.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)]];
    inputBackground.frame = CGRectMake(WINDOW_WIDTH/2-200, 264, 400, 89);
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 400, 1)];
    separator.backgroundColor = [UIColor lightBorderColor];
    [inputBackground addSubview:separator];
    [self.view addSubview:inputBackground];
    
    //username = [[MSTextField alloc] initWithFrame:CGRectMake(312, 265, 400, 44)];
    username = [[MSTextField alloc] initWithFrame:CGRectMake(WINDOW_WIDTH/2-200, 265, 400, 44)];
    username.textPadding = UIEdgeInsetsMake(10, 15, 10, 15);
    username.placeholder = NSLocalizedString(@"Username", nil);
    username.keyboardType = UIKeyboardTypeEmailAddress;
    
    username.returnKeyType = UIReturnKeyNext;
    username.clearButtonMode = UITextFieldViewModeWhileEditing;
    username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    username.delegate = self;
    //[username addTarget:self action:@selector(textFieldChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:username];
    
    password = [[MSTextField alloc] initWithFrame:CGRectMake(WINDOW_WIDTH/2-200, 310, 400, 44)];
    password.textPadding = UIEdgeInsetsMake(10, 15, 10, 15);
    password.placeholder = NSLocalizedString(@"Password", nil);
    password.returnKeyType = UIReturnKeyDone;
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.secureTextEntry = YES;
    password.delegate = self;
    //[password addTarget:self action:@selector(textFieldChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:password];
    
    if([Configuration isDev]){
        [self setAccountDefault];
    }
    // Login Button
    loginBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    loginBtn.frame = CGRectMake(WINDOW_WIDTH/2-200, 384, 400, 54);
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [loginBtn setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [self.view addSubview:loginBtn];
    [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    // Show and hide keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:UIKeyboardDidHideNotification object:nil];
    
    loginBtnAnimation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loginBtnAnimation.frame = CGRectMake(0, 0, 54, 54);
    
    loginBtnAnimation.center =CGPointMake(self.view.center.x, (CGRectGetMaxY(loginBtn.frame) - loginBtn.frame.size.height/2));
    
    [self.view addSubview:loginBtnAnimation];
    
    // Check Internet
    if (![[Reachability reachabilityForInternetConnection] isReachable]) {
        [Utilities alert:NSLocalizedString(@"Network Error", nil) withMessage:NSLocalizedString(@"You must connect to a Wi-Fi or cellular data network to access the SimiPOS", nil)];
        // password.text = [[Configuration globalConfig] objectForKey:@"password"];
        // [self textFieldChange];
        return;
    }
    
    
    // Login Button
    activeKeyBtn = [UIButton buttonWithType:UIButtonTypeSystem]; //[MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    activeKeyBtn.frame = CGRectMake(WINDOW_WIDTH/2-200, WINDOW_HEIGHT -54 -20, 400, 54);
    activeKeyBtn.titleLabel.textColor = [UIColor barBackgroundColor];//[UIColor blueColor];
    activeKeyBtn.tintColor =[UIColor barBackgroundColor];
    
    [activeKeyBtn setTitle:NSLocalizedString(@"Activate this device", nil) forState:UIControlStateNormal];
    [self.view addSubview:activeKeyBtn];
    [activeKeyBtn addTarget:self action:@selector(openPopupActiveKeys) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableLogin) name:@"activeSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disableLogin) name:@"activeFail" object:nil];
    
    if(BoolValue(KEY_HIDE_DEMO_BUTTON) == NO){
        [self createTryDemoButton];
    }
    
}

#pragma mark - create try demo button
-(void)createTryDemoButton{
    // Login Button
    
    tryDemoLabel =[[UILabel alloc] initWithFrame:CGRectMake(WINDOW_WIDTH/2, 480-20, 40, 40)];
    tryDemoLabel.text =@"Or";
    tryDemoLabel.textColor =[UIColor grayColor];
    [self.view addSubview:tryDemoLabel];
    
    tryDemoBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    tryDemoBtn.frame = CGRectMake(WINDOW_WIDTH/2-200, 550-40, 400, 54);
    tryDemoBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    [tryDemoBtn setBackgroundColor:[UIColor whiteColor]];
    
    [tryDemoBtn setTitleColor:[UIColor barBackgroundColor] forState:UIControlStateNormal];
    tryDemoBtn.layer.borderColor =[UIColor lightBorderColor].CGColor;
    tryDemoBtn.layer.borderWidth =1.0;
    
    
    [tryDemoBtn setTitle:NSLocalizedString(@"Try Demo", nil) forState:UIControlStateNormal];
    [self.view addSubview:tryDemoBtn];
    [tryDemoBtn addTarget:self action:@selector(loginTryDemo) forControlEvents:UIControlEventTouchUpInside];
}

- (void)disableLogin
{
    [loginBtn setEnabled:NO];
    // loginBtn.hidden = YES;
}
- (void)enableLogin
{
    [loginBtn setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
    [loginBtn setEnabled:YES];
    // loginBtn.hidden = NO;
}

- (void)showKeyboard
{
    //    [UIView animateWithDuration:0.25 animations:^{
    //        self.view.frame = CGRectMake(0, -54, WINDOW_WIDTH, 822);
    //    }];
}

- (void)hideKeyboard
{
    //    [UIView animateWithDuration:0.25 animations:^{
    //        self.view.frame = CGRectMake(0, 0, WINDOW_WIDTH, 768);
    //    }];
}

#pragma mark - Text field delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(popOverController){
        [popOverController dismissPopoverAnimated:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:username]) {
        [password becomeFirstResponder];
        
    }else if([textField isEqual:password]){
        [self login];
        
    }
    
    return YES;
}

#pragma mark - Button Actions
- (void)hideKeyboardInput
{
    [self.view endEditing:YES];
}

- (void)login
{
    if(self.username.text.length == 0){
        [Utilities alert:@"Alert" withMessage:@"Please insert your username"];
        [self.username becomeFirstResponder];
        return;
    }
    
    if(self.password.text.length == 0){
        [Utilities alert:@"Alert" withMessage:@"Please insert your password"];
        [self.password becomeFirstResponder];
        return;
    }
    
    SetBoolValue(NO, KEY_CHECK_USE_TRY_DEMO);
    
    if(popOverController){
        [popOverController dismissPopoverAnimated:NO];
    }
    
    [self hideKeyboardInput];
    
    if(![Configuration isDev])
    {
        urlDomainConfig =[[UrlDomainConfig findAll] firstObject];
        if(urlDomainConfig ==nil){
            [Utilities toastFailTitle:nil withMessage:MESSAGE_ACTIVE_DEVICE withView:self.view];
            [self openPopupActiveKeys];
            return;
        }
    }
    
    [self checkLoginMageStore];
}

-(void)setAccountDefault{
    self.username.text=@"daniel";
    self.password.text=@"db123db";
}

-(void)checkLoginMageStore{
    
    // Start Animation
    [loginBtn setEnabled:NO];
    
    loginBtnAnimation.color =[UIColor whiteColor];
    loginBtnAnimation.center =CGPointMake(self.view.center.x, (CGRectGetMaxY(loginBtn.frame) - loginBtn.frame.size.height/2));
    [self.loginBtnAnimation startAnimating];
    [loginBtn setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
    
    [[APIManager shareInstance] loginWithUsername:username.text Password:password.text Callback:^(BOOL success, id result) {
        
        [self.loginBtnAnimation stopAnimating];
        [loginBtn setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
        
        [loginBtn setEnabled:YES];
        
        if (success) {
            
            //  DLog(@"result:%@",result);
            
            NSDictionary * data =[result objectForKey:@"data"];
            NSString * session =[NSString stringWithFormat:@"%@",[data objectForKey:@"session"]];
            
            [[Configuration globalConfig] setObject:session forKey:@"session"];
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //insert store , cash drawer in database
                    [self updateUserInfo:data];
                    
                    [self.loginBtnAnimation stopAnimating];
                    
                    [self openStoreSetting];
                    
                });
            });
            
        } else {
            
            [self.loginBtnAnimation stopAnimating];
            
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

#pragma mark - insert store , cash drawer in database
-(void)updateUserInfo:(NSDictionary *)dict{
    if(!dict){
        return;
    }
    
    //update stores
    NSArray * stores =[dict objectForKey:@"stores"];
    if(stores && stores.count >0){
        
        //remove database;
        [Stores truncateAll];
        
        for(NSDictionary * item in stores){
            
            if(item && [item isKindOfClass:[NSDictionary class]]){
                NSString * store_id =[NSString stringWithFormat:@"%@",[item objectForKey:@"id"]];
                NSString * store_name =[NSString stringWithFormat:@"%@",[item objectForKey:@"name"]];
                NSString * enable_cash_drawer =[NSString stringWithFormat:@"%@",[item objectForKey:@"enable_cash_drawer"]];
                
                Stores * store =[Stores MR_createEntity];
                
                store.store_id =store_id;
                store.store_name =store_name;
                store.enable_cash_drawer =enable_cash_drawer;
            }
        }
        
        [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    }
    
    
    //update cash drawer
    NSArray * cashDrawers =[dict objectForKey:@"cash_drawer"];
    if(cashDrawers && cashDrawers.count >0){
        
        //remove database;
        [CashDrawer truncateAll];
        
        for(NSDictionary * item in cashDrawers){
            
            if(item && [item isKindOfClass:[NSDictionary class]]){
                NSString * cash_drawer_id =[NSString stringWithFormat:@"%@",[item objectForKey:@"id"]];
                NSString * cash_drawer_name =[NSString stringWithFormat:@"%@",[item objectForKey:@"name"]];
                NSString * saved_automatic =[NSString stringWithFormat:@"%@",[item objectForKey:@"saved_automatic"]];
                
                CashDrawer * cashDrawer =[CashDrawer MR_createEntity];
                
                cashDrawer.cash_drawer_id =cash_drawer_id;
                cashDrawer.cash_drawer_name =cash_drawer_name;
                cashDrawer.save_automatic =saved_automatic;
            }
        }
        
        [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    }
    
    //Update user
    NSDictionary * userInfoDict =[dict objectForKey:@"user_info"];
    if(userInfoDict){
        
        [UserInfo truncateAll];
        
        UserInfo * userInfo =[UserInfo MR_createEntity];
        userInfo.username =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"username"]];
        userInfo.display_name =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"display_name"]];
        userInfo.email_address =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"email"]];
        userInfo.session =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"sessid"]];
        userInfo.user_id =[NSString stringWithFormat:@"%@",[userInfoDict objectForKey:@"user_id"]];
        
        [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
    }
}

#pragma mark - Setting Store & Cash Drawer
- (void)openStoreSetting
{
    UserStoreSettingVC *storeSetting = [[UserStoreSettingVC alloc] initWithNibName:@"UserStoreSettingVC" bundle:nil];
    [self.navigationController pushViewController:storeSetting animated:YES];
}

-(void)openPopupActiveKeys{
    
    ActivateKeyViewController * activateKeyVC =[[ActivateKeyViewController alloc] initWithNibName:@"ActivateKeyViewController" bundle:nil] ;
    
    popOverController =[[UIPopoverController alloc] initWithContentViewController:activateKeyVC];
    [popOverController setPopoverContentSize:activateKeyVC.view.frame.size];
    popOverController.passthroughViews =[[NSArray alloc] initWithObjects:self.loginBtn,self.username,self.password,nil];
    
    activateKeyVC.popOverController =popOverController;
    
    [popOverController presentPopoverFromRect:activeKeyBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    
}



#pragma mark - ActivateKeyViewControllerDelegate
-(void)activeKeyButtonClickDelegate{
    
    username.placeholder = NSLocalizedString(@"Email", nil);
    username.placeholder = NSLocalizedString(@"Email", nil);
}
-(void)activeKeySelectItem:(NSString *)url{
    DLog(@"url:%@",url);
}

-(void)openShowFormActivekey: (NSString*) apiKey{
    
    ActivateKeyViewController * activateKeyVC =[[ActivateKeyViewController alloc] initWithNibName:@"ActivateKeyViewController" bundle:nil] ;
    
    popOverController =[[UIPopoverController alloc] initWithContentViewController:activateKeyVC];
    [popOverController setPopoverContentSize:activateKeyVC.view.frame.size];
    
    activateKeyVC.popOverController =popOverController;
    
    [popOverController presentPopoverFromRect:activeKeyBtn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    [activateKeyVC.btnActivateNewKey sendActionsForControlEvents:UIControlEventTouchUpInside];
    activateKeyVC.txtActivateKey.text = apiKey;
    
}

-(void)checkActiveKeyStatus{
    urlDomainConfig =[[UrlDomainConfig findAll] firstObject];
    
    if(urlDomainConfig != nil && urlDomainConfig.api_key){
        [loginBtn setEnabled:NO];
        
        loginBtnAnimation.color =[UIColor barBackgroundColor];
        loginBtnAnimation.center =CGPointMake(self.view.center.x, (CGRectGetMaxY(tryDemoBtn.frame) - tryDemoBtn.frame.size.height/2)+70);
        [loginBtnAnimation startAnimating];
        
        [[APIManager shareInstance] getStoreUrl:urlDomainConfig.api_key Callback:^(BOOL success, id result) {
            
            [loginBtnAnimation stopAnimating];
            [loginBtn setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
            
            if(success){
                if([result isKindOfClass:[NSDictionary class]]){
                    NSDictionary * dict =[result objectForKey:@"data"];
                    {
                        
                        if(dict && [dict objectForKey:@"main_url"]){
                            [loginBtn setEnabled:YES];
                            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
                            dispatch_async(backgroundQueue, ^{
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    urlDomainConfig.domain_live =[NSString stringWithFormat:@"%@",[dict objectForKey:@"main_url"]];
                                    urlDomainConfig.domain_dev =[NSString stringWithFormat:@"%@",[dict objectForKey:@"dev_url"]];
                                    urlDomainConfig.domain_active =@"domain_live";
                                    urlDomainConfig.main_api_url =[NSString stringWithFormat:@"%@",[dict objectForKey:@"main_api_url"]];
                                    urlDomainConfig.dev_api_url =[NSString stringWithFormat:@"%@",[dict objectForKey:@"dev_api_url"]];
                                    SAVE_DATABASE;
                                    
                                    [[Configuration globalConfig] readDomainFromActivateKey];
                                    [activeKeyViewController.tblView reloadData];
                                    
                                    //[self openPopupActiveKeys];
                                    [self enableLogin];
                                });
                            });
                            
                        }
                    }
                }else{
                    [Utilities toastSuccessTitle:nil withMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"data"]] withView:self.view];
                    [self disableLogin];
                    [self openShowFormActivekey:urlDomainConfig.api_key];
                }
                
            }else{
                [Utilities toastSuccessTitle:nil withMessage:[NSString stringWithFormat:@"%@",[result objectForKey:@"data"]] withView:self.view];
                [self disableLogin];
                [self openShowFormActivekey:urlDomainConfig.api_key];
            }
            
        }];
    }
}


#pragma mark - Login try demo
-(void)loginTryDemo{
    
    tryDemoBtn.enabled =NO;
    
    loginBtnAnimation.color =[UIColor barBackgroundColor];
    loginBtnAnimation.center =CGPointMake(self.view.center.x, (CGRectGetMaxY(tryDemoBtn.frame) - tryDemoBtn.frame.size.height/2)+70);
    [loginBtnAnimation startAnimating];
    
    [[APIManager shareInstance] getDemoDataCallback:^(BOOL success, id result) {
        [self.loginBtnAnimation stopAnimating];
        
        tryDemoBtn.enabled =YES;
        
        if (success) {
            
            // DLog(@"result:%@",result);
            
            NSDictionary * data =[result objectForKey:@"data"];
            
            if(data && [data isKindOfClass:[NSDictionary class]]){
                
                NSString * demo_url =[NSString stringWithFormat:@"%@",[data objectForKey:@"demo_url"]];
                [[Configuration globalConfig] setObject:demo_url forKey:API_URL_NAME];
                
                NSString * demo_user =[NSString stringWithFormat:@"%@",[data objectForKey:@"demo_user"]];
                NSString * demo_pass =[NSString stringWithFormat:@"%@",[data objectForKey:@"demo_pass"]];
                
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
    
    tryDemoBtn.enabled =NO;
    
    loginBtnAnimation.color =[UIColor barBackgroundColor];
    loginBtnAnimation.center =CGPointMake(self.view.center.x, (CGRectGetMaxY(tryDemoBtn.frame) - tryDemoBtn.frame.size.height/2)+70);
    [loginBtnAnimation startAnimating];
    
    [[APIManager shareInstance] loginWithUsername:userDemo Password:passwordDemo Callback:^(BOOL success, id result) {
        
        [self.loginBtnAnimation stopAnimating];
        tryDemoBtn.enabled =YES;
        
        if (success) {
            
            //  DLog(@"result:%@",result);
            
            NSDictionary * data =[result objectForKey:@"data"];
            NSString * session =[NSString stringWithFormat:@"%@",[data objectForKey:@"session"]];
            
            [[Configuration globalConfig] setObject:session forKey:@"session"];
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("marcus.queue", 0);
            dispatch_async(backgroundQueue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //insert store , cash drawer in database
                    [self updateUserInfo:data];
                    
                    [self.loginBtnAnimation stopAnimating];
                    
                    [self openStoreSetting];
                    
                });
            });
            
        } else {
            
            [self.loginBtnAnimation stopAnimating];
            
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

@end
