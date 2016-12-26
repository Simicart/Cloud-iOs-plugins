//
//  PrinterSettingsViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 2/24/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "PrinterSettingsViewController.h"
#import "Configuration.h"

@interface PrinterSettingsViewController ()
- (void)changeAutoLoadPaper:(UISwitch *)sender;
@end

@implementation PrinterSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = 54;
    self.tableView.backgroundView = [UIView new];
    [self.tableView.backgroundView setBackgroundColor:[UIColor colorWithWhite:0.937 alpha:1]];
    
    self.title = NSLocalizedString(@"Print", nil);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:NO];
    [super viewWillDisappear:animated];
}

// Manual Print
// 0 - Star Micronisc TSP100LAN Printer
// 1 - A4 Printer (Magento Invoice Template)
// 2 - Receipt Printer Scroll
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([[[Configuration globalConfig] objectForKey:@"manual_print"] integerValue] == 2) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section) {
        return 2;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.backgroundColor = [UIColor whiteColor];
    if ([indexPath section]) {
        CGFloat paperWidth = 58;
        if ([[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue]) {
            paperWidth = [[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue];
        }
        CGFloat widths[4] = {58, 80, 148, 210};
        if (paperWidth == widths[[indexPath row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        switch ([indexPath row]) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"58mm (2.28 inch) roll paper", nil);
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"80mm (3.15 inch) roll paper", nil);
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"A5", nil);
                break;
            default:
                cell.textLabel.text = NSLocalizedString(@"A4", nil);
                break;
        }
//        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40, 0, 436, 54)];
//        [slider addTarget:self action:@selector(changeSliderValue:) forControlEvents:UIControlEventValueChanged];
//        slider.minimumValue = 37;
//        slider.maximumValue = 210;
//        if ([[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue]) {
//            slider.value = [[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue];
//        } else {
//            slider.value = 58;
//        }
//        [cell addSubview:slider];
//        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d mm", (int)slider.value];
    } else {
        switch ([indexPath row]) {
            case 1:
                cell.textLabel.text = NSLocalizedString(@"A4 Printer (Magento Invoice Template)", nil);
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"Receipt Printer Scroll", nil);
                break;
            default:
                cell.textLabel.text = NSLocalizedString(@"Star Micronisc TSP100LAN Printer", nil);
                break;
        }
        if ([[[Configuration globalConfig] objectForKey:@"manual_print"] integerValue] == [indexPath row]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.textLabel.text = NSLocalizedString(@"Autoload paper size", nil);
//        UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
//        [switcher addTarget:self action:@selector(changeAutoLoadPaper:) forControlEvents:UIControlEventValueChanged];
//        [switcher setOn:![[[Configuration globalConfig] objectForKey:@"manual_print"] boolValue]];
//        cell.accessoryView = switcher;
    }
    
    
     NSNumber * manualPrint = [[NSUserDefaults standardUserDefaults] objectForKey:@"manual_print"];
    if ([manualPrint integerValue] == [indexPath row]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
         cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section) {
        return NSLocalizedString(@"Choose Paper Size", nil);
    }
    return NSLocalizedString(@"Choose Printer Type", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"The receipt template will depends on printer type", nil);
//        return NSLocalizedString(@"System will load paper size from printer automatically.", nil);
    }
//    if (section) {
//        CGFloat paperWidth;
//        if ([[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue]) {
//            paperWidth = [[[Configuration globalConfig] objectForKey:@"paper_width"] integerValue];
//        } else {
//            paperWidth = 58;
//        }
//        paperWidth /= 25.4;
//        return [NSString stringWithFormat:@"%.2f inch", paperWidth];
//    }
    return nil;
}

#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:indexPath.row] forKey:@"manual_print"];
    [self.tableView reloadData];
    return;
    
    
    if ([indexPath section] == 0) {
        NSInteger oldType = [[[Configuration globalConfig] objectForKey:@"manual_print"] integerValue];
        NSInteger newType = [indexPath row];
        if (oldType != newType) {
            // Deselect old type
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldType inSection:0]].accessoryType = UITableViewCellAccessoryNone;
            // Select new type
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            // Save configuration
            [[Configuration globalConfig] setValue:[NSNumber numberWithInteger:newType] forKeyPath:@"manual_print"];
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newType] forKey:@"manual_print"];
            
            // Show/Hide paper size session
            if (newType == 2) {
                [tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            } else if (oldType == 2) {
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    CGFloat widths[4] = {58, 80, 148, 210};
    CGFloat oldWidth = [[[Configuration globalConfig] objectForKey:@"paper_width"] floatValue];
    if (oldWidth < 1) {
        oldWidth = 58;
    }
    CGFloat newWidth = widths[[indexPath row]];
    if (oldWidth != newWidth) {
        // Deselect old width
        for (NSUInteger i = 0; i < 4; i++) {
            if (oldWidth == widths[i]) {
                UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                oldCell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        // Select new width
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        // Save Config
        [[Configuration globalConfig] setValue:[NSNumber numberWithFloat:newWidth] forKey:@"paper_width"];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - actions
- (void)changeAutoLoadPaper:(UISwitch *)sender
{
    [[Configuration globalConfig] setValue:[NSNumber numberWithBool:![sender isOn]] forKey:@"manual_print"];
    if ([sender isOn]) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    }
}


@end
