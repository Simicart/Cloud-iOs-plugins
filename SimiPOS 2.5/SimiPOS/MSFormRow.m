//
//  MSFormRow.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/25/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormRow.h"
#import "MSForm.h"

@implementation MSFormRow
@synthesize childFields;

- (id)initWithConfig:(NSDictionary *)data
{
    if (self = [super initWithConfig:data]) {
        self.childFields = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)isInputElement
{
    return NO;
}
//
//- (id)getValue
//{
//    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
//    for (MSFormAbstract *field in self.childFields) {
//        if (field.name) {
//            [values setValue:[field getValue] forKey:field.name];
//        }
//    }
//    return values;
//}

#pragma mark - children fields
- (MSFormAbstract *)addField:(NSString *)type config:(NSDictionary *)data
{
    NSString *fieldClass = [NSString stringWithFormat:@"MSForm%@", type];
    MSFormAbstract *field = [[NSClassFromString(fieldClass) alloc] initWithConfig:data];
    field.form = self.form;
    [self.childFields addObject:field];
    // Update Row heigh
    if (self.height < field.height) {
        self.height = field.height;
    }
    // Add default value
    if ([data objectForKey:@"value"]) {
        [self.form.formData setValue:[data objectForKey:@"value"] forKey:field.name];
    }
    return field;
}

#pragma mark - working with table view cell
- (void)reloadField:(UITableViewCell *)cell
{
    [super reloadField:cell];
    
    // Reload View for Cell
    if (![self.childFields count]) {
        return;
    }
    CGFloat width = (self.form.frame.size.width + 1) / [self.childFields count];
    CGFloat x = 0;
    for (MSFormAbstract *field in self.childFields) {
        [self addSubview:field];
        UIView *subField = [[UIView alloc] initWithFrame:CGRectMake(x, 0, width - 1, field.height)];
        [field reloadField:subField];
        x += width;
        // Separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(x-1, 0, 1, field.height)];
        separator.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
        [self addSubview:separator];
    }
}

- (void)reloadFieldData
{
    // Update data for input view
    for (MSFormAbstract *field in self.childFields) {
        [field reloadFieldData];
    }
}

@end
