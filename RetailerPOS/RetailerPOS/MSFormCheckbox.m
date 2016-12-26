//
//  MSFormCheckbox.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 9/26/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSFormCheckbox.h"
#import "MSForm.h"
#import "M13Checkbox.h"

@interface MSFormCheckbox()
@property (strong, nonatomic) M13Checkbox *checkbox;
@end

@implementation MSFormCheckbox
@synthesize checkbox;

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        self.checkbox = [[M13Checkbox alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        self.checkbox.strokeColor = [UIColor grayColor];
        [self.checkbox addTarget:self action:@selector(changeCheckbox) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)reloadField:(UITableViewCell *)cell
{
    cell.accessoryView = self.checkbox;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = self.title;
}

- (void)reloadFieldData
{
    if ([[self.form.formData objectForKey:self.name] boolValue]) {
        [self.checkbox setCheckState:M13CheckboxStateChecked];
    } else {
        [self.checkbox setCheckState:M13CheckboxStateUnchecked];
    }
}

- (void)changeCheckbox
{
    if ([self.checkbox checkState] == M13CheckboxStateChecked) {
        [self updateFormData:[NSNumber numberWithBool:YES]];
    } else {
        [self updateFormData:nil];
    }
}

- (void)selectTableViewCell:(UITableViewCell *)cell
{
    [self.checkbox toggleCheckState];
    [self changeCheckbox];
}

@end
