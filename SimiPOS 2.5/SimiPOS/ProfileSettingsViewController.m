//
//  ProfileSettingsViewController.m
//
//  Created by Nguyen Duc Chien on 11/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import "ProfileSettingsViewController.h"
#import "MSFramework.h"
//#import "Account.h"
#import "UserInfo.h"

@interface ProfileSettingsViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)saveAccountInformationThread;
@end

@implementation ProfileSettingsViewController
{
    UserInfo * userInfo;
    NSString *displayName;
    NSString *email;
    NSString *oldPassword;
    NSString *newPassword;
    
}
@synthesize animation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    // Title and button
    self.title = NSLocalizedString(@"My Account", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveAccountInformation)];
    
    userInfo =[UserInfo MR_findFirst];
    
}

- (void)saveAccountInformation
{
    
    if(BoolValue(KEY_CHECK_USE_TRY_DEMO)){
        
        [Utilities alert:@"Try demo account" withMessage:@"You do not have access"];
        return;
    }
    
    displayName = [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] accessoryView] text];
    email = [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] accessoryView] text];
    
    // Validate Input Field
    if ([MSValidator isEmptyString:displayName]  || [MSValidator isEmptyString:email]) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Please complete all fields before saving!", nil)];
        return;
    }
    // Validate Email
    if (![MSValidator validateEmail:email]) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(INPUT_INVALID_EMAIL_ADRESS, nil)];
        [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] accessoryView] becomeFirstResponder];
        return;
    }
    
    //Old password
     oldPassword = [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView] text];
    
    if(oldPassword.length == 0){
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"You must input old password", nil)];
        [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView] becomeFirstResponder];
        return;
    }
    
    if ([oldPassword length] < 7) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Password must be at least 7 characters.", nil)];
         [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView] becomeFirstResponder];
        return;
    }
        
    // Validate New Password
    newPassword = [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] accessoryView] text];
    NSString *confirmation = [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] accessoryView] text];
    
    if(newPassword.length == 0){
        newPassword =@"";
        
        if(confirmation.length > 0){
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Please input new password", nil)];
            [(UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] accessoryView] becomeFirstResponder];
            return;
        }
        
    }
    else if (![MSValidator isEmptyString:newPassword]) {

        if (![newPassword isEqualToString:confirmation]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"The new password and the confirmation password do not match.", nil)];
            return;
        }
        if ([newPassword length] < 7) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Password must be at least 7 characters.", nil)];
            return;
        }
    }
    
    // Save Account Information
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height + 80);
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveAccountInformationThread) object:nil] start];
}

-(void)clearPasswordInfomation{
    
    ((UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView]).text =@"";
    ((UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] accessoryView]).text =@"";
    ((UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] accessoryView]).text =@"";

}

-(void)updateUserInfo{
    userInfo.display_name =displayName;
    userInfo.email_address =email;
    [[NSManagedObjectContext defaultContext] saveToPersistentStoreAndWait];
}

- (void)saveAccountInformationThread
{
    
    [[APIManager shareInstance] changeProfleUserId:userInfo.user_id Name:displayName Email:email OldPassword:oldPassword NewPassword:newPassword Callback:^(BOOL success, id result) {
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{

                [animation stopAnimating];
                
               // DLog(@"%@",result);
                
                if(success){
                    
                    [self.view endEditing:YES];
                    
                    [self updateUserInfo];
                    
                    [self clearPasswordInfomation];
                    
                    [Utilities alert:NSLocalizedString(@"Message", nil) withMessage:NSLocalizedString(@"your account save successful", nil)];
                    
                }else{
                    
                    id message =[result objectForKey:@"data"];
                    if(message && [message isKindOfClass:[NSString class]]){

                        [Utilities alert:@"Error" withMessage:message];
                        
                    }else{
                      [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Submit have error", nil)];
                    }
                }
                
                
            });
        });
        
    }];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
}

#pragma mark - Set as root controller
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES];
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingInputCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        MSTextField *inputText = [[MSTextField alloc] initWithFrame:CGRectMake(160, 2, 390, 52)];
        inputText.textPadding =  UIEdgeInsetsMake(15, 0, 13, 0);
        inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputText.delegate = self;
        cell.accessoryView = inputText;
    }
    
    MSTextField *inputText = (MSTextField *)cell.accessoryView;
    inputText.keyboardType = UIKeyboardTypeDefault;
    inputText.returnKeyType =UIReturnKeyNext;
    inputText.autocapitalizationType = UITextAutocapitalizationTypeWords;
    inputText.autocorrectionType = UITextAutocorrectionTypeDefault;
    if ([indexPath section] == 1) {
        inputText.secureTextEntry = YES;
       
        if ([indexPath row] == 0) {
            cell.textLabel.text = NSLocalizedString(@"Old Password", nil);
            inputText.placeholder = NSLocalizedString(@"Old Password", nil);
        }
        
        else if ([indexPath row] == 1) {
            cell.textLabel.text = NSLocalizedString(@"New Password", nil);
            inputText.placeholder = NSLocalizedString(@"New Password", nil);
            
        } else {
            cell.textLabel.text = NSLocalizedString(@"Confirmation", nil);
            inputText.placeholder = NSLocalizedString(@"Retype New Password", nil);
            
            inputText.returnKeyType =UIReturnKeyDone;
        }
        return cell;
    }
    inputText.secureTextEntry = NO;
    
    switch ([indexPath row]) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"Display Name", nil);
            inputText.placeholder = NSLocalizedString(@"Display Name", nil);
            inputText.text = userInfo.display_name;
            break;

        default:
            cell.textLabel.text = NSLocalizedString(@"Email Address", nil);
            inputText.placeholder = NSLocalizedString(@"Email Address", nil);
            inputText.text = userInfo.email_address;
            inputText.autocapitalizationType = UITextAutocapitalizationTypeNone;
            inputText.autocorrectionType = UITextAutocorrectionTypeNo;
            inputText.keyboardType = UIKeyboardTypeEmailAddress;
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Account Information", nil);
    }
    return NSLocalizedString(@"Change Password", nil);
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSUInteger index = [indexPath section] * 3 + [indexPath row];
    if (index < 4) {
        index++;
        NSUInteger section = index / 3;
        NSUInteger row = index - section * 3;
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        [nextCell.accessoryView becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
