//
//  StarIOListPrintersViewController.h
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 7/19/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <StarIO/SMPort.h>

@protocol StarIOListPrintersDelegate <NSObject>
- (void)selectPrinterPort:(PortInfo *)portInfo;
@end


@interface StarIOListPrintersViewController : UITableViewController
@property (retain, nonatomic) id <StarIOListPrintersDelegate> delegate;
@end
