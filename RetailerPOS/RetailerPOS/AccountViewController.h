
//  Created by Nguyen Duc Chien on 8/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.

#import <UIKit/UIKit.h>

@interface AccountViewController : UIViewController <UIActionSheetDelegate>
+(AccountViewController*)sharedInstance;

- (CGSize)reloadContentSize;

// button action
- (void)lockScreen;
- (void)logout;

@end
