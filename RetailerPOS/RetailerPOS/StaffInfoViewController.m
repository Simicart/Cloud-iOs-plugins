//
//  StaffInfoViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/25/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StaffInfoViewController.h"
#import "MSFramework.h"
#import "StaffListViewController.h"
#import "Account.h"
#import "Location.h"
#import "LocationCollection.h"
#import "LocationViewController.h"

@interface StaffInfoViewController ()
@property (nonatomic) BOOL customRole;
@property (strong, nonatomic) NSMutableDictionary *formData;
- (BOOL)toggleSelectRow:(UITableViewCell *)cell;

- (IBAction)changeSwitcher:(id)sender;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)startAnimation;
- (void)stopAnimation;
- (void)saveUserThread;
- (void)deleteUserThread;
@end

@implementation StaffInfoViewController
@synthesize user, userList, listController, currentIndexPath, customRole, formData, animation;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    self.view.frame = CGRectMake(0, 0, 596, 702);
    
    // self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteUser)];
    if (user == nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCreate)];
    }
    if (([Account permissionValue:@"user.update"] && user)
        || ([Account permissionValue:@"user.create"] && user == nil)
    ) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveUser)];
    }
    if (user && [[user objectForKey:@"name"] isKindOfClass:[NSString class]]) {
        self.title = [user objectForKey:@"name"];
    } else if (user == nil) {
        self.title = NSLocalizedString(@"New Staff User", nil);
    }
    if ([user objectForKey:@"user_role"] != nil && [[user objectForKey:@"user_role"] integerValue] == 2) {
        customRole = YES;
    } else {
        customRole = NO;
    }
    // Form Data
    formData = [NSMutableDictionary new];
    if (user) {
        [formData addEntriesFromDictionary:user];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger result = 3;
    if (customRole) {
        result = 9;
    }
    if (user != nil && [Account permissionValue:@"user.delete"]) {
        result++;
    }
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = 4;
    if (section == 0) {
        result = 5;
    } else if (section == 1) {
        result = 2;
    } else if (section == 2) {
        result = 2;
    } else if (section == 3) {
        if (customRole) {
            result = 2;
        } else {
            result = 1;
        }
    } else if (section == 9) {
        result = 1;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellID = @"StaffInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        
        MSTextField *inputText = [[MSTextField alloc] initWithFrame:CGRectMake(160, 2, 390, 42)];
        inputText.textPadding =  UIEdgeInsetsMake(10, 0, 8, 0);
        inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        inputText.delegate = self;
        inputText.tag = 123;
        [cell addSubview:inputText];
        
        [inputText addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingChanged];
        [inputText addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [switcher addTarget:self action:@selector(changeSwitcher:) forControlEvents:UIControlEventValueChanged];
        switcher.tag = 124;
        [cell addSubview:switcher];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor darkTextColor];
    cell.detailTextLabel.text = nil;
    
    MSTextField *inputText = (MSTextField *)[cell viewWithTag:123];
    inputText.hidden = NO;
    [inputText setSecureTextEntry:NO];
    inputText.keyboardType = UIKeyboardTypeDefault;
    
    UISwitch *switcher = (UISwitch *)[cell viewWithTag:124];
    switcher.hidden = YES;
    if (cell.accessoryView != nil) {
        cell.accessoryView = nil;
        [cell addSubview:switcher];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Basic information
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"First Name", nil);
                inputText.placeholder = NSLocalizedString(@"First Name", nil);
                inputText.text = [formData objectForKey:@"first_name"];
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Last Name", nil);
                inputText.placeholder = NSLocalizedString(@"Last Name", nil);
                inputText.text = [formData objectForKey:@"last_name"];
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Email", nil);
                inputText.placeholder = NSLocalizedString(@"Email", nil);
                inputText.text = [formData objectForKey:@"email"];
                inputText.keyboardType = UIKeyboardTypeEmailAddress;
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"Status", nil);
                inputText.hidden = YES;
                switcher.hidden = NO;
                cell.accessoryView = switcher;
                if ([formData objectForKey:@"status"] != nil && [[formData objectForKey:@"status"] boolValue]) {
                    [switcher setOn:YES];
                } else {
                    [switcher setOn:NO];
                }
                break;
            case 4:
                cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.backgroundColor = [UIColor whiteColor];
                cell.textLabel.font = [UIFont systemFontOfSize:18];
                
                cell.textLabel.text = NSLocalizedString(@"Location", nil);
                inputText.hidden = YES;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                Location *location = [[LocationCollection allLocation] getLocationById:[formData objectForKey:@"location_id"]];
                cell.detailTextLabel.text = [location objectForKey:@"name"];
                break;
        }
        return cell;
    }
    
    // Password
    if ([indexPath section] == 1) {
        [inputText setSecureTextEntry:YES];
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Password", nil);
                inputText.text = [formData objectForKey:@"new_password"];
                inputText.placeholder = NSLocalizedString(@"Password", nil);
                break;
            default:
                cell.textLabel.text = NSLocalizedString(@"Confirmation", nil);
                inputText.text = [formData objectForKey:@"confirmation"];
                inputText.placeholder = NSLocalizedString(@"Confirmation", nil);
                break;
        }
        return cell;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    inputText.hidden = YES;
    // Role (Select Role Permission)
    if ([indexPath section] == 2) {
        if ([indexPath row]) {
            cell.textLabel.text = NSLocalizedString(@"Sales staff (configured permissions)", nil);
            if (customRole) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            cell.textLabel.text = NSLocalizedString(@"Admin (full permissions)", nil);
            if (!customRole) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        return cell;
    }
    
    NSDictionary *permission = [formData objectForKey:@"role_permission"];
    if (![permission isKindOfClass:[NSDictionary class]]) {
        permission = [NSDictionary new];
    }
    
    // Delete User
    if (([indexPath section] == 3 && !customRole)
        || [indexPath section] == 9
        ) {
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.text = NSLocalizedString(@"Delete User", nil);
        return cell;
    }
    
    // Customer
    if ([indexPath section] == 3) {
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"Update customers", nil);
                if ([[permission objectForKey:@"customer.update"] integerValue] == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            default:
                cell.textLabel.text = NSLocalizedString(@"Delete customers", nil);
                if ([[permission objectForKey:@"customer.delete"] integerValue] == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
        }
        return cell;
    }
    
    // Order List, Invoice, Refund, Cancel
    if ([indexPath section] > 3 && [indexPath section] < 8) {
        NSInteger value = 0;
        switch ([indexPath section]) {
            case 4:
                value = [[permission objectForKey:@"order.list"] integerValue];
                break;
            case 5:
                value = [[permission objectForKey:@"order.invoice"] integerValue];
                break;
            case 6:
                value = [[permission objectForKey:@"order.refund"] integerValue];
                break;
            default:
                value = [[permission objectForKey:@"order.cancel"] integerValue];
                break;
        }
        value++;
        if (value == 5) {
            value = 0;
        }
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"No permission", nil);
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Created by this user", nil);
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Created by other staff", nil);
                break;
            default:
                cell.textLabel.text = NSLocalizedString(@"All orders", nil);
                break;
        }
        if (value == [indexPath row]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    }
    
    // Staff User
    if ([indexPath section] == 8) {
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"View staff user list", nil);
                if ([[permission objectForKey:@"user.list"] integerValue] == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"Create staff users", nil);
                if ([[permission objectForKey:@"user.create"] integerValue] == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Delete staff users", nil);
                if ([[permission objectForKey:@"user.delete"] integerValue] == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
            default:
                cell.textLabel.text = NSLocalizedString(@"Update staff users", nil);
                if ([[permission objectForKey:@"user.update"] integerValue] == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                break;
        }
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @" ";
    } else if (section == 2) {
        return NSLocalizedString(@"Select User Role", nil);
    } else if (section == 3 && customRole) {
        return NSLocalizedString(@"Manage Customers", nil);
    } else if (section == 4) {
        return NSLocalizedString(@"View Order List", nil);
    } else if (section == 5) {
        return NSLocalizedString(@"Invoice Orders", nil);
    } else if (section == 6) {
        return NSLocalizedString(@"Refund Orders", nil);
    } else if (section == 7) {
        return NSLocalizedString(@"Cancel Orders", nil);
    } else if (section == 8) {
        return NSLocalizedString(@"Manage Staff Users", nil);
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
//    if (section == 2) {
//        return NSLocalizedString(@"Check it for Sales Staff account, otherwise for POS Admin account", nil);
//    }
    return nil;
}

#pragma mark - table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([indexPath section] == 0 && [indexPath row] == 4) {
        // change Location
        LocationViewController *locationViewControl = [[LocationViewController alloc] initWithStyle:UITableViewStyleGrouped];
        locationViewControl.formData = formData;
        locationViewControl.infoViewController = self;
        [self.navigationController pushViewController:locationViewControl animated:YES];
    }
    
    if ([indexPath section] == 2 && (customRole ^ [indexPath row])) {
        if (customRole) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]].accessoryType = UITableViewCellAccessoryNone;
            customRole = NO;
            [formData setValue:@"1" forKey:@"user_role"]; // Admin
            [tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 6)] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]].accessoryType = UITableViewCellAccessoryNone;
            customRole = YES;
            [formData setValue:@"2" forKey:@"user_role"]; // Sales Staff
            [tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 6)] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    
    // Delete user
    if (([indexPath section] == 3 && !customRole)
        || [indexPath section] == 9
        ) {
        UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this user?", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
        [confirm showInView:self.view];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    NSMutableDictionary *permission = [formData objectForKey:@"role_permission"];
    if (permission == nil || ![permission isKindOfClass:[NSDictionary class]]) {
        permission = [NSMutableDictionary new];
    } else if ([[[permission class] description] isEqualToString:@"__NSCFDictionary"]) {
        permission = [[NSMutableDictionary alloc] initWithDictionary:permission];
    }
    // Customer
    if ([indexPath section] == 3) {
        BOOL isSelected = [self toggleSelectRow:cell];
        if ([indexPath row] == 0) {
            [permission setValue:[NSNumber numberWithBool:isSelected] forKey:@"customer.update"];
        } else {
            [permission setValue:[NSNumber numberWithBool:isSelected] forKey:@"customer.delete"];
        }
    }
    
    // Order List, Invoice, Refund, Cancel
    if ([indexPath section] > 3 && [indexPath section] < 8) {
        NSString *key = nil;
        switch ([indexPath section]) {
            case 4:
                key = @"order.list";
                break;
            case 5:
                key = @"order.invoice";
                break;
            case 6:
                key = @"order.refund";
                break;
            default:
                key = @"order.cancel";
                break;
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSInteger value = [[permission objectForKey:key] integerValue];
        value = (value + 1) % 5;
        if (value != [indexPath row]) {
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:value inSection:[indexPath section]]];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            value = [indexPath row];
            if (value == 0) {
                value = 4;
            } else {
                value--;
            }
            [permission setValue:[NSNumber numberWithInteger:value] forKey:key];
        }
    }
    
    // Staff User
    if ([indexPath section] == 8) {
        BOOL isSelected = [self toggleSelectRow:cell];
        if ([indexPath row] == 0) {
            [permission setValue:[NSNumber numberWithBool:isSelected] forKey:@"user.list"];
//            NSArray *indexPaths = @[
//                [NSIndexPath indexPathForRow:1 inSection:8],
//                [NSIndexPath indexPathForRow:2 inSection:8],
//                [NSIndexPath indexPathForRow:3 inSection:8]
//            ];
//            if (isSelected) {
//                [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//            } else {
//                [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
//            }
        } else if ([indexPath row] == 1) {
            [permission setValue:[NSNumber numberWithBool:isSelected] forKey:@"user.create"];
        } else if ([indexPath row] == 2) {
            [permission setValue:[NSNumber numberWithBool:isSelected] forKey:@"user.delete"];
        } else if ([indexPath row] == 3) {
            [permission setValue:[NSNumber numberWithBool:isSelected] forKey:@"user.update"];
        }
    }
    
    [formData setValue:permission forKey:@"role_permission"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)toggleSelectRow:(UITableViewCell *)cell
{
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        return YES;
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    return NO;
}

