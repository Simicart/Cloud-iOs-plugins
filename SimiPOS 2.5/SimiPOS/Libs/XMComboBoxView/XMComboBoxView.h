//
//  XMComboBoxView.h
//  eReport
//
//  Created by Hung Do Manh on 5/21/13.
//  Copyright (c) 2013 Hung Do Manh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDropDownMenu.h"
@interface XMComboBoxView : UIDropDownMenu<UITextFieldDelegate> {

}
//caption and data normally same
-(void)makeMenu:(UIView *)targetView andIdentifier:(NSString*) identifier
        caption:(NSMutableArray *)captions data:(NSMutableArray*)data section:(NSMutableArray*) sections;
- (void) loadData:(NSMutableArray*) captions data:(NSMutableArray*) data section:(NSMutableArray*) sections;
-(void) onDropListSelected:(NSString*)identifier selectedValue:(NSString*) string;
-(void) setSelectedRow:(NSInteger)row;

-(NSString*) getSelectedText;
+ (void) setButtonImage:(NSString*) imageName;

@end
