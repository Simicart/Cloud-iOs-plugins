//
//  PartialRefundViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 4/25/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "Price.h"
#import "Configuration.h"
#import "Payanywhere.h"
#import "Invoice.h"
#import "PartialRefundViewController.h"
#import "M13Checkbox.h"
#import "RefundOrderModel.h"

@interface PartialRefundViewController ()
@property (nonatomic) BOOL isOnlineRefund;
@property (strong, nonatomic) UILabel *totalRefund;
@property (strong, nonatomic) MSNumberPad *keyboard;
@property (strong, nonatomic) UIPopoverController *popover;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableDictionary *formData;
@property (strong, nonatomic) NSMutableArray *lineKeys;
@property (strong, nonatomic) NSDictionary * oldQtyValues;
@property (strong, nonatomic) UIBarButtonItem *refundButtonItem;
@property (strong, nonatomic) MSTextField *qty;

- (void)changeSwitch:(UISwitch *)sender;
@property (strong, nonatomic) id root;
@end

@implementation PartialRefundViewController{
    // Johan
    RefundOrderModel *refundOrderModel;
    // End
}
@synthesize isOnlineRefund;
@synthesize totalRefund, keyboard, popover;
@synthesize animation, scrollView, formData, lineKeys;
@synthesize order = _order, editViewController;
@synthesize root;
@synthesize refundButtonItem;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navigation buttons
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelRefund)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Refund for Order # %@", nil), [self.order getIncrementId]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    refundButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Refund", nil) style:UIBarButtonItemStyleDone target:self action:@selector(refundOnline)];
    self.navigationItem.rightBarButtonItem = refundButtonItem ;
    
    
    // Update main view
    self.view.backgroundColor = [UIColor whiteColor];
  //   self.view.bounds = CGRectMake(0, 0, 757, 300);
   self.view.frame = CGRectMake(0, 0, 1000, 500);
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(12, 0, self.view.frame.size.width, 702)];
    [self.view addSubview:scrollView];
    [self showOrderItemsDetail];

    
    //Luu lai gia tri cu de so sanh validate khi input new value
    self.oldQtyValues = [[formData objectForKey:@"qtys"] copy];
}

- (void)keyboardWillShow
{
    scrollView.frame = CGRectMake(12, 0, 757, 353);
}

- (void)keyboardWillHide
{
    scrollView.frame = CGRectMake(12, 0, 757, 702);
}

#pragma mark - view order item detail
- (void)showOrderItemsDetail
{
    formData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSMutableDictionary new], @"qtys", [NSMutableDictionary new], @"stocks", nil];
    lineKeys = [NSMutableArray new];
    CGFloat height = 20;
    // Order Item
    [self drawItemHeader:scrollView height:&height];
    NSArray *items = [[self.order objectForKey:@"details"] objectForKey:@"items"];
    for (NSArray *item in items) {
        if ([item count] < 9 || ![[item objectAtIndex:8] boolValue]) {
            continue;
        }
        [self drawOrderItem:item onPage:scrollView height:&height];
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, height-5, self.view.frame.size.width, 1)];
        separator.backgroundColor = [UIColor backgroundColor];
        [scrollView addSubview:separator];
    }
   
    height += 10;
    // Credit Memo Comment
    UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height, 370, 30)];
    commentLabel.font =  [UIFont boldSystemFontOfSize:16];//[UIFont italicSystemFontOfSize:16];
    commentLabel.text = NSLocalizedString(@"Credit Memo Comments", nil);
    [scrollView addSubview:commentLabel];
    
    
    UITextView *comment = [[UITextView alloc] initWithFrame:CGRectMake(0, height + 30, 370, 75)];
    comment.font = [UIFont systemFontOfSize:16];
    [comment.layer setBorderColor:[UIColor backgroundColor].CGColor];
    [comment.layer setBorderWidth:1.0];
    comment.delegate = self;
    [scrollView addSubview:comment];
    
    // Totals
    NSUInteger tag = 100001;
    CGFloat totalHeight = 15;
    for (NSString *total in @[NSLocalizedString(@"Adjustment Refund", nil), NSLocalizedString(@"Adjustment Fee", nil)]) {
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(384, height + totalHeight, 216, 24)];
        totalLabel.text = total;
        totalLabel.font = [UIFont boldSystemFontOfSize:16];
        totalLabel.textAlignment = NSTextAlignmentRight;
        [scrollView addSubview:totalLabel];
        
        MSTextField *totalInput = [[MSTextField alloc] initWithFrame:CGRectMake(605, height + totalHeight - 3, 140, 30)];
        totalInput.font = [UIFont boldSystemFontOfSize:16];
        totalInput.textAlignment = NSTextAlignmentRight;
        totalInput.text = [Price format:[NSNumber numberWithInt:0]];
        totalInput.tag = tag;
        totalInput.textPadding = UIEdgeInsetsMake(5, 5, 5, 5);
        totalInput.delegate = self;
        totalInput.layer.borderColor = [UIColor backgroundColor].CGColor;
        totalInput.layer.borderWidth = 1.0;
        [scrollView addSubview:totalInput];
        tag++;
        totalHeight += 36;
    }
    
    height += MAX(120, 0);
    // Content Size
    scrollView.contentSize = CGSizeMake(757, height);
}