#pragma mark - change data (text field delegate)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[textField superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSUInteger index = [indexPath section] * 4 + [indexPath row];
    if (index < 5) {
        index++;
        if (index == 3) {
            index++;
        }
        NSUInteger section = index / 4;
        NSUInteger row = index - section * 4;
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
        UIView *nextField = [nextCell viewWithTag:123];
        [nextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[textField superview]];
    NSUInteger index = [indexPath section] * 4 + [indexPath row];
    
    NSString *key = nil;
    switch (index) {
        case 0:
            key = @"first_name";
            break;
        case 1:
            key = @"last_name";
            break;
        case 2:
            key = @"email";
            break;
        case 4:
            key = @"new_password";
            break;
        default:
            key = @"confirmation";
            break;
    }
    if (textField.text) {
        [formData setValue:textField.text forKey:key];
    } else {
        [formData removeObjectForKey:key];
    }
}

- (void)changeSwitcher:(id)sender
{
    BOOL status = [(UISwitch *)sender isOn];
    [formData setValue:[NSNumber numberWithBool:status] forKey:@"status"];
}

#pragma mark - edit user action
- (void)cancelCreate
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startAnimation
{
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        animation.color = [UIColor grayColor];
        animation.frame = self.view.bounds;
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    self.navigationItem.hidesBackButton = YES;
}

