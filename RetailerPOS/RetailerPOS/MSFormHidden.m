//
//  MSFormHidden.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
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
