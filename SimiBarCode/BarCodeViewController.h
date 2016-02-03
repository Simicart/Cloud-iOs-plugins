//
//  BarCodeViewController.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/20/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/SCProductViewController.h>
#import <SimiCartBundle/NSObject+SimiObject.h>
#import "ZBarSDK.h"
#import "MTBBarcodeScanner.h"
#import "BarCodeModel.h"

@interface BarCodeViewController : SimiViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
    BOOL isFistLoad; // First time load Controller
    BOOL isWaitingDataFromServer; // Waiting data from server
    BOOL isAfterPresentImagePickerView;
    BOOL isScanningFromPhoto;
    BOOL isImagePickerViewCancel;
    BOOL isScanFromPhotoSuccess;
}
@property (nonatomic) BOOL torchState;
@property (strong, nonatomic) UIView *previewView;
@property (strong, nonatomic) UIImageView *imgCanvas;
@property (strong, nonatomic) MTBBarcodeScanner *scanner;
@property (strong, nonatomic) NSMutableArray *uniqueCodes;
@property (strong, nonatomic) UILabel *lblShowDataScan;
@property (strong, nonatomic) UIButton *btnFlash;
@property (strong, nonatomic) UIButton *btnPhoto;
@property (strong, nonatomic) UIImageView *imgBackgroundHeader;
@property (strong, nonatomic) UIImageView *imgBackgroundFooter;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) BarCodeModel *barCodeModel;
@property (strong, nonatomic) UIPopoverController *popoverShowProduct;
@property (nonatomic) BOOL isAvailable;
@end
