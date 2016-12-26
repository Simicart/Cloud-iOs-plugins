//
//  MSFormCCard.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormCCard.h"
#import "MSForm.h"

@implementation MSFormCCard
@synthesize ccNumber;

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        [self.inputText addTarget:self action:@selector(changeInputCard) forControlEvents:UIControlEventEditingChanged];
        [self.inputText setKeyboardType:UIKeyboardTypeNumberPad];
    }
    return self;
}

- (void)reloadFieldData
{
    if (self.ccNumber == nil) {
        [super reloadFieldData];
    } else {
        self.inputText.text = self.ccNumber;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.ccNumber == nil) {
        [super textFieldDidEndEditing:textField];
    }
}

- (void)addCCNumberMask:(NSString *)aString
{
    if (aString.length < 5) {
        return;
    }
    NSString *mask = [aString substringToIndex:1];
    for (NSUInteger i = 1; i < aString.length - 4; i++) {
        mask = [mask stringByAppendingString:@"x"];
    }
    self.ccNumber = [mask stringByAppendingString:[aString substringFromIndex:aString.length - 4]];
}

- (void)changeInputCard
{
    if (self.ccNumber == nil) {
        return;
    }
    if (self.inputText.text.length > self.ccNumber.length) {
        self.inputText.text = [self.inputText.text substringFromIndex:self.ccNumber.length];
    } else {
        self.inputText.text = nil;
    }
    self.ccNumber = nil;
}

@end
