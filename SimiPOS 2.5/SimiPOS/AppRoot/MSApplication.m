//
//  MSApplication.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/13/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "MSApplication.h"
#import "Configuration.h"

@interface MSApplication ()
- (void)watchDogTimerTimeout;
@end

@implementation MSApplication

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    if (_watchDogTimer) {
        NSSet *allTouches = [event allTouches];
        if ([allTouches count]) {
            UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
            if (phase == UITouchPhaseBegan) {
                [self resetWatchDogTimer];
            }
        }
    } else {
        [self resetWatchDogTimer];
    }
}

- (void)resetWatchDogTimer
{
    if (_watchDogTimer) {
        [_watchDogTimer invalidate];
    }
    
    NSUInteger timeout = 5;//[[[Configuration globalConfig] objectForKey:@"general/timeout"] intValue];
    if (timeout == 4) {
        _watchDogTimer = nil;
    } else {
        switch (timeout) {
            case 0:
                timeout = 120;
                break;
            case 1:
                timeout = 300;
                break;
            case 2:
                timeout = 600;
                break;
            default:
                timeout = 30;
                break;
        }
        _watchDogTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(watchDogTimerTimeout) userInfo:nil repeats:NO];
    }
}

- (void)watchDogTimerTimeout
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MSApplicationTimeOut" object:nil];
}

@end
