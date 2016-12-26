//
//  ItemDiscountForm.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/11/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ItemDiscountForm.h"
#import "MSFramework.h"
#import "EditItemViewController.h"
#import "Price.h"
#import "Quote.h"

@interface ItemDiscountForm ()
@property (strong, nonatomic) MSSegmentedControl *discountType;
@property (strong, nonatomic) MSTextField *discountAmount;
@property (strong, nonatomic) MSTextField *discountPercentage;

@property (nonatomic) long double currentPrice;
@end

@implementation ItemDiscountForm
@synthesize discountType;
@synthesize discountAmount;
@synthesize discountPercentage;
@synthesize currentPrice;

@synthesize item = _item;
@synthesize isShowedNumberPad;

@synthesize isFirtTimeDisplay;
@synthesize segmentIndex;
@synthesize customPrice;

@synthesize backButton;
@synthesize doneButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.scrollEnabled = NO;
    
	// Do any additional setup after loading the view.
    discountType = [[MSSegmentedControl alloc] initWithItems:@[NSLocalizedString(@"$", nil), NSLocalizedString(@"%", nil)]];
    discountType.frame = CGRectMake(0, 0, 144, 44);
    [discountType addTarget:self action:@selector(toggleDiscountType:) forControlEvents:UIControlEventValueChanged];
    
    discountAmount = [[MSTextField alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    discountAmount.font = [UIFont boldSystemFontOfSize:22];
    discountAmount.textPadding = UIEdgeInsetsMake(8, 0, 0, 0);
    discountAmount.textAlignment = NSTextAlignmentRight;
    discountAmount.delegate = self;
    
    discountPercentage = [[MSTextField alloc] initWithFrame:CGRectMake(0, 0, 120, 44)];
    discountPercentage.font = [UIFont boldSystemFontOfSize:22];
    discountPercentage.textPadding = UIEdgeInsetsMake(8, 0, 0, 0);
    discountPercentage.textAlignment = NSTextAlignmentRight;
    discountPercentage.delegate = self;
}

- (IBAction)toggleDiscountType:(id)sender
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if ([sender selectedSegmentIndex]) {
        self.currentPrice = [MSNumberPad keyboard].currentValue;
        cell.textLabel.text = NSLocalizedString(@"Percentage", nil);
        cell.accessoryView = self.discountPercentage;
        
        NSString *percenText = self.discountPercentage.text;
        if (percenText == nil || percenText.length == 0) {
            self.discountPercentage.text = @"0.00%";
            percenText = self.discountPercentage.text;
        }
        CGFloat percentage = [[percenText substringToIndex:(percenText.length - 1)] floatValue];
        [MSNumberPad keyboard].currentValue = percentage;
        
        [MSNumberPad keyboard].floatPoints = 2;
        [MSNumberPad keyboard].maxInput = 5;
        [MSNumberPad keyboard].textField = self.discountPercentage;
    } else {
        cell.textLabel.text = NSLocalizedString(@"Price", nil);
        cell.accessoryView = self.discountAmount;
        
        [MSNumberPad keyboard].floatPoints = [Price precision];
        [MSNumberPad keyboard].maxInput = 13;
        [MSNumberPad keyboard].currentValue = self.currentPrice; // self.customPrice;
        [MSNumberPad keyboard].textField = self.discountAmount;
    }
}

- (CGSize)reloadContentSize
{
    CGFloat width = 288;
    CGFloat height = 176; // 2 x 66 + 44
    // if (self.isShowedNumberPad) {
        height += 241;
    // }
//    self.contentSizeForViewInPopover = CGSizeMake(width, height);
//    return self.contentSizeForViewInPopover;
    
    self.preferredContentSize = CGSizeMake(width, height);
    return self.preferredContentSize;
}

