//
//  MSNumberPadString.h
//  SimiPOS
//
//  Created by Lionel on 6/14/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSBlueButton.h"
#import "MSGrayButton.h"

@class MSNumberPadString;

// Number keypad delegate protocol
@protocol MSNumberPadStringDelegate <NSObject>
@optional
// Customize Delegate
-(void)numberPad:(MSNumberPadString *)numberPad willShowButton:(UIButton *)button;
-(NSString *)numberPadFormatOutput:(MSNumberPadString *)numberPad;
// Action Delegate
-(BOOL)numberPad:(MSNumberPadString *)numberPad willChangeValue:(NSInteger)value;
-(void)numberPad:(MSNumberPadString *)numberPad didChangeValue:(NSInteger)value;

-(BOOL)numberPad:(MSNumberPadString *)numberPad willMaxInput:(NSInteger)value;
-(void)numberPad:(MSNumberPadString *)numberPad didMaxInput:(NSInteger)value;

-(BOOL)numberPadShouldDone:(MSNumberPadString *)numberPad;
-(void)numberPadDidDone:(MSNumberPadString *)numberPad;
@end

// Number keypad class
/*________________________________________
 21      22      23 // External buttons
 ________________________
 1       2       3
 4       5       6
 7       8       9
 ________   _____________
 11(DEL)| 0 |   13(Enter)
 __________________________________________
 */
@interface MSNumberPadString : UIViewController
+(MSNumberPadString *)keyboard;

@property (weak, nonatomic) UITextField *textField;
@property (copy, nonatomic) NSString *doneLabel;
@property (nonatomic) NSString *stringValue;
@property (nonatomic) NSUInteger maxInput;
@property (nonatomic) CGFloat horizontalSpace, verticalSpace;
@property (nonatomic) BOOL isShowExtButton;

@property (weak, nonatomic) id <MSNumberPadStringDelegate> delegate;

-(void)resetConfig;
-(void)updateInputTextField;

// Selector Action
-(IBAction)numberButtonTapped:(UIButton *)sender;

// Show / hide numberPad on view controller
-(void)showOn:(UIViewController *)viewController atFrame:(CGRect)frame;
-(void)hidePad;

@end
