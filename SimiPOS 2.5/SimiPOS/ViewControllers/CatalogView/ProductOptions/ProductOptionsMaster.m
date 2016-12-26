//
//  ProductOptionsMaster.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/22/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ProductOptionsMaster.h"

#define CELL_TEXT_LABEL_TAG     1
#define CELL_TEXT_FIELD_TAG     2

@interface OptionTextField : UITextField
@end
@implementation OptionTextField
// Implement text field input for options
//-(CGRect)textRectForBounds:(CGRect)bounds {
//    return CGRectMake(0, 22, bounds.size.width, 21);
//}
//-(CGRect)editingRectForBounds:(CGRect)bounds {
//    if (self.text != nil
//        && ![self.text isEqualToString:@""]
//    ) {
//        return CGRectMake(0, 22, bounds.size.width - 21, 21);
//    }
//    return CGRectMake(0, 22, bounds.size.width, 21);
//}
//-(CGRect)clearButtonRectForBounds:(CGRect)bounds {
//    return CGRectMake(bounds.size.width - 20, 21, 21, 21);
//}
@end

@implementation ProductOptionsMaster
@synthesize currentSelectedPath;

@synthesize doneButtonView;

@synthesize tableWidth;
@synthesize detailControl;
@synthesize masterOptions;

- (id)selectedValues:(NSDictionary *)option
{
    NSMutableDictionary *selectedOptions = [(ProductOptions *)self.parentViewController productOptions];
    id selectedOption = [selectedOptions objectForKey:[option objectForKey:@"name"]];
    if (selectedOption == nil) {
        return nil;
    }
    if ([[option objectForKey:@"group"] isEqualToString:@"date"]) {
        if ([selectedOption isKindOfClass:[NSString class]]) {
            return selectedOption;
        }
        NSString *result;
        if ([selectedOption objectForKey:@"day"]) {
            result = [NSString stringWithFormat:@"%@-%@-%@", [selectedOption objectForKey:@"year"], [selectedOption objectForKey:@"month"], [selectedOption objectForKey:@"day"]];
        }
        if ([selectedOption objectForKey:@"hour"]) {
            if (result) {
                result = [result stringByAppendingString:[NSString stringWithFormat:@" %@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]]];
            } else {
                result = [NSString stringWithFormat:@"%@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]];
            }
        }
        return result;
    }
    if ([[option objectForKey:@"group"] isEqualToString:@"text"]) {
        return selectedOption;
    }
    NSDictionary *optionValues = [option objectForKey:@"values"];
    if ([selectedOption isKindOfClass:[NSArray class]]) {
        NSMutableArray *optionTitles = [[NSMutableArray alloc] init];
        for (id valueId in selectedOption) {
            [optionTitles addObject:[[optionValues objectForKey:valueId] objectForKey:@"title"]];
        }
        return [optionTitles componentsJoinedByString:@", "];
    }
    if ([optionValues count]) {
        return [[optionValues objectForKey:selectedOption] objectForKey:@"title"];
    }
    return selectedOption;
}

- (void)refreshDoneButton
{
    if (!self.doneButtonView) {
        return;
    }
    if ([(ProductOptions *)self.parentViewController validateOptions]) {
        doneButtonView.enabled = YES;
    } else {
        doneButtonView.enabled = NO;
    }
}

- (void)refreshMasterOption:(NSDictionary *)option
{
    if (self.view.hidden) {
        return;
    }
    if (!self.currentSelectedPath) {
        return;
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.currentSelectedPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:self.currentSelectedPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)moveToNextOption
{
    if (self.view.hidden) {
        return;
    }
    NSUInteger nextRow = [self.currentSelectedPath row];
    for (nextRow++; nextRow < [self.masterOptions count]; nextRow++) {
        NSDictionary *option = [self.masterOptions objectAtIndex:nextRow];
        if ([[option objectForKey:@"group"] isEqualToString:@"select"]
            || [[option objectForKey:@"group"] isEqualToString:@"date"]
        ) {
            break;
        }
    }
    if (nextRow < [self.masterOptions count]) {
        NSIndexPath *nextPath = [NSIndexPath indexPathForRow:nextRow inSection:[self.currentSelectedPath section]];
        [self.tableView deselectRowAtIndexPath:self.currentSelectedPath animated:YES];
        [self tableView:self.tableView didSelectRowAtIndexPath:nextPath];
        [self.tableView selectRowAtIndexPath:self.currentSelectedPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        return;
    }
    if ([self.currentSelectedPath row] == [self.masterOptions count] - 1
        && [(ProductOptions *)self.parentViewController validateOptions]
    ) {
        [self doneEditOptions:self];
    }
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.masterOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductOptionsMasterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = CELL_TEXT_LABEL_TAG;
        label.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:label];
        
        OptionTextField *textField = [[OptionTextField alloc] init];
        textField.tag = CELL_TEXT_FIELD_TAG;
        textField.clearsOnBeginEditing = NO;
        textField.textAlignment = NSTextAlignmentRight;
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
        // bug
        
        label.hidden = NO;
        textField.hidden = NO;
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        label.frame = CGRectMake(10, 4, self.tableWidth - 20, 22);
        textField.frame = CGRectMake(10, label.frame.origin.y + label.frame.size.height, self.tableWidth - 20, 26);
        label.text = [NSString stringWithFormat:@"%@:", [option objectForKey:@"title"]];
        textField.placeholder = [option objectForKey:@"title"];
        [textField setTextAlignment:(NSTextAlignmentLeft)];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([[option objectForKey:@"required"] boolValue]
            && ![self selectedValues:option]
        ) {
            cell.detailTextLabel.text = NSLocalizedString(@"Required", nil);
            cell.detailTextLabel.textColor = [UIColor redColor];
        } else {
            cell.detailTextLabel.text = [self selectedValues:option];
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        }
        // Highlight for current selected option
        if ([[option objectForKey:@"id"] isEqual:[self.detailControl.detailOptions objectForKey:@"id"]]) {
            currentSelectedPath = indexPath;
            cell.selected = YES;
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return cell;
}

#pragma mark - Table view delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *option = [self.masterOptions objectAtIndex:[indexPath row]];
    if ([[option objectForKey:@"group"] isEqualToString:@"text"]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *option = [self.masterOptions objectAtIndex:[indexPath row]];
    if ([[option objectForKey:@"group"] isEqualToString:@"text"]) {
        return;
    }
    if ([indexPath isEqual:currentSelectedPath]) {
        return;
    }
    // Update detail view
    if ([[option objectForKey:@"config"] boolValue]) {
        // Configurable values
        NSMutableDictionary *values = [[NSMutableDictionary alloc] initWithDictionary:[option objectForKey:@"values"]];
        for (NSUInteger i = 0; i < [indexPath row]; i++) {
            NSDictionary *cOption = [self.masterOptions objectAtIndex:i];
            if (![[cOption objectForKey:@"config"] boolValue]) {
                continue;
            }
            
            NSMutableDictionary *selectedOptions = [(ProductOptions *)self.parentViewController productOptions];
            id selectedOption = [selectedOptions objectForKey:[cOption objectForKey:@"name"]];
            if (selectedOption == nil) {
                [tableView selectRowAtIndexPath:currentSelectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                return;
            }
            if ([selectedOption isKindOfClass:[NSArray class]]) {
                if ([selectedOption count]) {
                    selectedOption = [selectedOption objectAtIndex:0];
                } else {
                    [tableView selectRowAtIndexPath:currentSelectedPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                    return;
                }
            }
            NSArray *products = [[[[cOption objectForKey:@"values"] objectForKey:selectedOption] objectForKey:@"products"] allKeys];
            [values enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
                NSArray *vProducts = [[value objectForKey:@"products"] allKeys];
                BOOL noProduct = YES;
                for (id product in vProducts) {
                    if ([products containsObject:product]) {
                        noProduct = NO;
                        break;
                    }
                }
                if (noProduct) {
                    [values removeObjectForKey:key];
                }
            }];
        }
        NSMutableDictionary *configOption = [[NSMutableDictionary alloc] initWithDictionary:option];
        [configOption setValue:values forKey:@"values"];
        self.detailControl.detailOptions = configOption;
    } else {
        self.detailControl.detailOptions = option;
    }
    currentSelectedPath = indexPath;
    [self.detailControl.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.masterOptions count] > 1) {
        return 44;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Select Options", nil);
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (view == nil || [self.masterOptions count] < 2 || !self.detailControl.view.hidden) {
        return;
    }
    [view addSubview:[self doneEditButton]];
    if ([(ProductOptions *)self.parentViewController validateOptions]) {
        doneButtonView.enabled = YES;
    } else {
        doneButtonView.enabled = NO;
    }
}

#pragma mark - custom section cell
- (UIButton *)doneEditButton
{
    if (doneButtonView == nil) {
        doneButtonView = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        [doneButtonView setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        
        [doneButtonView addTarget:self action:@selector(doneEditOptions:) forControlEvents:UIControlEventTouchUpInside];
    }
    doneButtonView.frame = CGRectMake(self.tableWidth - 74, 5, 68, 36);
    return doneButtonView;
}

- (IBAction)doneEditOptions:(id)sender
{
    [(ProductOptions *)self.parentViewController addProductToCart];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:CELL_TEXT_LABEL_TAG];
    
    NSDictionary *option = [self.masterOptions objectAtIndex:[indexPath row]];
    if ([[option objectForKey:@"required"] boolValue]
        && [textField.text isEqualToString:@""]
    ) {
        label.textColor = [UIColor redColor];
    } else {
        label.textColor = [UIColor blackColor];
    }
    NSMutableDictionary *selectedOptions = [(ProductOptions *)self.parentViewController productOptions];
    [selectedOptions setValue:textField.text forKey:[option objectForKey:@"name"]];
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
    // try to add product to cart
    if ([indexPath row] == [self.masterOptions count] - 1
        && [(ProductOptions *)self.parentViewController validateOptions]
    ) {
        [self doneEditOptions:self];
    }
}

@end
