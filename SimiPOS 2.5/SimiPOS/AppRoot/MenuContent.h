//
//  MenuContent.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/16/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MenuContent <NSObject>

- (UIViewController <MenuContent> *)initMenuView;
- (BOOL)didSelectedChange;

@end
