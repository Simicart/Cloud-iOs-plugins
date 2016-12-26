//
//  EditShippingViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 12/17/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Quote.h"
#import "MSForm.h"

@interface EditShippingViewController : UIViewController

@property (strong, nonatomic) Customer *customer;
@property (strong, nonatomic) MSForm *form;

- (void)cancelEdit;
- (void)saveShippingAddress;

// Edit form resize
- (void)resizeFormHeight:(NSNotification *)note;
- (void)returnFormHeight:(NSNotification *)note;

// load customer data
- (void)loadAddressData;

// process locale
- (void)reloadRegion;
- (void)changeCountry:(NSNotification *)note;

@end
