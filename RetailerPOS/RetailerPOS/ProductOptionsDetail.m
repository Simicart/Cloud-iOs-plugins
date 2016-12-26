//
//  ProductOptionsDetail.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/22/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ProductOptionsDetail.h"
#import "Configuration.h"

@interface ProductOptionsDetail ()
@property (strong, nonatomic) UIButton *doneButtonView;
@property (strong, nonatomic) UIDatePicker *datePicker;
@end

@implementation ProductOptionsDetail
@synthesize doneButtonView;
@synthesize datePicker;

@synthesize optionViewController;
@synthesize masterControl;
@synthesize detailOptions;
@synthesize hasOptionsLabel;

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    if ([parent isKindOfClass:[ProductOptions class]]) {
        optionViewController = (ProductOptions *)parent;
    }
}

- (BOOL)hasSelectedOption
{
    NSDictionary *selectedOptions = [optionViewController productOptions];
    id selectedOption = [selectedOptions objectForKey:[self.detailOptions objectForKey:@"name"]];
    if (selectedOption == nil) {
        return NO;
    }
    if ([selectedOption isKindOfClass:[NSArray class]]
        && ![selectedOption count]
    ) {
        return NO;
    }
    return YES;
}

- (BOOL)optionIsSelected:(NSDictionary *)option
{
    NSDictionary *selectedOptions = [optionViewController productOptions];
    id selectedOption = [selectedOptions objectForKey:[self.detailOptions objectForKey:@"name"]];
    if (selectedOption == nil) {
        return NO;
    }
    if ([selectedOption isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)selectedOption indexOfObject:[option objectForKey:@"id"]] != NSNotFound) {
            return YES;
        }
    } else if ([selectedOption isEqual:[option objectForKey:@"id"]]) {
        return YES;
    }
    return NO;
}

