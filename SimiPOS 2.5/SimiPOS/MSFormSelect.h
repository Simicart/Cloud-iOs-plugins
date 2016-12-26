//
//  MSFormSelect.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormAbstract.h"

@interface MSFormSelect : MSFormAbstract <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *inputText;

@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) UIPopoverController *optionsPopover;

- (void)updateSelectInput:(NSArray *)selected;

@end
