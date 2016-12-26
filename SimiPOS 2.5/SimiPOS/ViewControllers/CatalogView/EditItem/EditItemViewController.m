//
//  EditItemViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/5/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "EditItemViewController.h"
#import "Product.h"
#import "Quote.h"
#import "Price.h"


@implementation EditItemViewController{
    Permission * permission;
    CGFloat quantity;
}
@synthesize cartItemPopover;

@synthesize item = _item;
@synthesize itemIndexPath;
@synthesize itemTableView;

@synthesize isShowedQtyInput;
@synthesize discountForm;
@synthesize isShowedDiscountForm;
@synthesize itemOptions;
@synthesize isShowedItemOptions;

- (CGSize)reloadContentSize
{
    CGFloat width =288;
    CGFloat height = 352; // 220 + 66 + 66
    
    if (self.isShowedQtyInput) {
        height += 175;
    } else if ([self.item.product hasOptions]) {
        height += 66;
    }
    height += 66;
    self.preferredContentSize = CGSizeMake(width, height);
    return CGSizeMake(width, height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Init before show
    self.tableView.scrollEnabled = YES;
    permission = [Permission MR_findFirst];
//    quantity = 1;
}

- (void)updateQuoteItem:(NSDictionary *)options
{
    self.isShowedItemOptions = YES;
    [[[NSThread alloc] initWithTarget:self selector:@selector(threadUpdateQuoteItem:) object:options] start];
}

- (void)threadUpdateQuoteItem:(NSDictionary *)options
{
    [[Quote sharedQuote] updateItem:[self.item getId] withOptions:options];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(permission.items_custom_price.boolValue || permission.items_discount.boolValue){
        if ([self.item.product hasOptions]) {
            return 5;
        }
        return 4;
    }else{
        if ([self.item.product hasOptions]) {
            return 4;
        }
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.item.product hasOptions]) {
        switch ([indexPath row]) {
            case 0:
                return [self itemImageCell];
            case 1:
                return [self qtyEditItemCell];
            case 2:
                if (self.isShowedQtyInput) {
                    // Empty Row
                    static NSString *EmptyCell = @"EmptyTableViewCell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EmptyCell];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCell];
                    }
                    return cell;
                }
                if(permission.items_custom_price.boolValue || permission.items_discount.boolValue){
                    return [self discountItemCell];
                }
                if ([self.item.product hasOptions]) {
                    return [self optionsItemCell];
                }
                return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableViewCell"];
            case 3:
                return [self optionsItemCell];
            default:
                return [self updateQtyItemCell];
        }
    } else {
        switch ([indexPath row]) {
            case 0:
                return [self itemImageCell];
            case 1:
                return [self qtyEditItemCell];
            case 2:
                if (self.isShowedQtyInput) {
                    // Empty Row
                    static NSString *EmptyCell = @"EmptyTableViewCell";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EmptyCell];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EmptyCell];
                    }
                    return cell;
                }
                if(permission.items_custom_price.boolValue || permission.items_discount.boolValue){
                    return [self discountItemCell];
                }
                if ([self.item.product hasOptions]) {
                    return [self optionsItemCell];
                }
                return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyTableViewCell"];
            case 3:
                return [self updateQtyItemCell];
            default:
                return [self updateQtyItemCell];
        }
    }
    
}

