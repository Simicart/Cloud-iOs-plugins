//
//  CustomDiscountViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/7/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CustomDiscountViewController.h"

#import "Quote.h"
#import "Price.h"
#import "Discount.h"

@interface CustomDiscountViewController ()
@property (strong, nonatomic) NSNumber *amount;
@property (nonatomic) CGFloat percentage;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) UIView *couponView, *centerView;

@end

@implementation CustomDiscountViewController{
    Permission * permission;
}
@synthesize inputType, couponCode;
@synthesize discountAmount, discountName, discountPercentage, discountType, keyboard, amountLabel;
@synthesize amount, percentage;
@synthesize animation;
@synthesize couponView, centerView;

int kDeltaPostionX =70;

-(void)createMenuNavigationBar{
//    UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
//    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
//    buttonCancel.layer.cornerRadius =3.0;
//    buttonCancel.backgroundColor =[UIColor buttonCancelColor];
//    [buttonCancel addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *leftButton =[[UIBarButtonItem alloc] initWithCustomView:buttonCancel];
//    self.navigationItem.leftBarButtonItem = leftButton;
//    
//    UIButton *rightbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
//    [rightbutton setTitle:@"Apply" forState:UIControlStateNormal];
//    rightbutton.backgroundColor =[UIColor buttonSubmitColor];
//    rightbutton.layer.cornerRadius =3.0;
//    [rightbutton addTarget:self action:@selector(addCustomDiscount:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:rightbutton];
//    self.navigationItem.rightBarButtonItem = rightBarButtonItem;

    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelEdit)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Apply", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addCustomDiscount:)];
    self.navigationItem.rightBarButtonItem = saveButton;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createMenuNavigationBar];
    
    permission =[Permission MR_findFirst];
    
    self.view.backgroundColor = [UIColor backgroundColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];    
    NSArray *allowDiscounts = [[NSArray alloc] init];
    
    if(permission.all_cart_discount.boolValue || permission.cart_custom_discount.boolValue){
        allowDiscounts = [[NSArray alloc ]initWithObjects:NSLocalizedString(@"Custom Discount", nil), nil];
    }
    if(permission.all_cart_discount.boolValue || permission.cart_coupon.boolValue){
        if(allowDiscounts.count == 0){
            allowDiscounts = [[NSArray alloc ]initWithObjects:NSLocalizedString(@"Coupon Code", nil), nil];
        }else{
            allowDiscounts = [allowDiscounts arrayByAddingObject:NSLocalizedString(@"Coupon Code", nil)];
        }
        
    }
    
    if(permission.all_cart_discount.boolValue || permission.cart_custom_discount.boolValue || permission.cart_coupon.boolValue){
        inputType = [[MSSegmentedControl alloc] initWithItems:allowDiscounts];
        inputType.frame = CGRectMake(15+kDeltaPostionX, 8, 366, 44);
        [self.view addSubview:inputType];
        [inputType addTarget:self action:@selector(toggleInputType:) forControlEvents:UIControlEventValueChanged];
        inputType.selectedSegmentIndex = 0;
    }
    
    if(permission.all_cart_discount.boolValue || permission.cart_coupon.boolValue){
        // Coupon View
        couponView = [[UIView alloc] initWithFrame:CGRectMake(10+kDeltaPostionX, 59, 386, 60)];
        [self.view addSubview:couponView];
        couponView.backgroundColor = [UIColor whiteColor];
        couponView.layer.borderColor = [UIColor colorWithWhite:0.97 alpha:1].CGColor;
        couponView.layer.borderWidth = 1.0;
        couponView.hidden = YES;
        if(!permission.cart_custom_discount.boolValue){
           couponView.hidden = NO;
        }
        
    }
    
    // Navigation Title
    self.title = @"Discount";//NSLocalizedString(@"Discount", nil);
    
    // Center view
    centerView = [[UIView alloc] initWithFrame:CGRectMake(10+kDeltaPostionX, 60, 376, 494)];
    [self.view addSubview:centerView];
    centerView.layer.borderColor = [UIColor colorWithWhite:0.97 alpha:1].CGColor;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 386, 60)];
    [centerView addSubview:view];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 17, 90, 30)];
    label.font = [UIFont systemFontOfSize:20];
    
    discountName = [[UITextField alloc] initWithFrame:CGRectMake(110, 17, 256, 30)];
    discountName.textAlignment = NSTextAlignmentRight;
    discountName.font = [UIFont systemFontOfSize:20];
    discountName.delegate = self;
    
    if(permission.all_cart_discount.boolValue || permission.cart_custom_discount.boolValue){
        // Custom discount description
        
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = centerView.layer.borderColor;
        view.layer.borderWidth = 1.0;
        
        label.text = NSLocalizedString(@"Name", nil);
        [view addSubview:label];
        [view addSubview:discountName];
        discountName.placeholder = NSLocalizedString(@"Custom Discount", nil);
        if ([[[Quote sharedQuote] objectForKey:@"webpos_discount_desc"] isKindOfClass:[NSString class]]) {
            discountName.text = [[Quote sharedQuote] objectForKey:@"webpos_discount_desc"];
        }
        // discount type
        CGRect frame = view.frame;
        frame.origin.y += 59;
        view = [[UIView alloc] initWithFrame:frame];
        [centerView addSubview:view];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = centerView.layer.borderColor;
        view.layer.borderWidth = 1.0;
        
        label = [label clone];
        label.frame = CGRectMake(20, 15, 220, 30);
        [view addSubview:label];
        label.text = NSLocalizedString(@"Discount Type", nil);
        
        discountType = [[MSSegmentedControl alloc] initWithItems:@[NSLocalizedString(@"$", nil), NSLocalizedString(@"%", nil)]];
        discountType.frame = CGRectMake(222, 9, 144, 44);
        [view addSubview:discountType];
        [discountType addTarget:self action:@selector(toggleDiscountType:) forControlEvents:UIControlEventValueChanged];
        
        // Discount Amount / Percentage
        frame.origin.y += 59;
        view = [[UIView alloc] initWithFrame:frame];
        [centerView addSubview:view];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.borderColor = centerView.layer.borderColor;
        view.layer.borderWidth = 1.0;
        
        label = [label clone];
        [view addSubview:label];
        
        discountAmount = [discountName clone];
        discountAmount.delegate = self;
        [view addSubview:discountAmount];
        discountAmount.font = [UIFont boldSystemFontOfSize:24];
        
        discountPercentage = [discountName clone];
        discountPercentage.delegate = self;
        [view addSubview:discountPercentage];
        discountPercentage.font = [UIFont boldSystemFontOfSize:24];
        
        // Price Keyboard
        frame.origin.y += 59;
        
        keyboard = [[MSNumberPad alloc] init];
        [keyboard resetConfig];
        keyboard.delegate = self;
        keyboard.doneLabel = @"00";
        [keyboard showOn:self atFrame:CGRectMake(0, 0, frame.size.width, 265)];
        keyboard.view.frame = CGRectMake(1, frame.origin.y, frame.size.width, 265);
        [centerView addSubview:keyboard.view];
        
        amount = [[Quote sharedQuote] objectForKey:@"webpos_discount_amount"];
        percentage = [[[Quote sharedQuote] objectForKey:@"webpos_discount_percent"] floatValue];
        if (percentage < 0.0001) {
            label.text = NSLocalizedString(@"Amount", nil);
            discountAmount.text = [Price format:amount];
            keyboard.maxInput = 13;
            keyboard.currentValue = [amount doubleValue];
            keyboard.floatPoints = [Price precision];
            keyboard.textField = discountAmount;
            [discountType setSelectedSegmentIndex:0];
            discountPercentage.hidden = YES;
        } else {
            label.text = NSLocalizedString(@"Percentage", nil);
            discountPercentage.text = [NSString stringWithFormat:@"%.2f%%", percentage];
            keyboard.maxInput = 5;
            keyboard.currentValue = percentage;
            keyboard.floatPoints = 2;
            keyboard.textField = discountPercentage;
            [discountType setSelectedSegmentIndex:1];
            discountAmount.hidden = YES;
        }
        amountLabel = label;
    }
    if(permission.all_cart_discount.boolValue || permission.cart_coupon.boolValue){
        // coupon code input
        label = [label clone];
        [couponView addSubview:label];
        label.text = NSLocalizedString(@"Coupon", nil);
        
        couponCode = [discountName clone];
        couponCode.delegate = self;
        [couponView addSubview:couponCode];
        couponCode.placeholder = NSLocalizedString(@"Coupon Code", nil);
        if ([[[Quote sharedQuote] objectForKey:@"coupon_code"] isKindOfClass:[NSString class]]) {
            couponCode.text = [[Quote sharedQuote] objectForKey:@"coupon_code"];
        }
        if(!permission.cart_custom_discount.boolValue){
            centerView.hidden = YES;
        }
    }
    
    
}

