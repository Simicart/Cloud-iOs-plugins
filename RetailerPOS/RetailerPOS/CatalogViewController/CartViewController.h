//
//  CartViewController.h
//  MobilePOS
//
//  Edit by Nguyen Duc Chien on 10/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"
#import "ProductCollectionViewVC.h"

#define SHOPPING_CART_PAGE  1
#define CHECKOUT_PAGE       2

@class CartInformation;

@interface CartViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) ProductCollectionViewVC *productView;

@property (strong, nonatomic) IBOutlet UIButton *totalButton;
@property (strong, nonatomic) IBOutlet UILabel *totalLabel;
@property (strong, nonatomic) CartInformation *cartController;
@property (weak, nonatomic) IBOutlet UIButton *holdButton;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;



//Truong hop khi nhan continue tu man hinh hold Order sang
@property (assign, nonatomic) BOOL isHoldOrder;
@property (strong, nonatomic) Order *order;

// Load data from server
- (void)loadCartInformation;
- (void)loadCartInformationThread;

// Refresh cart
- (void)clearShoppingCart;
- (void)refreshCartView;

- (IBAction)startCheckout;
- (IBAction)backToShoppingCart;

- (void)showNoteForm:(id)sender;

- (void)addProductByBarcode:(NSString *)barcode;
- (void)listenBarCodeReader:(NSNotification *)note;
- (void)reListenBarcodeReader:(NSNotification *)note;
- (void)forceListenBarcodeRd:(NSNotification *)note;

// External Methods
- (void)showBackButton;

+(CartViewController*)sharedInstance;

@end
