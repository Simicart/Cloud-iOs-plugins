//
//  MSFormText.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormAbstract.h"

@interface MSFormText : MSFormAbstract <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *inputText;

- (BOOL)moveToNextInputText;
- (void)forcusInput;

@end