- (void)stopAnimation
{
    [animation stopAnimating];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    self.navigationItem.hidesBackButton = NO;
}

- (void)saveUser
{
    // Validate Form
    NSString *firstName = [formData objectForKey:@"first_name"];
    NSString *lastName = [formData objectForKey:@"last_name"];
    NSString *email = [formData objectForKey:@"email"];
    NSString *password = [formData objectForKey:@"new_password"];
    // Validate Input Field
    if ([MSValidator isEmptyString:firstName]
        || [MSValidator isEmptyString:lastName]
        || [MSValidator isEmptyString:email]
        || ([MSValidator isEmptyString:password] && user == nil)
    ) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Please complete all fields before saving!", nil)];
        return;
    }
    // Validate Email
    if (![MSValidator validateEmail:email]) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(INPUT_INVALID_EMAIL_ADRESS, nil)];
        return;
    }
    // Validate Password
    if (![MSValidator isEmptyString:password]) {
        NSString *confirmation = [formData objectForKey:@"confirmation"];
        if (![password isEqualToString:confirmation]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"The confirmation not match with password", nil)];
            return;
        }
        if ([password length] < 7) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Password must be at least 7 characters.", nil)];
            return;
        }
    }
    
    // Start animation and save to server
    [self startAnimation];
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveUserThread) object:nil] start];
}

