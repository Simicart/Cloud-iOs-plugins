//
//  MSForm.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MSFormAbstract.h"
#import "MSFormRow.h"

#import "MSFormText.h"
#import "MSFormEmail.h"
#import "MSFormPassword.h"
#import "MSFormTextarea.h"

#import "MSFormBoolean.h"
#import "MSFormSelect.h"

#import "MSFormCCard.h"
#import "MSFormDate.h"
#import "MSFormMultiSelect.h"
#import "MSFormHidden.h"

@class MSForm;
@protocol MSFormDelegate <NSObject>
@optional
-(void)resetForm:(MSForm *)form;
-(void)doneEditForm:(MSForm *)form;
@end


@interface MSForm : UITableView <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id <MSFormDelegate> formDelegate;

@property (strong, nonatomic) NSMutableDictionary *formData;
@property (strong, nonatomic) NSMutableArray *formFields;

- (MSFormAbstract *)addField:(NSString *)type config:(NSDictionary *)data;

- (MSFormAbstract *)getFieldByName:(NSString *)name;

- (void)updateKeyboardInputType;

- (void)loadFormData:(NSDictionary *)data;
// - (NSDictionary *)formDataValues;

@end
