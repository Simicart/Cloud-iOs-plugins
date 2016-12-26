//
//  MSFormSelectOptions.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/26/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSFormSelect.h"

@interface MSFormSelectOptions : UITableViewController <UIPopoverControllerDelegate>
@property (strong, nonatomic) MSFormSelect *selectInput;

@property (strong, nonatomic) NSArray *selectedOptions;

- (CGSize)reloadContentSize;

- (void)reloadData;

- (BOOL)isSelected:(id)option;

@property (strong, nonatomic) NSDictionary *dataSource;
@property (strong, nonatomic) NSArray *currentKeys;
- (NSArray *)sortedKeysArray;

@end
