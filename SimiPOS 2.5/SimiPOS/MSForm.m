//
//  MSForm.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSForm.h"

@implementation MSForm
@synthesize formDelegate;
@synthesize formData, formFields;

- (id)init
{
    if (self = [super init]) {
        self.formData = [[NSMutableDictionary alloc] init];
        self.formFields = [[NSMutableArray alloc] init];
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

- (void)reloadData
{
    if ([NSThread isMainThread]) {
        [super reloadData];
    } else {
        [super performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
}

#pragma mark - form methods
- (MSFormAbstract *)addField:(NSString *)type config:(NSDictionary *)data
{
    NSString *fieldClass = [NSString stringWithFormat:@"MSForm%@", type];
    MSFormAbstract *field = [[NSClassFromString(fieldClass) alloc] initWithConfig:data];
    field.form = self;
    [self.formFields addObject:field];
    // Add default value
    if ([data objectForKey:@"value"]) {
        [self.formData setValue:[data objectForKey:@"value"] forKey:field.name];
    }
    return field;
}

- (MSFormAbstract *)getFieldByName:(NSString *)name
{
    for (MSFormAbstract *field in self.formFields) {
        if ([field.name isEqualToString:name]) {
            return field;
        } else if (![field isInputElement]) {
            for (MSFormAbstract *subField in [(MSFormRow *)field childFields]) {
                if ([subField.name isEqualToString:name]) {
                    return subField;
                }
            }
        }
    }
    return nil;
}

- (void)updateKeyboardInputType
{
    for (NSInteger i = [self.formFields count] - 1; i >= 0; i--) {
        MSFormAbstract *field = [self.formFields objectAtIndex:i];
        if ([field isKindOfClass:[MSFormText class]]) {
            if ([field isKindOfClass:[MSFormTextarea class]]) {
                ((MSFormTextarea *)field).textInput.returnKeyType = UIReturnKeyDone;
            } else {
                ((MSFormText *)field).inputText.returnKeyType = UIReturnKeyDone;
            }
            return;
        } else if (![field isInputElement]) {
            NSArray *childFields = [(MSFormRow *)field childFields];
            for (NSInteger j = [childFields count] - 1; j >= 0; j--) {
                MSFormAbstract *subField = [childFields objectAtIndex:j];
                if ([subField isKindOfClass:[MSFormTextarea class]]) {
                    ((MSFormTextarea *)subField).textInput.returnKeyType = UIReturnKeyDone;
                } else if ([subField isKindOfClass:[MSFormText class]]) {
                    ((MSFormText *)subField).inputText.returnKeyType = UIReturnKeyDone;
                }
                return;
            }
        }
    }
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self updateKeyboardInputType];
    return [self.formFields count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSFormAbstract *field = [self.formFields objectAtIndex:[indexPath row]];
    NSString *CellID = [[field class] description];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [field initTableViewCell:cell];
    }
    [field reloadField:cell];
    [field reloadFieldData];
    
    return cell;
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSFormAbstract *field = [self.formFields objectAtIndex:[indexPath row]];
    return field.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    MSFormAbstract *field = [self.formFields objectAtIndex:[indexPath row]];
    [field selectTableViewCell:cell];
}

#pragma mark - form data
- (void)loadFormData:(NSDictionary *)data
{
    DLog(@"dta:%@",data);
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [self.formData removeObjectForKey:key];
        } else {
            [self.formData setValue:obj forKey:key];
        }
    }];
    // [self.formData addEntriesFromDictionary:data];
}
//
//- (NSDictionary *)formDataValues
//{
//    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
//    for (MSFormAbstract *field in self.formFields) {
//        id value = [field getValue];
//        if (value == nil) {
//            continue;
//        }
//        if ([value isKindOfClass:[NSDictionary class]]) {
//            [values addEntriesFromDictionary:value];
//        } else {
//            [values setValue:value forKey:field.name];
//        }
//    }
//    return values;
//}

@end
