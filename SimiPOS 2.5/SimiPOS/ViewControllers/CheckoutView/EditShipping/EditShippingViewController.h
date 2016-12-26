//
//  EditShippingViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/17/13.
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


// load customer data
- (void)loadAddressData;

// process locale
- (void)reloadRegion;
- (void)changeCountry:(NSNotification *)note;
 
@end
