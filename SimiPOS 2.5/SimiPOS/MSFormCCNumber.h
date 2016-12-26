//
//  MSFormCCNumber.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 9/22/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFormCCard.h"
#import "MSNumberPad.h"

@interface MSFormCCNumber : MSFormCCard <MSNumberPadDelegate>

@property (strong, nonatomic) MSNumberPad *keyboard;
@property (strong, nonatomic) UIPopoverController *optionsPopover;

@end
