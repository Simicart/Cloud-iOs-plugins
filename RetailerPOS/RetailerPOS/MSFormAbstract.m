//
//  MSFormAbstract.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormAbstract.h"
#import "MSForm.h"

@implementation MSFormAbstract
@synthesize form = _form;
@synthesize name, title, required, height;

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super init]) {
        // Config Form Field Data
        self.name = [data objectForKey:@"name"];
        self.title = [data objectForKey:@"title"];
        self.required = [[data objectForKey:@"required"] boolValue];
        self.height = [[data objectForKey:@"height"] floatValue];
        if (self.height < 1) {
            self.height = 44;
        }
    }
    return self;
}

- (BOOL)isInputElement
{
    return YES;
}
//
//- (id)getValue
//{
//    return nil;
//}

#pragma mark - working with table view cell
- (void)initTableViewCell:(UITableViewCell *)cell
{
    // Need overidded -- init table view cell
}

- (void)reloadField:(UIView *)cell
{
    // Need overrided -- reload display for cell
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        [cell addSubview:self];
        self.frame = CGRectMake(0, 0, self.form.frame.size.width, self.height);
    } else {
        self.frame = cell.frame;
    }
}

- (void)reloadFieldData
{
    // Need overrided -- reload data for input
}

- (void)selectTableViewCell:(UITableViewCell *)cell
{
    // Need overridded - select table view cell
}

#pragma mark - update form data
- (void)updateFormData:(id)value
{
    if (value == nil) {
        [self.form.formData removeObjectForKey:self.name];
    } else {
        [self.form.formData setValue:value forKey:self.name];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSFormFieldChange" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSFormUpdateData" object:self.form];
}

@end
