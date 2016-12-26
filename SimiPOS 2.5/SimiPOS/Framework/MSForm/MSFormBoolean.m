//
//  MSFormBoolean.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormBoolean.h"
#import "MSForm.h"

@implementation MSFormBoolean
@synthesize switcher;

#pragma mark - abstract methods
- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        self.switcher = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
        [self.switcher addTarget:self action:@selector(changeSwitcher) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)reloadField:(UITableViewCell *)cell
{
    cell.accessoryView = self.switcher;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = self.title;
}

- (void)reloadFieldData
{
    [self.switcher setOn:[[self.form.formData objectForKey:self.name] boolValue]];
}

#pragma mark - switcher methods
- (void)changeSwitcher
{
    [self updateFormData:[NSNumber numberWithBool:self.switcher.on]];
}

@end
