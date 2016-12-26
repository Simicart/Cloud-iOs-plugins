//
//  MSFormTextarea.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormText.h"

@interface MSFormTextarea : MSFormText <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textInput;

@end
