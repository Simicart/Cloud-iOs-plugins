//
//  MSFormAbstract.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/24/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MSForm;

@interface MSFormAbstract : UIView
@property (strong, nonatomic) MSForm *form;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *title;
@property (nonatomic) BOOL required;
@property (nonatomic) CGFloat height;

-(id)initWithConfig:(NSDictionary *)data;
-(BOOL)isInputElement;
// -(id)getValue;

-(void)initTableViewCell:(UITableViewCell *)cell;
-(void)reloadField:(UIView *)cell;
-(void)reloadFieldData;

-(void)selectTableViewCell:(UITableViewCell *)cell;

-(void)updateFormData:(id)value;

@end
