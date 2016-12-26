//
//  MSHTTPRequest.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/6/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MSHTTPRequest.h"

@interface MSHTTPRequest()
- (void)reportFinished;
@end

@implementation MSHTTPRequest

- (void)requestFinished
{
#if DEBUG_REQUEST_STATUS || DEBUG_THROTTLING
	ASI_DEBUG_LOG(@"[STATUS] Request finished: %@",self);
#endif
	if ([self error] || [self mainRequest]) {
		return;
	}
    [self reportFinished];
//	if ([self isPACFileRequest]) {
//		[self reportFinished];
//	} else {
//		[self performSelectorOnMainThread:@selector(reportFinished) withObject:nil waitUntilDone:[NSThread isMainThread]];
//	}
}

- (void)reportFinished
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	if (delegate && [delegate respondsToSelector:didFinishSelector]) {
		[delegate performSelector:didFinishSelector withObject:self];
	}
#pragma clang diagnostic pop
    
#if NS_BLOCKS_AVAILABLE
	if(completionBlock){
		completionBlock();
	}
#endif
    
	if (queue && [queue respondsToSelector:@selector(requestFinished:)]) {
		[queue performSelector:@selector(requestFinished:) withObject:self];
	}
}

@end
