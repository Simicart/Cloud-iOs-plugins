//
//  MSFormCvv.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 9/22/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFormAbstract.h"
#import "MSNumberPad.h"

@interface MSFormCvv : MSFormAbstract <UITextFieldDelegate, MSNumberPadDelegate>

@property (strong, nonatomic) UITextField *inputText;

@end
