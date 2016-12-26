//
//  IDTechSwipeViewController.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 6/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "uniMag.h"
#import "PaymentFormAbstract.h"

@interface IDTechSwipeViewController : PaymentFormAbstract

@property (strong, nonatomic) uniMag *uniMagPos;
@end