#pragma mark - table view  data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"ItemDiscountFormCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    switch ([indexPath row]) {
        case 0: // Discount Type
            cell.textLabel.text = NSLocalizedString(@"Type", nil);
            cell.accessoryView = self.discountType;
            [self.discountType setSelectedSegmentIndex:self.segmentIndex];
            break;
        case 1: // Discount Amount
            [[MSNumberPad keyboard] resetConfig];
            [MSNumberPad keyboard].delegate = self;
            [MSNumberPad keyboard].doneLabel = @"00";
            self.currentPrice = 0;
            
            if (self.isFirtTimeDisplay) {
                long double price = [[self.item getRegularPrice] doubleValue];
                if (price > 0 && [self.item hasSpecialPrice]) {
                    float percent = 100 * [[self.item getPrice] doubleValue] / price;
                    self.discountPercentage.text = [NSString stringWithFormat:@"%.2f%%", percent];
                } else {
                    self.discountPercentage.text = @"0.00%";
                }
            }
            
            if ([self.discountType selectedSegmentIndex]) {
                cell.textLabel.text = NSLocalizedString(@"Percentage", nil);
                cell.accessoryView = self.discountPercentage;
                if (self.isFirtTimeDisplay) {
                    [MSNumberPad keyboard].currentValue = 0;
                } else {
                    NSString *percenText = self.discountPercentage.text;
                    if (percenText == nil || percenText.length == 0) {
                        self.discountPercentage.text = @"0.00%";
                        percenText = self.discountPercentage.text;
                    }
                    CGFloat percentage = [[percenText substringToIndex:(percenText.length - 1)] floatValue];
                    [MSNumberPad keyboard].currentValue = percentage;
                }
                [MSNumberPad keyboard].floatPoints = 2;
                [MSNumberPad keyboard].maxInput = 5;
                [MSNumberPad keyboard].textField = self.discountPercentage;
            } else {
                cell.textLabel.text = NSLocalizedString(@"Price", nil);
                cell.accessoryView = self.discountAmount;
                self.discountAmount.text = [Price format:[NSNumber numberWithFloat:self.customPrice]];
                
                [MSNumberPad keyboard].floatPoints = [Price precision];
                [MSNumberPad keyboard].maxInput = 13;
                [MSNumberPad keyboard].currentValue = self.customPrice;
                [MSNumberPad keyboard].textField = self.discountAmount;
            }
            if (!self.isShowedNumberPad) {
                self.isShowedNumberPad = YES;
                [[MSNumberPad keyboard] showOn:self atFrame:CGRectMake(0, 176, 288, 241)];
            }
            break;
        default: // Empty Cell
            cell.textLabel.text = nil;
            cell.accessoryView = nil;
            break;
    }
    return cell;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (/*self.isShowedNumberPad && */[indexPath row] == 2) {
        return 241;
    }
    return 66;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"           %@", NSLocalizedString(@"Custom Price", nil)];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (backButton == nil) {
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        backButton.frame = CGRectMake(0, 5, 44, 36);
        [backButton addTarget:self action:@selector(backEdit:) forControlEvents:UIControlEventTouchUpInside];
        
        doneButton = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        [doneButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
        doneButton.frame = CGRectMake(214, 5, 68, 36);
        [doneButton addTarget:self action:@selector(doneEdit:) forControlEvents:UIControlEventTouchUpInside];
    }
    [view addSubview:backButton];
    [view addSubview:doneButton];
}

- (IBAction)doneEdit:(id)sender
{
    self.segmentIndex = [self.discountType selectedSegmentIndex];
    EditItemViewController *editItem = (EditItemViewController *)self.navigationController.delegate;
    UITableViewCell *cell = [editItem.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    if (self.segmentIndex) {
        if ([MSNumberPad keyboard].currentValue == 100) {
            [[[NSThread alloc] initWithTarget:self selector:@selector(updatePriceThread:) object:[NSNull null]] start];
            cell.detailTextLabel.text = NSLocalizedString(@"None", nil);
        } else {
            long double price = [MSNumberPad keyboard].currentValue * [[self.item getRegularPrice] doubleValue] / 100;
            [[[NSThread alloc] initWithTarget:self selector:@selector(updatePriceThread:) object:[NSNumber numberWithDouble:price]] start];
            cell.detailTextLabel.text = [Price format:[NSNumber numberWithDouble:price]];
        }
    } else {
        if ([MSNumberPad keyboard].currentValue == [[self.item getRegularPrice] floatValue]) {
            [[[NSThread alloc] initWithTarget:self selector:@selector(updatePriceThread:) object:[NSNull null]] start];
            cell.detailTextLabel.text = NSLocalizedString(@"None", nil);
        } else {
            [[[NSThread alloc] initWithTarget:self selector:@selector(updatePriceThread:) object:[NSNumber numberWithDouble:[MSNumberPad keyboard].currentValue]] start];
            cell.detailTextLabel.text = [Price format:[NSNumber numberWithDouble:[MSNumberPad keyboard].currentValue]];
        }
    }
    // Back to Edit item
    [self backEdit:sender];
}

- (void)updatePriceThread:(id)price
{
    [[Quote sharedQuote] updateItemPrice:[self.item getId] price:price];
}

- (IBAction)backEdit:(id)sender
{
    EditItemViewController *editItem = (EditItemViewController *)self.navigationController.delegate;
    [editItem rePresentPopover:[editItem reloadContentSize]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Text Field delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if (!self.isShowedNumberPad) {
//        self.isShowedNumberPad = YES;
//        
//        [[MSNumberPad keyboard] showOn:self atFrame:CGRectMake(0, 176, 288, 241)];
//        EditItemViewController *parentControl = (EditItemViewController *)self.navigationController.delegate;
//        [parentControl rePresentPopover:[self reloadContentSize]];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//    }
    return NO;
}

#pragma mark - Number pad delegate
- (void)numberPad:(MSNumberPad *)numberPad willShowButton:(UIButton *)button
{
    if (button.tag == 13) {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:28];
    }
}

- (BOOL)numberPadShouldDone:(MSNumberPad *)numberPad
{
    UIButton *zeroButton = (UIButton *)[numberPad.view viewWithTag:0];
    [numberPad numberButtonTapped:zeroButton];
    [numberPad numberButtonTapped:zeroButton];
    return NO;
}

- (NSString *)numberPadFormatOutput:(MSNumberPad *)numberPad
{
    if ([self.discountType selectedSegmentIndex]) {
        return [NSString stringWithFormat:@"%.2f%%", (CGFloat)numberPad.currentValue];
    }
    return [Price format:[NSNumber numberWithDouble:numberPad.currentValue]];
}

@end