- (void)drawItemHeader:(UIView *)page height:(CGFloat *)height
{
    NSArray *headerData = [[self.order objectForKey:@"details"] objectForKey:@"items_header"];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, *height-1, 745, 24)];
    [header setBackgroundColor:[UIColor backgroundColor]];
    [header.layer setBorderColor:[UIColor lightBorderColor].CGColor];
    [header.layer setBorderWidth:1.0];
    [page addSubview:header];
    *height += 27;
    
    // Each Label
    CGFloat start = 12;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(start, 2, 274, 20)];
    headerLabel.backgroundColor = [UIColor backgroundColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    
    // Products & SKU
    headerLabel.text = [headerData objectAtIndex:0];
    [header addSubview:headerLabel];
    start += 286;
    
    // Price
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:3];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.frame = CGRectMake(start, 2, 138, 20);
    headerLabel.backgroundColor =[UIColor clearColor];
    [header addSubview:headerLabel];
    start += 138;
    
    // Return to Stock
    headerLabel = [headerLabel clone];
    headerLabel.text = NSLocalizedString(@"Return to Stock", nil);
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.frame = CGRectMake(start-5, 2, 130, 20);
    [header addSubview:headerLabel];
    start += 110;
    
    // Qty
    headerLabel = [headerLabel clone];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.backgroundColor =[UIColor clearColor];
    headerLabel.text = [headerData objectAtIndex:2];
    headerLabel.frame = CGRectMake(start, 2, 80, 20);
    [header addSubview:headerLabel];
    start += 80;
    
    // Subtotal
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:5];
    headerLabel.backgroundColor =[UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentRight;
    headerLabel.frame = CGRectMake(start, 2, 108, 20);
    [header addSubview:headerLabel];
}

