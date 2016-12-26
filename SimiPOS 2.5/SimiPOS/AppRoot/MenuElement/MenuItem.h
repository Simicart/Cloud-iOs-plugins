//
//  MenuItem.h
//  MobilePOS
//
//  Created by Nguyen Dac Doan on 10/8/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuItem : UIViewController

@property (strong, nonatomic) IBOutlet UIView *selectBackground;

@property (strong, nonatomic) IBOutlet UIImageView *menuImageView;
@property (strong, nonatomic) IBOutlet UILabel *menuLabelView;

- (void)clearStyle;
- (void)selectStyle;

- (IBAction)touchDown:(id)sender;
- (IBAction)touchCancel:(id)sender;
- (IBAction)selectItem:(id)sender;

@end
