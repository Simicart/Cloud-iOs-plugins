//
//  SimiPayUAPI.h
//  SimiCartPluginFW
//
//  Created by Vu Thanh Do on 1/29/16.
//  Copyright © 2016 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>

@interface SimiPayUAPI : SimiAPI
-(void)getDirectLinkWithParam:(NSDictionary *)params target:(id)target selector:(SEL)selector;
@end
