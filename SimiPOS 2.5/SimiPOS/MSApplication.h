//
//  MSApplication.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/13/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSApplication : UIApplication {
    NSTimer *_watchDogTimer;
}

- (void)resetWatchDogTimer;

@end
