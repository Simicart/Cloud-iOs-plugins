//
//  MSNumberPadString.m
//  SimiPOS
//
//  Created by Lionel on 6/14/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "MSNumberPadString.h"

@interface MSNumberPadString()
@property (nonatomic) BOOL isInitBasicButton;
@property (nonatomic) BOOL isInitExtendButton;

-(void)initBasicButtons;
-(void)initExtendButtons;

-(void)alignButtons;

@end

@implementation MSNumberPadString
@synthesize isInitBasicButton, isInitExtendButton;

@synthesize textField;
@synthesize doneLabel;
@synthesize maxInput;
@synthesize horizontalSpace, verticalSpace;
@synthesize isShowExtButton;
@synthesize delegate;

-(void)resetConfig
{
    self.textField = nil;
    self.doneLabel = NSLocalizedString(@"Done", nil);
    self.maxInput = 4;
    self.horizontalSpace = 7;
    self.verticalSpace = 5;
    self.isShowExtButton = NO;
    self.delegate = nil;
}

-(void)updateInputTextField
{
    if (self.textField == nil) {
        return;
    }
//    NSString *text;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(numberPadFormatOutput:)]) {
//        text = [self.delegate numberPadFormatOutput:self];
//    } else {
//        // Default format
//        text = [NSString stringWithFormat:self.outFormat, (CGFloat)self.currentValue];
//    }
    self.textField.text = self.stringValue;
}

#pragma mark - selector actions
-(IBAction)numberButtonTapped:(UIButton *)sender
{
    if (sender.tag == 13) { // Done
        BOOL allowDone = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(numberPadShouldDone:)]) {
            allowDone = [self.delegate numberPadShouldDone:self];
        }
        if (allowDone && self.delegate && [self.delegate respondsToSelector:@selector(numberPadDidDone:)]) {
            [self.delegate numberPadDidDone:self];
        }
        return;
    }
    BOOL allowChange = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberPad:willChangeValue:)]) {
        allowChange = [self.delegate numberPad:self willChangeValue:sender.tag];
    }
    if (!allowChange) {
        return;
    }
    // Change Value
    if (sender.tag == 11) { // Delete
//        self.currentValue /= 10;
//        if (self.floatPoints) {
//            long double power = powl(10, self.floatPoints);
//            self.currentValue = floorl(self.currentValue * power) / power;
//        } else {
//            self.currentValue = floorl(self.currentValue);
//        }
        self.stringValue = @"";
        [self updateInputTextField];
    }
    
    if (sender.tag < 10) { // Standard number
//        long double maxNumber = powl(10, self.maxInput - self.floatPoints - 1);
//        long double numberVal = sender.tag;
//        //        if (self.floatPoints) {
//        //            numberVal /= powl(10, self.floatPoints);
//        //        }
//        if (maxNumber <= self.currentValue) {
//            // Maximum input
//            BOOL allowMaxCut = YES;
//            if (self.delegate && [self.delegate respondsToSelector:@selector(numberPad:willMaxInput:)]) {
//                allowMaxCut = [self.delegate numberPad:self willMaxInput:sender.tag];
//            }
//            if (allowMaxCut) {
//                // Cut hightest number
//                long double heightVal = floorl(self.currentValue / maxNumber) * maxNumber;
//                self.currentValue -= heightVal;
//                long double power = powl(10, self.floatPoints);
//                self.currentValue = 10 * roundl(self.currentValue * power) + numberVal;
//                self.currentValue /= power;
//                //                self.currentValue = roundl(self.currentValue * power) / power;
//                //                self.currentValue = 10 * self.currentValue + numberVal;
//            }
//            if (self.delegate && [self.delegate respondsToSelector:@selector(numberPad:didMaxInput:)]) {
//                [self.delegate numberPad:self didMaxInput:sender.tag];
//            }
//        } else {
//            long double power = powl(10, self.floatPoints);
//            self.currentValue = 10 * roundl(self.currentValue * power) + numberVal;
//            self.currentValue /= power;
//            //            self.currentValue = 10 * self.currentValue + numberVal;
//        }
        NSString *tab = [NSString stringWithFormat:@"%ld", (long)sender.tag];
        if (self.stringValue.length < maxInput) {
            self.stringValue = [NSString stringWithFormat:@"%@%@", self.stringValue, tab];
        } else {
            
        }
        
        [self updateInputTextField];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberPad:didChangeValue:)]) {
        [self.delegate numberPad:self didChangeValue:sender.tag];
    }
}

