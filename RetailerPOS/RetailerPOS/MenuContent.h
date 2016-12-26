//
//  MenuContent.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 10/16/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuContent <NSObject>

- (UIViewController <MenuContent> *)initMenuView;
- (BOOL)didSelectedChange;

@end