- (UITableViewCell *)itemImageCell
{
    static NSString *CellID = @"EditItemImageCell";
    CGRect frameAccessoryView =CGRectMake(0, 0, 288, 220);
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // Item Image
        // cell.accessoryView =[[UIImageView alloc] initWithFrame:frameAccessoryView];
        UIImageView *itemImage = [[UIImageView alloc] initWithFrame:frameAccessoryView];   //(UIImageView *)cell.accessoryView;
        itemImage.contentMode =UIViewContentModeScaleToFill;
        itemImage.tag=101;
        [cell.contentView addSubview:itemImage];
        
        
        // Item Name
        UILabel *itemName = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, CGRectGetWidth(frameAccessoryView), 60)];
        itemName.textColor = [UIColor whiteColor];
        itemName.textAlignment = NSTextAlignmentCenter;
        itemName.tag = 1;
        if ([MSValidator isEmptyString:[self.item objectForKey:@"message"]]) {
            itemName.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            itemName.text = [self.item objectForKey:@"name"];
            itemName.numberOfLines = 2;
        } else {
            itemName.backgroundColor = [UIColor colorWithRed:1.0f green:0.0 blue:0.0 alpha:0.4];
            itemName.frame = CGRectMake(-1, 0, 289, 220);
            itemName.text = [self.item objectForKey:@"message"];
            itemName.numberOfLines = 0;
        }
        [cell.contentView addSubview:itemName];
    }
    UIImageView *itemImage =(UIImageView *)[cell viewWithTag:101];   //(UIImageView *)cell.accessoryView;
    [itemImage setImageWithURL:[NSURL URLWithString:[self.item objectForKey:@"image"]] placeholderImage:[UIImage imageNamed:@"item_placeholder.png"]];
    
    UILabel *itemName = (UILabel *)[cell viewWithTag:1];
    if ([MSValidator isEmptyString:[self.item objectForKey:@"message"]]) {
        itemName.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        itemName.frame = CGRectMake(0, 160, CGRectGetWidth(frameAccessoryView), 60);
        itemName.text = [self.item objectForKey:@"name"];
        itemName.numberOfLines = 2;
    } else {
        itemName.backgroundColor = [UIColor colorWithRed:1.0f green:0.0 blue:0.0 alpha:0.4];
        itemName.frame = CGRectMake(0, 0, CGRectGetWidth(frameAccessoryView), 220);
        itemName.text = [self.item objectForKey:@"message"];
        itemName.numberOfLines = 0;
    }
    
    return cell;
}

- (UITableViewCell *)qtyEditItemCell
{
    static NSString *CellId = @"EditItemQtyCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIButton *decrease = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        decrease.tag = 4;
        decrease.frame = CGRectMake(6, 6, 88, 52);
        decrease.titleLabel.font = [UIFont boldSystemFontOfSize:40];
        [decrease setTitle:@"-" forState:UIControlStateNormal];
        [decrease addTarget:self action:@selector(decreaseItemQty:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:decrease];
        
        MSTextField *qtyText = [[MSTextField alloc] initWithFrame:CGRectMake(100, 7, 88, 52)];
        qtyText.tag = 1;
        qtyText.textPadding = UIEdgeInsetsMake(7, 0, 0, 0);
        qtyText.font = [UIFont boldSystemFontOfSize:32];
        qtyText.textAlignment = NSTextAlignmentCenter;
        qtyText.borderStyle = UITextBorderStyleRoundedRect;
        qtyText.returnKeyType = UIReturnKeyDone;
        [qtyText setKeyboardType:UIKeyboardTypeNumberPad];
        [qtyText addTarget:self action:@selector(changeItemQty:) forControlEvents:UIControlEventEditingChanged];
        qtyText.delegate = self;
        [cell addSubview:qtyText];
        
        UIButton *increase = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        increase.frame = CGRectMake(194, 6, 88, 52);
        increase.titleLabel.font = [UIFont boldSystemFontOfSize:40];
        [increase setTitle:@"+" forState:UIControlStateNormal];
        [increase addTarget:self action:@selector(increaseItemQty:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:increase];
    }
    UITextField *qtyText = (UITextField *)[cell viewWithTag:1];
    UIButton *decrease = (UIButton *)[cell viewWithTag:4];
    qtyText.text = [NSString stringWithFormat:@"%.0f", [self.item getQty]];
    [decrease setEnabled:YES];
    return cell;
}

- (IBAction)changeItemQty:(id)sender
{
    UITextField *qtyText = (UITextField *)sender;
    UIButton *decrease = (UIButton *)[[sender superview] viewWithTag:4];
    CGFloat qty = [qtyText.text floatValue];
    if (qty <= 0) {
        [decrease setEnabled:NO];
        if (qty < 0) {
            qtyText.text = @"0";
        }
        return;
    }
    [decrease setEnabled:YES];
    quantity = qty;
}

- (IBAction)decreaseItemQty:(id)sender
{
    UITextField *qtyText = (UITextField *)[[sender superview] viewWithTag:1];
    CGFloat oldQty = [qtyText.text floatValue];
    if (oldQty == 1) {
        return;
    }
    CGFloat qty = [qtyText.text floatValue] - 1;
    qtyText.text = [NSString stringWithFormat:@"%.0f", qty];
    [MSNumberPad keyboard].currentValue = qty;
    [sender setEnabled:YES];
    quantity = qty;
//    [self updateItemQty:qty];
}

- (IBAction)increaseItemQty:(id)sender
{
    UITextField *qtyText = (UITextField *)[[sender superview] viewWithTag:1];
    CGFloat qty = [qtyText.text floatValue] + 1;
    if (qty == 1) {
        UIButton *decrease = (UIButton *)[[sender superview] viewWithTag:4];
        [decrease setEnabled:YES];
    }
    qtyText.text = [NSString stringWithFormat:@"%.0f", qty];
    [MSNumberPad keyboard].currentValue = qty;
    quantity = qty;
//    [self updateItemQty:qty];
}

- (UITableViewCell *)discountItemCell
{
    static NSString *CellId = @"EditItemDiscountCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Custom Price", nil);
    }
    // Discount Text
    if ([self.item hasSpecialPrice]) {
        cell.detailTextLabel.text = [Price format:[self.item getPrice]];
    } else {
        cell.detailTextLabel.text = NSLocalizedString(@"None", nil);
    }
    return cell;
}

