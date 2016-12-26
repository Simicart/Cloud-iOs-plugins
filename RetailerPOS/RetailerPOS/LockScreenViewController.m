//
//  LockScreenViewController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/2016/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "LockScreenViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "UIView+I7ShakeAnimation.h"

#import "MagentoAccount.h"
#import "LoginFormViewController.h"

const float deltaPostionX =160;

@interface LockScreenViewController ()

@end

@implementation LockScreenViewController
@synthesize pinText, keyboard;

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(10+deltaPostionX, 15, 380, 24)];
    header.text = NSLocalizedString(@"Please enter your PIN code", nil);
    header.textAlignment = NSTextAlignmentCenter;
    header.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:header];
    
    pinText = [[MSTextField alloc] initWithFrame:CGRectMake(10+deltaPostionX, 45, 380, 36)];
    pinText.font = [UIFont boldSystemFontOfSize:36];
    pinText.textAlignment = NSTextAlignmentCenter;
    pinText.secureTextEntry = YES;
    pinText.delegate = self;
    [self.view addSubview:pinText];
    
    keyboard = [MSNumberPad new];
    [keyboard resetConfig];
    keyboard.delegate = self;
    keyboard.doneLabel = NSLocalizedString(@"Logout", nil);
    keyboard.textField = pinText;
    [keyboard showOn:self atFrame:CGRectMake(10, 100, 380, 265)];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0+deltaPostionX, 0, 400, 376)];
    [self.view addSubview:view];
    [view addSubview:keyboard.view];
    
    if (![[[Configuration globalConfig] objectForKey:@"locked"] boolValue]) {
        [[Configuration globalConfig] setValue:[NSNumber numberWithBool:YES] forKey:@"locked"];
    }
}

#pragma mark - text field delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

#pragma mark - number pad delegate
- (void)numberPad:(MSNumberPad *)numberPad willShowButton:(UIButton *)button
{
    if (button.tag == 13) {
        [button setImage:[UIImage imageNamed:@"icon_account_logout.png"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor barBackgroundColor] forState:UIControlStateNormal];
    }
}

- (BOOL)numberPad:(MSNumberPad *)numberPad willChangeValue:(NSInteger)value
{
    NSString *text = numberPad.textField.text;
    if (value == 11) { // Delete
        if (text && [text length]) {
            text = [text substringToIndex:([text length] - 1)];
            if (text == nil) {
                text = @"";
            }
            numberPad.textField.text = text;
        }
    } else {
        if (text == nil) {
            text = @"";
        }
        if ([text length] < 4) {
            text = [NSString stringWithFormat:@"%@%d", text,(int)value];
            numberPad.textField.text = text;
        }
        if ([text length] == 4) {
            NSString *pin = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_GENERAL_PIN];
            if (pin == nil) {
                pin = @"0000";
            }
            if ([text isEqualToString:pin]) {
                
                //pin is ok
                [self pinValidate];
                
            } else {
                numberPad.textField.text = @"";
                // Shake view controller
                [self.view shakeX];
            }
        }
    }
    return NO;
}

- (BOOL)numberPadShouldDone:(MSNumberPad *)numberPad
{
    // Logout to system
    [(MagentoAccount *)[[Account currentAccount] getResource] logout];
    [self dismissViewControllerAnimated:NO completion:nil];    
    return NO;
}

-(void)pinValidate{
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.parrentVC dismissViewControllerAnimated:NO completion:nil];
}
@end
