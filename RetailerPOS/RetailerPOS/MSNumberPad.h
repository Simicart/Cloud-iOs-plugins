//
//  MSNumberPad.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/8/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSBlueButton.h"
#import "MSGrayButton.h"

@class MSNumberPad;

// Number keypad delegate protocol
@protocol MSNumberPadDelegate <NSObject>
@optional
// Customize Delegate
-(void)numberPad:(MSNumberPad *)numberPad willShowButton:(UIButton *)button;
-(NSString *)numberPadFormatOutput:(MSNumberPad *)numberPad;
// Action Delegate
-(BOOL)numberPad:(MSNumberPad *)numberPad willChangeValue:(NSInteger)value;
-(void)numberPad:(MSNumberPad *)numberPad didChangeValue:(NSInteger)value;

-(BOOL)numberPad:(MSNumberPad *)numberPad willMaxInput:(NSInteger)value;
-(void)numberPad:(MSNumberPad *)numberPad didMaxInput:(NSInteger)value;

-(BOOL)numberPadShouldDone:(MSNumberPad *)numberPad;
-(void)numberPadDidDone:(MSNumberPad *)numberPad;
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
@interface MSNumberPad : UIViewController
+(MSNumberPad *)keyboard;

@property (weak, nonatomic) UITextField *textField;
@property (copy, nonatomic) NSString *outFormat, *doneLabel;
@property (nonatomic) long double currentValue;
@property (nonatomic) NSUInteger maxInput, floatPoints;
@property (nonatomic) CGFloat horizontalSpace, verticalSpace;
@property (nonatomic) BOOL isShowExtButton;

@property (weak, nonatomic) id <MSNumberPadDelegate> delegate;

-(void)resetConfig;
-(void)updateInputTextField;

// Selector Action
-(IBAction)numberButtonTapped:(UIButton *)sender;

// Show / hide numberPad on view controller
-(void)showOn:(UIViewController *)viewController atFrame:(CGRect)frame;
-(void)hidePad;

@end