- (void)saveUserThread
{
    User *newUser = [User new];
    [newUser addData:formData];
    id failt = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"UserSaveAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [newUser removeObjectForKey:@"new_password"];
        [newUser removeObjectForKey:@"confirmation"];
        if (user == nil) {
            // Add New User
            if (userList && userList.loadCollectionFlag) {
                NSUInteger index = [userList getSize];
                [userList.sortedIndex setObject:[NSNumber numberWithInteger:index] atIndexedSubscript:index];
                [newUser setValue:[newUser objectForKey:@"user_id"] forKey:@"id"];
                [userList setValue:newUser forKey:[userList.sortedIndex objectAtIndex:index]];
                if (listController) {
                    // [listController.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:index inSection:0]];
                    [listController.tableView performSelectorOnMainThread:@selector(insertRowsAtIndexPaths:withRowAnimation:) withObject:indexPaths waitUntilDone:NO];
                }
            }
            [self performSelectorOnMainThread:@selector(cancelCreate) withObject:nil waitUntilDone:NO];
        } else {
            // Update existed user
            [user addData:newUser];
            // [listController.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            [listController.tableView performSelectorOnMainThread:@selector(reloadRowsAtIndexPaths:withRowAnimation:) withObject:@[currentIndexPath] waitUntilDone:NO];
            [self.navigationController performSelectorOnMainThread:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
        }
    }];
    [newUser save];
    
    [self stopAnimation];
    [[NSNotificationCenter defaultCenter] removeObserver:failt];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        return;
    }
    [self deleteUser];
}

- (void)deleteUser
{
    [self startAnimation];
    [[[NSThread alloc] initWithTarget:self selector:@selector(deleteUserThread) object:nil] start];
}

- (void)deleteUserThread
{
    id failt = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"UserDeleteAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Delete Row
        [userList removeObjectForKey:[userList.sortedIndex objectAtIndex:[currentIndexPath row]]];
        [userList.sortedIndex removeObjectAtIndex:[currentIndexPath row]];
        [listController.tableView performSelectorOnMainThread:@selector(deleteRowsAtIndexPaths:withRowAnimation:) withObject:@[currentIndexPath] waitUntilDone:YES];
        [self.navigationController performSelectorOnMainThread:@selector(popViewControllerAnimated:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
    }];
    [user deleteUser];
    
    [self stopAnimation];
    [[NSNotificationCenter defaultCenter] removeObserver:failt];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

@end
