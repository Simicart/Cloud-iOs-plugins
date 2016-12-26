//
//  MarkLayerController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/16/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "MarkLayerController.h"

@implementation MarkLayerController

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideMenuBar];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self hideMenuBar];
}

- (void)hideMenuBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"globalToggleViewMenu" object:self];
}

@end
