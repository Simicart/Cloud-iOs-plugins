//
//  Product.m
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/9/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "Product.h"
#import "MagentoProduct.h"

@implementation Product
@synthesize isLoadingOptions = _isLoadingOptions;

-(id)init
{
    if (self = [super init]) {
        self.eventPrefix = @"Product";
        self.isLoadingOptions = NO;
    }
    return self;
}

#pragma mark - data methods (get/set)
-(NSString *)getName
{
    return (NSString *)[self objectForKey:@"name"];
}

#pragma mark - options methods
-(BOOL)hasOptions
{
    return [[self objectForKey:@"has_options"] boolValue];
}

-(BOOL)isLoadedOptions
{
    if (![self hasOptions]) {
        return YES;
    }
    NSArray *options = (NSArray *)[self objectForKey:@"options"];
    if (options != nil && [options count]) {
        return YES;
    }
    return NO;
}

-(NSArray *)getOptions
{
    NSArray *options = (NSArray *)[[self objectForKey:@"detail"]objectForKey:@"options"];
    if (![self hasOptions] || (options != nil && [options count])) {
        return options;
    }
    if (self.isLoadingOptions) {
        return options;
    }
    self.isLoadingOptions = YES;
    MagentoProduct *resource = (MagentoProduct *)[self getResource];
    [self setValue:[resource loadOptions:self] forKey:@"options"];
    // wait complete - timeout is 15 seconds
    CFTimeInterval endTime = CACurrentMediaTime() + 15;
    while (CACurrentMediaTime() < endTime && ![[self objectForKey:@"options"] count]) {
        // run loop
    }
    if ([self isLoadedOptions]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ProductLoadOptionsSuccess" object:self];
    } else {
        // request timeout - dispatch error timeout
        [[NSNotificationCenter defaultCenter] postNotificationName:@"QueryException" object:self userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"RequestTimeOut", @"name", NSLocalizedString(@"Request timeout", nil), @"reason", nil]];
    }
    self.isLoadingOptions = NO;
    return (NSArray *)[self objectForKey:@"options"];
}

#pragma mark - load product detail
- (void)loadDetail:(NSObject *)identify
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProductLoadDetailBefore" object:self];
    
    [(MagentoProduct *)[self getResource] loadDetail:self withId:identify finished:@selector(loadDetailSuccess)];
}

- (void)loadDetailSuccess
{
    for (id key in [self allKeys]) {
        if ([[self objectForKey:key] isKindOfClass:[NSNull class]]) {
            [self removeObjectForKey:key];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ProductLoadDetailAfter" object:self];
}

@end
