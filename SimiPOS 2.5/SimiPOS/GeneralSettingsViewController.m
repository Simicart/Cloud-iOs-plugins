//
//  GeneralSettingsViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/31/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "GeneralSettingsViewController.h"
#import "Configuration.h"
#import "MSTextField.h"
#import "AppDelegate.h"

@interface GeneralSettingsViewController ()
@property (strong, nonatomic) NSArray *autoLocks;

@property (strong, nonatomic) MSNumberPad *keyboard;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) MSTextField *pin ;
@end

@implementation GeneralSettingsViewController
{
    bool isZero;
}
@synthesize autoLocks;
@synthesize keyboard, popover;
@synthesize pin;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.autoLocks = @[
        NSLocalizedString(@"2 Minutes", nil),
        NSLocalizedString(@"5 Minutes", nil),
        NSLocalizedString(@"10 Minutes", nil),
        NSLocalizedString(@"15 Minutes", nil),
        NSLocalizedString(@"Never", nil),
    ];
    
    self.title = NSLocalizedString(@"General", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
      if(BoolValue(KEY_CHECK_USE_TRY_DEMO)){
          return 2;
      }
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section) {
        return 1;
    }
    return [autoLocks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = NSLocalizedString(@"Hide Demo Button", nil);
        UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [switcher setOnTintColor:[UIColor barBackgroundColor]];        
        [switcher addTarget:self action:@selector(changeHideDemoValue:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switcher;
        [switcher setOn:BoolValue(KEY_HIDE_DEMO_BUTTON)];
        return cell;
    }
    if ([indexPath section]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        
        pin = [[MSTextField alloc] initWithFrame:CGRectMake(45, 2, 506, 52)];
        pin.textPadding = UIEdgeInsetsMake(14, 0, 14, 0);
        pin.font = [UIFont boldSystemFontOfSize:20];
        pin.secureTextEntry = YES;
        pin.text =  [[NSUserDefaults standardUserDefaults] objectForKey:KEY_GENERAL_PIN];  //[[Configuration globalConfig] objectForKey:@"general/pin"];
        if (pin.text == nil || [pin.text isEqualToString:@""]) {
            pin.text = @"0000";
        }
        pin.delegate = self;
        
        [cell addSubview:pin];
        return cell;
    }
    static NSString *CellIdentifier = @"SettingsSelectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [self.autoLocks objectAtIndex:[indexPath row]];
    
    
    int timeOutIndex =(int)[[[NSUserDefaults standardUserDefaults] objectForKey:KEY_GENERAL_TIMEOUT] integerValue];
    
    
    if (timeOutIndex == [indexPath row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Auto-Lock Screen", nil);
    }
    if (section == 2) {
        return nil;
    }
    return NSLocalizedString(@"PIN", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return NSLocalizedString(@"Hide Try Demo button on login screen", nil);
    }
    if (section) {
        // Description for PIN
        return NSLocalizedString(@"Used to access POS system from the locked screen.\nThe default PIN is 0000.", nil);
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int timeOutIndex =(int)[[[NSUserDefaults standardUserDefaults] objectForKey:KEY_GENERAL_TIMEOUT] integerValue];
    
    if ([indexPath section] == 0 && timeOutIndex != [indexPath row]) {
       
        // deselect old row
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:timeOutIndex inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        //save
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:[indexPath row]] forKey:KEY_GENERAL_TIMEOUT];
        
        // select new row
        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [[AppDelegate sharedInstance] showLockScreenTimer];
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - keyboard
- (BOOL)numberPad:(MSNumberPad *)numberPad willChangeValue:(NSInteger)value
{
    
    if(value == 11){
        if(numberPad.textField.text.length >1)
        {
            isZero =false;
            
        }else{
            isZero =true;
        }
    }
    
    return YES;
}

-(NSString *)numberPadFormatOutput:(MSNumberPad *)numberPad{
    
    
    if(isZero){
         isZero =false;
        return @"";
        
    }else{
        return [NSString stringWithFormat:@"%.0Lf", numberPad.currentValue];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (keyboard == nil) {
        keyboard = [MSNumberPad keyboard];
        [keyboard resetConfig];
        keyboard.delegate = self;
        keyboard.maxInput = 4;
        [keyboard showOn:self atFrame:CGRectMake(0, 0, 288, 241)];
        [keyboard willMoveToParentViewController:nil];
        [keyboard.view removeFromSuperview];
        [keyboard removeFromParentViewController];
    }
    keyboard.textField = textField;
    if (popover == nil) {
        popover = [[UIPopoverController alloc] initWithContentViewController:keyboard];
        popover.popoverContentSize = CGSizeMake(288, 241);
    }
    [popover presentPopoverFromRect:CGRectMake(0, 25, 75, 2) inView:textField permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    return NO;
}

#pragma mark - number pad delegate
- (BOOL)numberPadShouldDone:(MSNumberPad *)numberPad
{
    NSString *text = numberPad.textField.text;
    if ([text length] == 4) {
        [[NSUserDefaults standardUserDefaults] setObject:text forKey:KEY_GENERAL_PIN];
    }
    // Dismiss popover
    [popover dismissPopoverAnimated:NO];
    return NO;
}

- (void)changeHideDemoValue:(id)sender
{
    SetBoolValue([(UISwitch *)sender isOn], KEY_HIDE_DEMO_BUTTON);
}

@end
