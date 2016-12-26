//
//  DetailProductOptionsMaster.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/16/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "DetailProductOptionsMaster.h"
#import "DetailProductOptionsDetail.h"
#import "MSFramework.h"

#define CELL_TEXT_LABEL_TAG     1
#define CELL_TEXT_FIELD_TAG     2

@interface DetailProductOptionsMaster ()
@property (strong, nonatomic) UIPopoverController *popover;
@end

@implementation DetailProductOptionsMaster
@synthesize popover;

- (void)refreshMasterOption:(NSDictionary *)option
{
    if (self.view.hidden) {
        return;
    }
    [self.tableView reloadData];
}

- (void)moveToNextOption
{
    return;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailProductOptionsMasterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = CELL_TEXT_LABEL_TAG;
        label.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:label];
        
        MSTextField *textField = [[MSTextField alloc] init];
        textField.textPadding = UIEdgeInsetsMake(12, 0, 0, 0);
        textField.tag = CELL_TEXT_FIELD_TAG;
        textField.clearsOnBeginEditing = NO;
        // textField.textAlignment = NSTextAlignmentRight;
        textField.textColor = [UIColor darkGrayColor];
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        [textField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingChanged];
        [textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        [cell.contentView addSubview:textField];
    }
    NSDictionary *option = [self.masterOptions objectAtIndex:[indexPath row]];
    
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:CELL_TEXT_LABEL_TAG];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:CELL_TEXT_FIELD_TAG];
    
    if ([[option objectForKey:@"group"] isEqualToString:@"text"]) {
        // Text Field Input - show custom and clear system
        label.hidden = NO;
        textField.hidden = NO;
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        
        label.frame = CGRectMake(10, 0, 220, 43);
        textField.frame = CGRectMake(240, 0, self.tableWidth - 245, 43);
        label.text = [option objectForKey:@"title"];
        textField.placeholder = [option objectForKey:@"title"];
        
        if ([[option objectForKey:@"required"] boolValue]
            && ![self selectedValues:option]
            ) {
            label.textColor = [UIColor redColor];
        } else {
            label.textColor = [UIColor blackColor];
        }
        textField.text = [self selectedValues:option];
        if ([[option objectForKey:@"name"] rangeOfString:@"super_group" options:NSCaseInsensitiveSearch].location == NSNotFound) {
            [textField setKeyboardType:UIKeyboardTypeDefault];
        } else {
            [textField setKeyboardType:UIKeyboardTypeNumberPad];
            textField.placeholder = NSLocalizedString(@"Qty", nil);
        }
    } else {
        // Clear custom view
        label.hidden = YES;
        textField.hidden = YES;
        
        cell.textLabel.text = [option objectForKey:@"title"];
        
        if ([[option objectForKey:@"required"] boolValue]
            && ![self selectedValues:option]
            ) {
            cell.detailTextLabel.text = NSLocalizedString(@"Required", nil);
            cell.detailTextLabel.textColor = [UIColor redColor];
        } else {
            cell.detailTextLabel.text = [self selectedValues:option];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    // Show Detail Options
    if (popover == nil) {
        popover = [[UIPopoverController alloc] initWithContentViewController:self.detailControl];
        ((DetailProductOptionsDetail *)self.detailControl).popoverController = popover;
    }
    
    NSIndexPath *showOnIndexPath = indexPath;
    for (NSUInteger i = 0; i < [indexPath row]; i++) {
        NSDictionary *cOption = [self.masterOptions objectAtIndex:i];
        if (![[cOption objectForKey:@"config"] boolValue]) {
            continue;
        }
        NSMutableDictionary *selectedOptions = [(ProductOptions *)self.parentViewController productOptions];
        id selectedOption = [selectedOptions objectForKey:[cOption objectForKey:@"name"]];
        if (selectedOption == nil
            || ([selectedOption isKindOfClass:[NSArray class]] && [selectedOption count] == 0)
        ) {
            showOnIndexPath = [NSIndexPath indexPathForRow:i inSection:[indexPath section]];
            break;
        }
    }
    
    popover.popoverContentSize = [(DetailProductOptionsDetail *)self.detailControl reloadContentSize];
    [popover presentPopoverFromRect:CGRectMake(200, 0, 10, 44) inView:[tableView cellForRowAtIndexPath:showOnIndexPath] permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UIButton *)doneEditButton
{
    if (self.doneButtonView == nil) {
        self.doneButtonView = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        self.doneButtonView.frame = CGRectMake(0, [self.masterOptions count] * 44 + 10, 280, 44);
        [self.doneButtonView setTitle:NSLocalizedString(@"Add to Cart", nil) forState:UIControlStateNormal];
        [self.doneButtonView addTarget:self.parentViewController action:@selector(addProductToCart:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self.doneButtonView;
}

- (void)addCartButton
{
    [self.view.superview addSubview:[self doneEditButton]];
    [self refreshDoneButton];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSUInteger nextRow = [indexPath row];
    for (nextRow++; nextRow < [self.masterOptions count]; nextRow++) {
        NSDictionary *option = [self.masterOptions objectAtIndex:nextRow];
        if ([[option objectForKey:@"group"] isEqualToString:@"text"]) {
            break;
        }
    }
    if (nextRow < [self.masterOptions count]) {
        // move to next input text
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:nextRow inSection:[indexPath section]];
        UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:nextPath];
        UITextField *nextField = (UITextField *)[nextCell.contentView viewWithTag:CELL_TEXT_FIELD_TAG];
        [nextField becomeFirstResponder];
        return;
    }
}

@end