- (UITableViewCell *)optionsItemCell
{
    static NSString *CellId = @"EditItemOptionCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[MSTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = NSLocalizedString(@"Options", nil);
    }
    cell.detailTextLabel.text = [self.item getOptionsLabel];
    return cell;
}
- (UITableViewCell *)updateQtyItemCell
{
    static NSString *CellId = @"EditItemUpdateQtyCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *updateBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
//        updateBtn.tag = 5;
        updateBtn.frame = CGRectMake(0, 0, 288, 66);
        updateBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [updateBtn setTitle:@"Update Quantity" forState:UIControlStateNormal];
        [updateBtn addTarget:self action:@selector(updateItemQuantity) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:updateBtn];
    }
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isShowedQtyInput && [indexPath row] == 2) {
        return 241;
    }
    if ([indexPath row] == 0) {
        return 220;
    }
    return 66;
}

-(void)updateItemQuantity {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self updateItemQty:quantity];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(permission.items_discount.boolValue || permission.items_custom_price.boolValue){
        // Select Row and Take Action
        if ([indexPath row] == 3) {
            // Select Options
            if (itemOptions == nil) {
                itemOptions = [[EditItemOptions alloc] init];
            }
            itemOptions.product = self.item.product;
            if (!isShowedItemOptions) {
                [itemOptions.productOptions removeAllObjects];
                [itemOptions.productOptions addEntriesFromDictionary:self.item.options];
            }
            
            [self.navigationController pushViewController:itemOptions animated:YES];
            [self rePresentPopover:[itemOptions reloadContentSize]];
            
            return;
        }
        if ([indexPath row] != 2) {
            return;
        }
        
        // Discount Form
        if (discountForm == nil) {
            discountForm = [[ItemDiscountForm alloc] init];
        }
        discountForm.item = self.item;
        discountForm.isShowedNumberPad = NO;
        if (!self.isShowedDiscountForm) {
            self.isShowedDiscountForm = YES;
            // Init discount for first time display
            discountForm.isFirtTimeDisplay = YES;
            discountForm.segmentIndex = 0;
            if ([self.item hasSpecialPrice]) {
                discountForm.customPrice = [[self.item getPrice] doubleValue];
            } else {
                discountForm.customPrice = 0; // [[self.item getPrice] doubleValue];
            }
        } else {
            discountForm.isFirtTimeDisplay = NO;
        }
        [discountForm.tableView reloadData];
        [self.navigationController pushViewController:discountForm animated:YES];
        [discountForm reloadContentSize];
    }else{
        // Select Row and Take Action
        if ([indexPath row] == 2 && [self.item.product hasOptions]) {
            // Select Options
            if (itemOptions == nil) {
                itemOptions = [[EditItemOptions alloc] init];
            }
            itemOptions.product = self.item.product;
            if (!isShowedItemOptions) {
                [itemOptions.productOptions removeAllObjects];
                [itemOptions.productOptions addEntriesFromDictionary:self.item.options];
            }
            
            [self.navigationController pushViewController:itemOptions animated:YES];
            [self rePresentPopover:[itemOptions reloadContentSize]];
            
            return;
        }
    }
}

