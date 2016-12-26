//
//  APIResource.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ModelAbstract;
@class CollectionAbstract;

@protocol APIResource <NSObject>

#pragma mark - load methods
- (void)load:(ModelAbstract *)object withId:(NSObject *)identify finished:(SEL)finishedMethod;
- (void)loadCollection:(CollectionAbstract *)collection finished:(SEL)finishedMethod;

#pragma mark - save method
- (void)save:(ModelAbstract *)object withAction:(NSString *)action finished:(SEL)finishedMethod;

@end
