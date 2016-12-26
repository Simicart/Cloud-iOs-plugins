//
//  MSFormHidden.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormHidden.h"
#import "MSForm.h"

@implementation MSFormHidden
@synthesize hiddenValue;

- (void)reloadFieldData
{
    self.hiddenValue = [self.form.formData objectForKey:self.name];
}

@end
