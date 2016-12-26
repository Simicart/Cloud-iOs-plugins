//
//  MSFormText.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormAbstract.h"

@interface MSFormText : MSFormAbstract <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *inputText;

- (BOOL)moveToNextInputText;
- (void)forcusInput;

@end