- (void)drawOrderItem:(NSArray *)item onPage:(UIView *)page height:(CGFloat *)height
{
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(7, *height, self.view.frame.size.width, 16)];
    [page addSubview:itemView];
    CGFloat x = 0, y = 0;
    
    // Product Name
    NSDictionary *productName = [item objectAtIndex:0];
    CGFloat delta = -7;
    if ([productName objectForKey:@"name"]) {
        delta = 0;
        UITextView *name = [[UITextView alloc] initWithFrame:CGRectMake(x, y, 298, 10)];
        name.text = [productName objectForKey:@"name"];
        name.font = [UIFont boldSystemFontOfSize:15];
        [name setEditable:NO];
        name.backgroundColor =[UIColor clearColor];
        [itemView addSubview:name];
        
        CGFloat width =CGRectGetWidth(name.frame);
        CGSize newSize =[name sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        CGRect newFrame =name.frame;
        newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
        name.frame=newFrame;
        
        y += newSize.height;
        if (![MSValidator isEmptyString:[item objectAtIndex:1]]) {
            UITextView *sku = [name clone];
            sku.font = [UIFont systemFontOfSize:15];
            sku.text = [NSString stringWithFormat:@"SKU: %@", [item objectAtIndex:1]];
            sku.backgroundColor =[UIColor clearColor];
            [itemView addSubview:sku];
            
             width =CGRectGetWidth(sku.frame);
             newSize =[sku sizeThatFits:CGSizeMake(width, MAXFLOAT)];
             sku.frame = CGRectMake(x, y-7, 298, newSize.height);
            
            y += newSize.height;
        }
    }
    x += 12;
    if ([productName objectForKey:@"options"]) {
        NSArray *options = [productName objectForKey:@"options"];
        for (NSDictionary *option in options) {
            // Title
            if ([option objectForKey:@"title"]) {
                UITextView *title = [[UITextView alloc] initWithFrame:CGRectMake(0, y-7, 286, 9)];
                title.text = [option objectForKey:@"title"];
                title.font = [UIFont italicSystemFontOfSize:15];
                [title setEditable:NO];
                title.backgroundColor =[UIColor clearColor];
                [itemView addSubview:title];
                //title.frame = CGRectMake(0, y-7, 286, title.contentSize.height);
               
                CGFloat width =CGRectGetWidth(title.frame);
                CGSize newSize =[title sizeThatFits:CGSizeMake(width, MAXFLOAT)];
                CGRect newFrame =title.frame;
                newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
                title.frame=newFrame;
                
                y += newSize.height - 7;
            }
            // Value
            if ([option objectForKey:@"value"]) {
                UITextView *value = [[UITextView alloc] initWithFrame:CGRectMake(x, y-7, 274, 9)];
                value.text = [[option objectForKey:@"value"] componentsJoinedByString:@"\n"];
                value.font = [UIFont systemFontOfSize:15];
                [value setEditable:NO];
                value.backgroundColor =[UIColor clearColor];
                [itemView addSubview:value];
               
                //value.frame = CGRectMake(x, y-7, 274, value.contentSize.height);
                CGFloat width =CGRectGetWidth(value.frame);
                CGSize newSize =[value sizeThatFits:CGSizeMake(width, MAXFLOAT)];
                CGRect newFrame =value.frame;
                newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
                value.frame=newFrame;
                y += newSize.height - 7;
            }
        }
        y += 7;
    }
    
    if ([MSValidator isEmptyString:[item objectAtIndex:6]]) {
        itemView.frame = CGRectMake(7, *height, self.view.frame.size.width, y);
        *height += y;
        return;
    }
    x += 274;
    
    // Price
    UITextView *content = [[UITextView alloc] initWithFrame:CGRectMake(x, delta, 138, 9)];
    [content setEditable:NO];
    content.backgroundColor =[UIColor clearColor];
    content.textAlignment = NSTextAlignmentCenter;
    content.font = [UIFont boldSystemFontOfSize:15];
    content.text = [[item objectAtIndex:3] componentsJoinedByString:@"\n"];
    [itemView addSubview:content];
    
    //content.frame = CGRectMake(x, delta, 138, content.contentSize.height);
   
    CGFloat width =CGRectGetWidth(content.frame);
    CGSize newSize =[content sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    CGRect newFrame =content.frame;
    newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
    content.frame=newFrame;
    
    
    x += 138;
    if (y < newSize.height) {
        y = newSize.height;
    }
    
    NSMutableDictionary *itemQtys = [formData objectForKey:@"qtys"];
    [lineKeys addObject:[item objectAtIndex:6]];
    // Return to Stock
//    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(x+20, delta + 5, 51, 31)];
//    [switcher addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    M13Checkbox *switcher = [[M13Checkbox alloc] initWithFrame:CGRectMake(x+47, delta + 5, 24, 24)];
    switcher.strokeColor = [UIColor grayColor];
    [switcher addTarget:self action:@selector(changeCheckbox:) forControlEvents:UIControlEventValueChanged];
    switcher.tag = [lineKeys count];
    [itemView addSubview:switcher];
    if (y < 36) {
        y = 36;
    }
    x += 110;
    
    //chiennd
    // Qty
    self.qty = [[MSTextField alloc] initWithFrame:CGRectMake(x+15, delta + 5, 60, 30)];
    self.qty.textPadding = UIEdgeInsetsMake(5, 5, 5, 5);
    self.qty.keyboardType =UIKeyboardTypeNumberPad;
    
    self.qty.tag = switcher.tag;
    self.qty.font = [UIFont boldSystemFontOfSize:16];
    self.qty.textAlignment = NSTextAlignmentRight;
    self.qty.text = [[item objectAtIndex:7] stringValue];
    self.qty.delegate = self;
    self.qty.layer.borderColor = [UIColor backgroundColor].CGColor;
    self.qty.layer.borderWidth = 1.0;
    [itemView addSubview:self.qty];
    x += 80;
    
    // Update Items Values
    [itemQtys setValue:[item objectAtIndex:7] forKey:[item objectAtIndex:6]];
    
    // Subtotal
    content = [content clone];
    content.textAlignment = NSTextAlignmentRight;
    content.backgroundColor =[UIColor clearColor];
    content.frame = CGRectMake(x, delta, 119, 9);
    content.text = [[item objectAtIndex:5] componentsJoinedByString:@"\n"];
    [itemView addSubview:content];
    
    //content.frame = CGRectMake(x, delta, 119, content.contentSize.height);
    
     width =CGRectGetWidth(content.frame);
     newSize =[content sizeThatFits:CGSizeMake(width, MAXFLOAT)];
     newFrame =content.frame;
     newFrame.size =CGSizeMake(fmaxf(width, newSize.width), newSize.height);
     content.frame=newFrame;
    
    x += 119;
    if (y < newSize.height) {
        y = newSize.height;
    }
    
    itemView.frame = CGRectMake(7, *height, 598, y);

    *height += y;
}

#pragma mark - cancel refund form
- (void)cancelRefund
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - switch return to stock
- (void)changeSwitch:(UISwitch *)sender
{
    NSMutableDictionary *stockData = [formData objectForKey:@"stocks"];
    NSString *key = [lineKeys objectAtIndex:sender.tag - 1];
    if ([sender isOn]) {
        [stockData setValue:[NSNumber numberWithBool:YES] forKey:key];
    } else {
        [stockData removeObjectForKey:key];
    }
}

- (void)changeCheckbox:(M13Checkbox *)checkbox
{
    NSMutableDictionary *stockData = [formData objectForKey:@"stocks"];
    NSString *key = [lineKeys objectAtIndex:checkbox.tag - 1];
    if (checkbox.checkState == M13CheckboxStateChecked) {
        [stockData setValue:[NSNumber numberWithBool:YES] forKey:key];
    } else {
        [stockData removeObjectForKey:key];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([MSValidator isEmptyString:textView.text]) {
        [formData removeObjectForKey:@"comment_text"];
    } else {
        [formData setValue:textView.text forKey:@"comment_text"];
    }
}

#pragma mark - edit adjusment
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    if (textField.tag < 10000){
//        return YES;
//    }
//    
    if (keyboard == nil) {
        keyboard = [MSNumberPad keyboard];
        [keyboard resetConfig];
        keyboard.delegate = self;
        keyboard.doneLabel = @"00";
        [keyboard showOn:self atFrame:CGRectMake(0, 0, 288, 241)];
        [keyboard willMoveToParentViewController:nil];
        [keyboard.view removeFromSuperview];
        [keyboard removeFromParentViewController];
    }
    keyboard.textField = textField;
    
    if (textField.tag < 10000) {
        keyboard.floatPoints = 0;
        keyboard.maxInput = 5;
        keyboard.currentValue = [textField.text doubleValue];
    } else {
        keyboard.floatPoints = [Price precision];
        keyboard.maxInput = 13;
    }
    
    if (textField.tag == 100001) {
        // Adjustment refund
        keyboard.currentValue = [[formData objectForKey:@"adjustment_positive"] doubleValue];
    } else if (textField.tag == 100002) {
        // Adjustment fee
        keyboard.currentValue = [[formData objectForKey:@"adjustment_negative"] doubleValue];
    }
    if (popover == nil) {
        popover = [[UIPopoverController alloc] initWithContentViewController:keyboard];
        popover.popoverContentSize = CGSizeMake(288, 241);
    }
    [popover presentPopoverFromRect:textField.frame inView:textField.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    return NO;
}


-(BOOL)numberPad:(MSNumberPad *)numberPad willChangeValue:(NSInteger)value{
    
    if (numberPad.textField.tag < 10000) {
        
        if(value ==11 ) //delete
        {
            if(numberPad.textField.text.length == 1){
                self.refundButtonItem.enabled = NO;
            }
            return YES;
        }
        
        NSNumber *qtyValue =[self.oldQtyValues objectForKey:[lineKeys objectAtIndex:numberPad.textField.tag - 1]];
        int currentValue =[NSString stringWithFormat:@"%.0Lf%d",numberPad.currentValue,(int)value].intValue;
       // DLog(@"qty:%d  currentValue:%d",qtyValue.intValue,currentValue);
        if(currentValue> qtyValue.intValue || currentValue == 0){
            self.refundButtonItem.enabled=NO;
            return NO;
            
        }else{
             self.refundButtonItem.enabled=YES;
        }
    }
    
    return YES;
}

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
    if (numberPad.textField.tag < 10000) {
      NSMutableDictionary *itemQtys = [formData objectForKey:@"qtys"];
      [itemQtys setValue:[NSNumber numberWithDouble:numberPad.currentValue] forKey:[lineKeys objectAtIndex:numberPad.textField.tag - 1]];
        return [NSString stringWithFormat:@"%.0Lf", numberPad.currentValue];
    }
    if (numberPad.textField.tag == 100001) {
        [formData setValue:[NSNumber numberWithDouble:numberPad.currentValue] forKey:@"adjustment_positive"];
    } else if (numberPad.textField.tag == 100002) {
        [formData setValue:[NSNumber numberWithDouble:numberPad.currentValue] forKey:@"adjustment_negative"];
    }
    
    return [Price format:[NSNumber numberWithDouble:numberPad.currentValue]];
}

#pragma mark - refund order methods
- (void)refundOffline
{
    isOnlineRefund = NO;
    [self confirmRefund];
}

- (void)refundOnline
{
    isOnlineRefund = YES;
    [self confirmRefund];
}

- (void)confirmRefund
{
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to refund this order?", nil) delegate:self cancelButtonTitle:@"" destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [confirm showInView:self.view];
}

/*
- (void)showPayAnywhereSDK
{
    Payanywhere *merchant = (Payanywhere *)[Configuration getSingleton:@"Payanywhere"];
    if (![merchant objectForKey:@"merchant_id"]) {
        [merchant load:nil];
    }
    if (![merchant objectForKey:@"merchant_id"] || ![merchant objectForKey:@"login_id"]
        || ![merchant objectForKey:@"user_name"] || ![merchant objectForKey:@"password"]
        ) {
        [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:NSLocalizedString(@"Invalid payment configuration. Please check your settings on your store backend.", nil)];
        return;
    }
    // Basic Information
    [[PATransactionHandler dataHolder] setDelegate:self];
    [[PATransactionHandler dataHolder] setMerchantId:[merchant objectForKey:@"merchant_id"]];
    [[PATransactionHandler dataHolder] setLoginId:[merchant objectForKey:@"login_id"]];
    [[PATransactionHandler dataHolder] setUserName:[merchant objectForKey:@"user_name"]];
    [[PATransactionHandler dataHolder] setPassWord:[merchant objectForKey:@"password"]];
    [[PATransactionHandler dataHolder] setAppName:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]];
    

    [[PATransactionHandler dataHolder] setSupportedOrientations:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft], [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight], nil]];
    
    // Configuration
    [[PATransactionHandler dataHolder] setTransactionType:RefundTransaction];
    [[PATransactionHandler dataHolder] setIsEmailOn:NO];
    [[PATransactionHandler dataHolder] setIsSignatureOn:YES];
    [[PATransactionHandler dataHolder] setIsSignatureRequired:NO];
    
    // Amount and Invoice ID
    [[PATransactionHandler dataHolder] setAmount:[NSString stringWithFormat:@"%f", [[self.order objectForKey:@"total_paid"] doubleValue] - [[self.order objectForKey:@"total_refunded"] doubleValue]]];
    [[PATransactionHandler dataHolder] setInvoice:[self.order objectForKey:@"invoice_id"]];
    
    [[PATransactionHandler dataHolder] submit];
}

 */

- (void)transactionResults:(id)response
{
    if ([[response objectForKey:@"Transaction status"] isEqualToString:@"Approved"]) {
        // Refund order
        [self refundOrder];
    }
    // [self cancelRefund];
    if (![[[UIApplication sharedApplication].keyWindow subviews] count]) {
        [[UIApplication sharedApplication].keyWindow addSubview:[(UIViewController *)root view]];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        if ([[self.order objectForKey:@"payment_method"] isEqualToString:@"payanywhere"]) {
            [self cancelRefund];
            root = [UIApplication sharedApplication].keyWindow.rootViewController;
           // [self showPayAnywhereSDK];
        } else {
            [self refundOrder];
        }
    }
}

- (void)refundOrder
{
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = self.view.superview.bounds;
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.view.superview addSubview:animation];
    }
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(refundOrderThread) object:nil] start];
}

- (void)refundOrderThread
{
    // Johan
    refundOrderModel = [RefundOrderModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRefundOrder:) name:@"DidRefundOrder" object:refundOrderModel];
    [refundOrderModel refundOrder:[self.order getIncrementId] WithForms:formData];
    // End
}

// Johan
- (void) didRefundOrder:(NSNotification *) noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidRefundOrder" object:refundOrderModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    [animation stopAnimating];
    if([respone.status isEqualToString:@"SUCCESS"]){
        [self performSelectorOnMainThread:@selector(cancelRefund) withObject:nil waitUntilDone:NO];
        // Reload order data
        
        [Utilities toastSuccessTitle:@"Order" withMessage:MESSAGE_REFUND_SUCCESS withView:self.editViewController.view];
        
        [self.editViewController loadOrder];
    }else{
        NSString * message = [NSString stringWithFormat:@"%@",[respone.message objectAtIndex:0]];
        if(message){
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:message];
        }
    }
}
// End

@end
