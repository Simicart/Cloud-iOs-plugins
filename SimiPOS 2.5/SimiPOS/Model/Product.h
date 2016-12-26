//
//  Product.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelAbstract.h"

@interface Product : ModelAbstract

// Instance methods (get/set)
-(NSString *)getName;

// Options methods
@property (nonatomic) BOOL isLoadingOptions;

-(BOOL)hasOptions;
-(BOOL)isLoadedOptions;
-(NSArray *)getOptions;

// Load product detail
- (void)loadDetail:(NSObject *)identify;
- (void)loadDetailSuccess;

@end
