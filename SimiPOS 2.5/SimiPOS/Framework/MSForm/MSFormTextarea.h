//
//  MSFormTextarea.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormText.h"

@interface MSFormTextarea : MSFormText <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textInput;

@end
