//
//  StarIOPrinterViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 7/18/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "StarIOListPrintersViewController.h"

@class StarIOPrinterViewController;
typedef void (^starPrintCompleteBlock)(StarIOPrinterViewController *printViewController, BOOL completed, NSString *error);

// Star IO printer protocol
@protocol StarIOPrinterViewControllerDelegate <NSObject>

- (UIImage *)printViewController:(StarIOPrinterViewController *)printViewController;

@end


// Print controller
@interface StarIOPrinterViewController : UITableViewController <StarIOListPrintersDelegate>
@property (weak, nonatomic) id <StarIOPrinterViewControllerDelegate> delegate;

+ (instancetype)sharePrinterViewController;

- (void)presentFromBarButtonItem:(UIBarButtonItem *)item completionHandler:(starPrintCompleteBlock)completion;

@end