- (NSDictionary *)productOptionsValue
{
    if ([[[Configuration globalConfig] objectForKey:@"in_stock_options"] boolValue]) {
        NSMutableDictionary *optionsValues = [NSMutableDictionary new];
        [(NSDictionary *)[self.detailOptions objectForKey:@"values"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (![[obj objectForKey:@"out_of_stock"] boolValue]) {
                [optionsValues setValue:obj forKey:key];
            }
        }];
        
        //NSLog(@"optionsValues:%@",optionsValues);
        return optionsValues;
    }
    
    //NSLog(@"self.detailOptions:%@",[self.detailOptions objectForKey:@"values"]);
    return [self.detailOptions objectForKey:@"values"];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([[self.detailOptions objectForKey:@"group"] isEqualToString:@"date"]) {
        return 1;
    }
    NSDictionary *optionValues = [self productOptionsValue];
    return [[optionValues allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.detailOptions objectForKey:@"group"] isEqualToString:@"date"]) {
        // Datetime picker
        static NSString *CellId = @"ProductOptionsDatetimeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
            datePicker = [[UIDatePicker alloc] init];
            [cell.contentView addSubview:datePicker];
            [datePicker addTarget:self action:@selector(changeDatePicker:) forControlEvents:UIControlEventValueChanged];
        }
        if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date"]) {
            datePicker.datePickerMode = UIDatePickerModeDate;
        } else if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date_time"]) {
            datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        } else {
            datePicker.datePickerMode = UIDatePickerModeTime;
        }
        datePicker.transform = CGAffineTransformMakeScale(1, 1);
        if (self.masterControl.view.hidden) {
            datePicker.frame = CGRectMake(0, -17, 320, 176);
        } else {
            datePicker.frame = CGRectMake(-39, 2, 320, 216);
            datePicker.transform = CGAffineTransformMakeScale(0.88, 1.02);
        }
        NSDictionary *selectedOptions = [optionViewController productOptions];
        id selectedOption = [selectedOptions objectForKey:[self.detailOptions objectForKey:@"name"]];
        if (selectedOption != nil && [selectedOption isKindOfClass:[NSString class]]) {
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date"]) {
                [dateFormater setDateFormat:@"yyyy-MM-dd"];
            } else if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date_time"]) {
                [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            } else {
                [dateFormater setDateFormat:@"HH:mm:ss"];
            }
            datePicker.date = [dateFormater dateFromString:selectedOption];
        } else if (selectedOption != nil) {
            NSString *result;
            NSString *format;
            if ([selectedOption objectForKey:@"day"]) {
                result = [NSString stringWithFormat:@"%@-%@-%@", [selectedOption objectForKey:@"year"], [selectedOption objectForKey:@"month"], [selectedOption objectForKey:@"day"]];
                format = @"yyyy-MM-dd";
            }
            if ([selectedOption objectForKey:@"hour"]) {
                if (result) {
                    result = [result stringByAppendingString:[NSString stringWithFormat:@" %@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]]];
                    format = [format stringByAppendingString:@" hh:mm aa"];
                } else {
                    result = [NSString stringWithFormat:@"%@:%@ %@", [selectedOption objectForKey:@"hour"], [selectedOption objectForKey:@"minute"], [selectedOption objectForKey:@"day_part"]];
                    format = @"hh:mm aa";
                }
            }
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            [dateFormater setDateFormat:format];
            datePicker.date = [dateFormater dateFromString:result];
        } else { // if (self.masterControl.view.hidden) {
            datePicker.date = [NSDate date];
            [self changeDatePicker:datePicker];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    static NSString *CellIdentifier = @"ProductOptionsDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
    }
    NSDictionary *optionValues = [self productOptionsValue];
    NSDictionary *option = [optionValues objectForKey:[[[optionValues allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[indexPath row]]];
    
    cell.textLabel.text = [option objectForKey:@"title"];
    if ([self optionIsSelected:option]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([[option objectForKey:@"out_of_stock"] boolValue]) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
    return cell;
}

- (IBAction)changeDatePicker:(id)sender
{
    NSMutableDictionary *selectedOptions = [optionViewController productOptions];
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    if ([self.detailOptions objectForKey:@"id"]) {
        // Magento Datetime Option
        NSMutableDictionary *optionValue = [NSMutableDictionary new];
        if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date"]) {
            [dateFormater setDateFormat:@"dd/MM/yyyy"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"date"];
            [dateFormater setDateFormat:@"yyyy"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"year"];
            [dateFormater setDateFormat:@"MM"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"month"];
            [dateFormater setDateFormat:@"dd"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"day"];
        } else if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date_time"]) {
            [dateFormater setDateFormat:@"yyyy"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"year"];
            [dateFormater setDateFormat:@"MM"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"month"];
            [dateFormater setDateFormat:@"dd"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"day"];
            [dateFormater setDateFormat:@"hh"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"hour"];
            [dateFormater setDateFormat:@"mm"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"minute"];
            [dateFormater setDateFormat:@"aa"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"day_part"];
        } else {
            [dateFormater setDateFormat:@"hh"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"hour"];
            [dateFormater setDateFormat:@"mm"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"minute"];
            [dateFormater setDateFormat:@"aa"];
            [optionValue setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:@"day_part"];
        }
        [selectedOptions setValue:optionValue forKey:[self.detailOptions objectForKey:@"name"]];
    } else {
        if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date"]) {
            [dateFormater setDateFormat:@"yyyy-MM-dd"];
        } else if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"date_time"]) {
            [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        } else {
            [dateFormater setDateFormat:@"HH:mm:ss"];
        }
        [selectedOptions setValue:[dateFormater stringFromDate:self.datePicker.date] forKey:[self.detailOptions objectForKey:@"name"]];
    }
    [self.masterControl refreshMasterOption:self.detailOptions];
    [self.masterControl refreshDoneButton];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *optionValues = [self productOptionsValue];
    NSDictionary *optionValue = [optionValues objectForKey:[[[optionValues allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[indexPath row]]];
    
    NSMutableDictionary *selectedOptions = [optionViewController productOptions];
    id selectedOption = [selectedOptions objectForKey:[self.detailOptions objectForKey:@"name"]];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // Multiple select first
    if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"checkbox"]
        || [[self.detailOptions objectForKey:@"type"] isEqualToString:@"multiple"]
    ) {
        if (selectedOption != nil && [[[selectedOption class] description] isEqualToString:@"__NSCFArray"]) {
            NSArray *bakOption = selectedOption;
            selectedOption = [[NSMutableArray alloc] init];
            [selectedOption setArray:bakOption];
            [selectedOptions setValue:selectedOption forKey:[self.detailOptions objectForKey:@"name"]];
        }
        // Update selected options
        if ([self optionIsSelected:optionValue]) {
            // Remove selected
            [selectedOption removeObject:[optionValue objectForKey:@"id"]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            if (selectedOption == nil) {
                selectedOption = [[NSMutableArray alloc] init];
                [selectedOptions setValue:selectedOption forKey:[self.detailOptions objectForKey:@"name"]];
            }
            [selectedOption addObject:[optionValue objectForKey:@"id"]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        if ([self hasSelectedOption]) {
            doneButtonView.enabled = YES;
        } else {
            doneButtonView.enabled = NO;
        }
        [self.masterControl refreshMasterOption:self.detailOptions];
    } else { // Single select - select then add to cart now
        if ([self optionIsSelected:optionValue]) {
            [selectedOptions removeObjectForKey:[self.detailOptions objectForKey:@"name"]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            if (selectedOption != nil) {
                NSUInteger oldIndex = [[[optionValues allKeys] sortedArrayUsingSelector:@selector(compare:)] indexOfObject:selectedOption];
                UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldIndex inSection:[indexPath section]]];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
            }
            [selectedOptions setValue:[optionValue objectForKey:@"id"] forKey:[self.detailOptions objectForKey:@"name"]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        if (self.masterControl.view.hidden) {
            [self.masterControl doneEditOptions:self];
        } else {
            [self.masterControl refreshMasterOption:self.detailOptions];
            if ([[Configuration getConfig:@"quick_select"] boolValue] && [self optionIsSelected:optionValue]) {
                [self.masterControl moveToNextOption];
            }
        }
    }
    [self.masterControl refreshDoneButton];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.detailOptions objectForKey:@"group"] isEqualToString:@"date"]) {
        self.tableView.scrollEnabled = NO;
    } else {
        self.tableView.scrollEnabled = YES;
    }
    if (self.hasOptionsLabel || !self.masterControl.view.hidden) {
        return 44;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[self.detailOptions objectForKey:@"group"] isEqualToString:@"date"]) {
        if (!self.masterControl.view.hidden) {
            return 221;
        }
        return 133;
    }
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.hasOptionsLabel) {
        if (self.masterControl.view.hidden) {
            return [self.detailOptions objectForKey:@"title"];
        }
        return NSLocalizedString(@"Values", nil);
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (view == nil) {
        return;
    }
    if (!self.masterControl.view.hidden) {
        [view addSubview:[self.masterControl doneEditButton]];
        if ([optionViewController validateOptions]) {
            self.masterControl.doneButtonView.enabled = YES;
        } else {
            self.masterControl.doneButtonView.enabled = NO;
        }
        return;
    }
    if (!self.hasOptionsLabel) {
        return;
    }
    if ([[self.detailOptions objectForKey:@"type"] isEqualToString:@"checkbox"]
        || [[self.detailOptions objectForKey:@"type"] isEqualToString:@"multiple"]
        || [[self.detailOptions objectForKey:@"group"] isEqualToString:@"date"]
        || [optionViewController validateOptions]
        ) {
        [view addSubview:[self doneEditButton]];
        if ([[self.detailOptions objectForKey:@"group"] isEqualToString:@"date"]
            || ![[self.detailOptions objectForKey:@"required"] boolValue]
            || [self hasSelectedOption]
        ) {
            doneButtonView.enabled = YES;
        } else {
            doneButtonView.enabled = NO;
        }
    }
}

#pragma mark - custom section cell
- (UIButton *)doneEditButton
{
    if (doneButtonView != nil) {
        return doneButtonView;
    }
    doneButtonView = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    doneButtonView.frame = CGRectMake(246, 5, 68, 36);
    [doneButtonView setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    
    [doneButtonView addTarget:self action:@selector(doneEditOptions:) forControlEvents:UIControlEventTouchUpInside];
    return doneButtonView;
}

- (IBAction)doneEditOptions:(id)sender
{
    [self.masterControl doneEditOptions:sender];
}

@end
