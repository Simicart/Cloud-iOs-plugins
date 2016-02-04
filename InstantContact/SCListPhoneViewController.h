//
//  SCListPhoneViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/30/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
@protocol SCListPhoneViewController_Delegate<NSObject>
- (void)didSelectPhoneNumber:(NSString*)stringPhone;
@end
@interface SCListPhoneViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *arrayPhone;
@property (nonatomic, strong) id<SCListPhoneViewController_Delegate> delegate;
@end
