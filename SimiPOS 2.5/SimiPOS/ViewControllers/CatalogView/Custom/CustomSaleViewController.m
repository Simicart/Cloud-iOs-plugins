//
//  CustomSaleViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/7/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIView+InputNotification.h"
#import "MSBlueButton.h"
#import "Price.h"
#import "Quote.h"
#import "UIColor+SimiPOS.h"

#import "CustomSaleViewController.h"
#import "ProductViewController.h"

@interface CustomSaleViewController ()

@end

@implementation CustomSaleViewController
@synthesize productName, productPrice, keyboard, productShipping, productAdd;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Navigation button
    //self.view.frame = CGRectMake(0, 0, 586, 620);
    self.view.frame  = CGRectMake(0, 0, WINDOW_WIDTH-427, WINDOW_HEIGHT-100);
    
    
    self.view.backgroundColor = [UIColor backgroundColor];
    
    // Center View
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake((WINDOW_WIDTH - 427 - 386) / 2, (WINDOW_HEIGHT-100 - 520) / 2, 386, 520)];
    [self.view addSubview:centerView];
    centerView.layer.borderColor = [UIColor colorWithWhite:0.88 alpha:1].CGColor;
    centerView.layer.borderWidth = 1.0;
    
    // Product Name
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 386, 60)];
    [centerView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = centerView.layer.borderColor;
    view.layer.borderWidth = 1.0;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 17, 90, 30)];
    label.font = [UIFont systemFontOfSize:24];
    label.text = NSLocalizedString(@"Name", nil);
    [view addSubview:label];
    
    productName = [[UITextField alloc] initWithFrame:CGRectMake(110, 17, 256, 30)];
    productName.textAlignment = NSTextAlignmentRight;
    productName.font = [UIFont systemFontOfSize:24];
    productName.delegate = self;
    [view addSubview:productName];
    productName.placeholder = NSLocalizedString(@"Custom Sale", nil);
    
    // Product shipping
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
    label.text = NSLocalizedString(@"Shippable", nil);
    
    productShipping = [[UISwitch alloc] initWithFrame:CGRectMake(296, 16, 80, 30)];
    [view addSubview:productShipping];
    
    // Product Price
    frame.origin.y += 59;
    view = [[UIView alloc] initWithFrame:frame];
    [centerView addSubview:view];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderColor = centerView.layer.borderColor;
    view.layer.borderWidth = 1.0;
    
    label = [label clone];
    [view addSubview:label];
    label.text = NSLocalizedString(@"Price", nil);
    
    productPrice = [productName clone];
    productPrice.delegate = self;
    [view addSubview:productPrice];
    productPrice.font = [UIFont boldSystemFontOfSize:24];
    productPrice.text = [Price format:[NSNumber numberWithInt:0]];
    
    // Price Keyboard
    frame.origin.y += 59;
    
    keyboard = [[MSNumberPad alloc] init];
    [keyboard resetConfig];
    keyboard.delegate = self;
    keyboard.doneLabel = @"00";
    keyboard.floatPoints = [Price precision];
    keyboard.maxInput = 13;
    keyboard.currentValue = 0;
    keyboard.textField = productPrice;
    if(WINDOW_WIDTH > 1024){
        [keyboard showOn:self atFrame:CGRectMake((WINDOW_WIDTH - 427 - 386) / 2, frame.origin.y + 195, frame.size.width, 265)];
    }else{
        [keyboard showOn:self atFrame:CGRectMake((WINDOW_WIDTH - 427 - 386) / 2, frame.origin.y + 65, frame.size.width, 265)];
    }
    
    // Product Add To Cart
    frame.origin.y += 270;
    productAdd = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    productAdd.frame = CGRectMake(7, frame.origin.y, frame.size.width - 14, 65);
    [centerView addSubview:productAdd];
    productAdd.titleLabel.font = [UIFont boldSystemFontOfSize:24];
    [productAdd setTitle:NSLocalizedString(@"Add to Cart", nil) forState:UIControlStateNormal];
    [productAdd addTarget:self action:@selector(addProductToCart:) forControlEvents:UIControlEventTouchUpInside];
    [productAdd setEnabled:NO];
}

- (void)addProductToCart:(id)sender
{
    // Add Product to cart
    [[[NSThread alloc] initWithTarget:self selector:@selector(addToCartThread) object:nil] start];
    // Hide custom sale form
    [(ProductViewController *)self.parentViewController customSale:self];
}

-(void)addToCartThread
{
    NSNumber *isVirtual = [NSNumber numberWithBool:!productShipping.on];
    NSNumber *price = [NSNumber numberWithDouble:keyboard.currentValue];
    if (productName.text) {
        [[Quote sharedQuote] addCustomSale:@{@"name": productName.text, @"is_virtual": isVirtual, @"price": price}];
    } else {
        [[Quote sharedQuote] addCustomSale:@{@"is_virtual": isVirtual, @"price": price}];
    }
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([productName isEqual:textField]) {
        return YES;
    }
    [productName resignFirstResponder];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
    return [Price format:[NSNumber numberWithDouble:numberPad.currentValue]];
}

- (void)numberPad:(MSNumberPad *)numberPad didChangeValue:(NSInteger)value
{
    if (numberPad.currentValue > 0) {
        [productAdd setEnabled:YES];
    } else {
        [productAdd setEnabled:NO];
    }
}

@end