- (void)rePresentPopover:(CGSize)popoverContentSize
{
    self.cartItemPopover.popoverContentSize = popoverContentSize;
    CGRect frame = [[itemTableView cellForRowAtIndexPath:itemIndexPath] frame];
    [self.cartItemPopover presentPopoverFromRect:frame inView:itemTableView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

#pragma mark - UITextField delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (!self.isShowedQtyInput) {
        self.isShowedQtyInput = YES;
        MSNumberPad *keyboard = [MSNumberPad keyboard];
        [keyboard resetConfig];
        keyboard.textField = textField;
        keyboard.delegate = self;
        [keyboard showOn:self atFrame:CGRectMake(0, 286, 288, 241)];
        
        [self rePresentPopover:[self reloadContentSize]];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    [MSNumberPad keyboard].currentValue = [textField.text floatValue];
    return NO;
}

#pragma mark - NumberPad Delegate
-(void)numberPad:(MSNumberPad *)numberPad didChangeValue:(NSInteger)value
{
    UIButton *decrease = (UIButton *)[[numberPad.textField superview] viewWithTag:4];
    if (numberPad.currentValue > 0) {
        [decrease setEnabled:YES];
    } else {
        [decrease setEnabled:NO];
    }
}

-(void)numberPadDidDone:(MSNumberPad *)numberPad
{
    self.isShowedQtyInput = NO;
    [numberPad hidePad];
    [self rePresentPopover:[self reloadContentSize]];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    quantity = numberPad.currentValue;
//    [self updateItemQty:numberPad.currentValue];
}

-(void)updateItemQty:(CGFloat)qty
{
    if (qty > 0 && [self.item getQty] != qty) {
        NSNumber *qtyObj = [NSNumber numberWithFloat:qty];
        [[[NSThread alloc] initWithTarget:self selector:@selector(threadUpdateItemQty:) object:qtyObj] start];
    }
}

-(void)threadUpdateItemQty:(id)qty
{
    CGFloat updateQty = [qty floatValue];
    if (updateQty == 0) {
        [[Quote sharedQuote] removeItem:[self.item getId]];
    } else {
        [[Quote sharedQuote] updateItemQty:[self.item getId] qty:updateQty];
    }
}

#pragma mark - UINavigation controller delegate

#pragma mark - UIPopover controller Delegate
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    // Update Qty (if changed)
    NSIndexPath *qtyIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITextField *qtyText = (UITextField *)[[self.tableView cellForRowAtIndexPath:qtyIndexPath] viewWithTag:1];
    if ([qtyText.text floatValue] == 0) {
        // Remove Item
        [[[NSThread alloc] initWithTarget:self selector:@selector(threadUpdateItemQty:) object:qtyText.text] start];
    }
    if (self.isShowedQtyInput) {
        [[MSNumberPad keyboard] hidePad];
    }
    // Deselect Item Row
    [itemTableView deselectRowAtIndexPath:itemIndexPath animated:NO];
    return YES;
}

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Release Memory (Some ControllerViews)
}

@end