#pragma mark - global keyboard input
+(MSNumberPadString *)keyboard
{
    static MSNumberPadString *keyboard = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyboard = [[self alloc] init];
    });
    return keyboard;
}

- (id)init
{
    if (self = [super init]) {
        self.isInitBasicButton = NO;
        self.isInitExtendButton = NO;
    }
    return self;
}

#pragma mark - show / hide number pad
-(void)showOn:(UIViewController *)viewController atFrame:(CGRect)frame
{
    // Init numberPad
    self.view.frame = frame;
    if (!self.isInitBasicButton) {
        [self initBasicButtons];
    }
    if (self.isShowExtButton && !self.isInitExtendButton) {
        [self initExtendButtons];
    }
    [self alignButtons];
    
    // Delegate prepare button to show
    if (self.delegate && [self.delegate respondsToSelector:@selector(numberPad:willShowButton:)]) {
        int total = 12;
        if (self.isShowExtButton) {
            total = 15;
        }
        for (int i = 0; i < total; i++) {
            [self.delegate numberPad:self willShowButton:(UIButton *)[[self.view subviews] objectAtIndex:i]];
        }
    }
    
    // Attach to view controller
    [viewController addChildViewController:self];
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
}

-(void)alignButtons
{
    CGFloat width = (self.view.frame.size.width - 4 * self.horizontalSpace) / 3;
    CGFloat height = (self.view.frame.size.height - 5 * self.verticalSpace) / 4;
    if (self.isShowExtButton) {
        height = (self.view.frame.size.height - 6 * self.verticalSpace) / 5;
    }
    CGFloat x = self.horizontalSpace;
    CGFloat y = self.verticalSpace;
    
    NSArray *buttons = [self.view subviews];
    if (self.isShowExtButton) {
        for (int i = 12; i < 15; i++) {
            UIButton *button = (UIButton *)[buttons objectAtIndex:i];
            button.hidden = NO;
            button.frame = CGRectMake(x, y, width, height);
            x += width + self.horizontalSpace;
        }
        x = self.horizontalSpace;
        y += height + self.verticalSpace;
    } else if (self.isInitExtendButton) {
        for (int i = 12; i < 15; i++) {
            UIButton *button = (UIButton *)[buttons objectAtIndex:i];
            button.hidden = YES;
        }
    }
    for (int i = 0; i < 12; ) {
        UIButton *button = (UIButton *)[buttons objectAtIndex:i];
        button.frame = CGRectMake(x, y, width, height);
        i++;
        if (i % 3) {
            x += width + self.horizontalSpace;
        } else {
            x = self.horizontalSpace;
            y += height + self.verticalSpace;
        }
    }
    UIButton *button = (UIButton *)[buttons objectAtIndex:11];
    [button setTitle:self.doneLabel forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
}

-(void)initBasicButtons
{
    for (int i = 1; i < 13; i++) {
        UIButton *button = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:28];
        if (i < 10) {
            button.tag = i;
            [button setTitle:[NSString stringWithFormat:@"%d", i] forState:UIControlStateNormal];
        } else if (i == 10) {
            button.tag = 11;
            [button setTitle:@"⌫" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        } else if (i == 11) {
            button.tag = 0;
            [button setTitle:@"0" forState:UIControlStateNormal];
        } else if (i == 12) {
            button.tag = 13;
        }
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget:self action:@selector(numberButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

-(void)initExtendButtons
{
    for (int i = 21; i < 24; i++) {
        UIButton *button = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = i;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:28];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button addTarget:self action:@selector(numberButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

-(void)hidePad
{
    if (self.parentViewController == nil) {
        return;
    }
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