#pragma mark - update value action
- (IBAction)toggleInputType:(id)sender
{
    if ([inputType selectedSegmentIndex]) {
        centerView.hidden = YES;
        couponView.hidden = NO;
    } else {
        couponView.hidden = YES;
        centerView.hidden = NO;
    }
}

- (void)toggleDiscountType:(id)sender
{
    if ([discountType selectedSegmentIndex]) {
        // Backup Amount
        amount = [NSNumber numberWithDouble:keyboard.currentValue];
        // Change to Percentage
        amountLabel.text = @"Percentage";//NSLocalizedString(@"Percentage", nil);
        discountPercentage.text = [NSString stringWithFormat:@"%.2f%%", percentage];
        keyboard.maxInput = 5;
        keyboard.currentValue = percentage;
        keyboard.floatPoints = 2;
        keyboard.textField = discountPercentage;
        discountPercentage.hidden = NO;
        discountAmount.hidden = YES;
    } else {
        // Backup Percentage
        percentage = keyboard.currentValue;
        // Change to Amount
        amountLabel.text = @"Amount";//NSLocalizedString(@"Amount", nil);
        discountAmount.text = [Price format:amount];
        keyboard.maxInput = 13;
        keyboard.currentValue = [amount doubleValue];
        keyboard.floatPoints = [Price precision];
        keyboard.textField = discountAmount;
        discountAmount.hidden = NO;
        discountPercentage.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelEdit
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClosePopupWindow" object:nil];
    }];
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([discountName isEqual:textField] || [couponCode isEqual:textField]) {
        return YES;
    }
    [discountName resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - add discount
- (void)addCustomDiscount:(id)sender
{
    
    [self addCustomDiscountThread];
    
    [self cancelEdit];
    
    return;
}

- (void)addCustomDiscountThread
{
    permission =[Permission MR_findFirst];
    
    if ([inputType selectedSegmentIndex] || (!permission.cart_custom_discount.boolValue && permission.cart_coupon.boolValue)) {
        // set coupon code
         [[Quote sharedQuote] addDiscountOffline:@{@"name": @"Coupon Code", @"inputtype": @"coupon_code",@"price":@"0", @"couponcode": couponCode.text}];
        
    } else {
        // set custom discount
         [[Quote sharedQuote] addDiscountOffline:@{@"name": discountName.text, @"inputtype": @"custom_discount", @"price":[NSNumber numberWithDouble:keyboard.currentValue].stringValue,@"couponcode":@""}];
    }
    
}

#pragma mark - keyboard delegate
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
    if ([discountType selectedSegmentIndex]) {
        return [NSString stringWithFormat:@"%.2f%%", (CGFloat)numberPad.currentValue];
    }
    return [Price format:[NSNumber numberWithDouble:numberPad.currentValue]];
}

@end
