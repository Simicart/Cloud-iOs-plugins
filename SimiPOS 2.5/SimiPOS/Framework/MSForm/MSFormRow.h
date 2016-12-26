//
//  MSFormRow.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/25/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSFormAbstract.h"

@interface MSFormRow : MSFormAbstract
@property (strong, nonatomic) NSMutableArray *childFields;

- (MSFormAbstract *)addField:(NSString *)type config:(NSDictionary *)data;

@end
