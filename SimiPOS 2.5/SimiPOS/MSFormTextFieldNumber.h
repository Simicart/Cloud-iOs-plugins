//
//  MSFormTextFieldNumber.h
//  SimiPOS
//
//  Created by mac on 3/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSFormAbstract.h"
#import "MSNumberPad2.h"


@interface MSFormTextFieldNumber : MSFormAbstract<UITextFieldDelegate, MSNumberPad2Delegate>

@property (strong, nonatomic) UITextField *inputText;

@end
