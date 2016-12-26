//
//  PayPalHereSDKViewController.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 5/30/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "PayPalHereSDKViewController.h"
#import "Quote.h"
#import "CreditCardSignViewController.h"
#import "CatalogViewController.h"
#import "PosTable.h"
#import "MSNavigationController.h"
#import "PPHKey.h"
#import "PaymentCompleteViewController.h"


@interface PayPalHereSDKViewController ()<PPHCardReaderDelegate, PPHTransactionManagerDelegate>
@property (nonatomic, strong) PPHCardReaderWatcher *cardReaderWatcher;
@property (nonatomic, strong) PPHTransactionWatcher *transactionWatcher;
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@property (strong, nonatomic) PosTable *cells;
@property (strong, nonatomic) UITableView* tableView;
@property (nonatomic) PPHReaderType* readerType;

@property (nonatomic, strong) UILabel *cardReaderStatus;
@property (nonatomic) BOOL promptedForSoftwareUpdate;
@property (nonatomic, strong) UIAlertView *softwareUpgradeAlert;

@end

@implementation PayPalHereSDKViewController{
    
    PPHAccessAccount *accessAccount;
    PPHSignatureViewController *signatureVC;
    PPHTransactionRecord * currentTransctionRecord;
    PPHInvoice *invoice;
    PPHAmount *amount;
    UIButton *chargeBtn;
    UIColor *colorActiveButton;
    UIColor *colorNoneActiveButton;
    UIColor *colorTintButton;
    
    
    NSString *nameIconSelected;
    NSString *nameIconUnSelected;
    float fontSize;
    float screenWidth;
    float padding;
    
    UIWebView *loginPaypalWebView;
    
    Boolean sanbox;
    UIAlertView *alertSuccess;
    UIAlertView *alertError;
    
    UIImageView *iconReady;
}

- (instancetype)init {
    if (self = [super init]) {
        self.cardReaderWatcher = [[PPHCardReaderWatcher alloc] initWithDelegate:self];
        self.transactionWatcher = [[PPHTransactionWatcher alloc] initWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpConstant];
    
    MSBackButton *backBtn = [MSBackButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn addTarget:self action:@selector(backToPaymentMethods) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    
    _animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _animation.center = CGPointMake(screenWidth/2, self.view.bounds.size.height/2);
    
    self.cardReaderStatus = [UILabel new];
    [self.cardReaderStatus setFont:[UIFont systemFontOfSize:14]];
    [self.cardReaderStatus setTextAlignment:NSTextAlignmentCenter];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    [self.tableView setFrame:CGRectMake(0, 0, screenWidth, SCREEN_HEIGHT - 64)];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.delaysContentTouches = NO;
    self.tableView.scrollEnabled = NO;
    [self.view addSubview: self.tableView];
    [self.view addSubview:_animation];
    
    sanbox = YES;
    
//    [PayPalHereSDK selectEnvironmentWithType:ePPHSDKServiceType_Live];
//    [PayPalHereSDK setLoggingDelegate:self];
//    [PayPalHereSDK clearActiveMerchant];
//    
//    if (sanbox) {
//        [self getToken];
//    }else{
//        [self getTokenLive];
//    }
    
    NSString *access_token = [[Quote sharedQuote].payment.instance valueForKey:@"access_token"];
    NSString *expires_in = [[Quote sharedQuote].payment.instance valueForKey:@"expires_in"];
    
    if ([access_token isKindOfClass:[NSNull class]]) {
        [self alertErrorHandle:@"Don't have Access Token"];
    } else{
        if ([expires_in isKindOfClass:[NSNull class]]) expires_in = @"";
        [self initializeSDKMerchantWithCredentials:access_token refreshUrl:@"" tokenExpiryOrNil:expires_in];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)backToPaymentMethods
{
    [self dismissViewControllerAnimated:YES completion:^{
        DLog(@"dismiss");
        [self clearAnyExistingInfo];
        [[PayPalHereSDK sharedTransactionManager] deActivateReaderForPayments];
    }];
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self clearAnyExistingInfo];
    [self setUpInvoiceAndAmount];
    [self.tableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.promptedForSoftwareUpdate = NO;
    [self checkForSoftwareUpgrade];
}

- (void)clearAnyExistingInfo {
    [[PayPalHereSDK sharedTransactionManager] cancelPayment];
}

#pragma mark setCells
-(void) setCells:(PosTable *)cells{
    if(cells) _cells = cells;
    else{
        float heightWrapCardReader = screenWidth / 3;
        _cells = [PosTable new];
        PosSection* section = [_cells addSectionWithIdentifier:@"PayPal Here Screen"];
        PosRow* charge = [[PosRow alloc] initWithIdentifier:Charge height:50];
        [section addObject:charge];
        
        
        if ([PayPalHereSDK sharedCardReaderManager].activeReader.readerType == ePPHReaderTypeAudioJack ) {
            PosRow* audioJack = [[PosRow alloc] initWithIdentifier:AudioJack height:heightWrapCardReader];
            [section addObject:audioJack];
        }
        
        if ([PayPalHereSDK sharedCardReaderManager].activeReader.readerType == ePPHReaderTypeChipAndPinBluetooth ) {
            PosRow* chipAndPinBluetooth = [[PosRow alloc] initWithIdentifier:ChipAndPinBluetooth height:heightWrapCardReader + 10];
            [section addObject:chipAndPinBluetooth];
            
        }
        PosRow* cardReaderStatusRow = [[PosRow alloc] initWithIdentifier:CardReaderStatus height:30];
        [section addObject:cardReaderStatusRow];
    }
}

- (void)setUpConstant{
    nameIconSelected    = @"PayPalHereSDK.bundle/ic_checkmark_lg@2x";
    nameIconUnSelected  = @"ic_unselected";
    fontSize = 20;
    padding = 10;
    if (self.navigationController.modalPresentationStyle == UIModalPresentationFormSheet) {
        screenWidth  = 540 ;
    } else if (self.navigationController.modalPresentationStyle == UIModalPresentationPageSheet) {
        screenWidth  = SCREEN_WIDTH *3/4 ;
    }
    
    colorActiveButton      = [UIColor greenColor];
    colorNoneActiveButton  = [UIColor grayColor];
    colorTintButton        = [UIColor blackColor];
    
}

- (void)getToken{
    loginPaypalWebView = [UIWebView new];
    [loginPaypalWebView setFrame:CGRectMake(0, 0, screenWidth, self.view.bounds.size.height)];
    loginPaypalWebView.delegate = self;
    [loginPaypalWebView setContentMode:UIViewContentModeScaleAspectFit];
    [loginPaypalWebView.scrollView setScrollEnabled:YES];
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"SAVED_TOKEN"];
    [self.view bringSubviewToFront:_animation];
    [_animation startAnimating];
    if (savedToken) {
        [self initializeSDKMerchantWithToken:savedToken];
    } else {
        [self.view addSubview:loginPaypalWebView];
        NSURL *url = [NSURL URLWithString:@"http://pph-retail-sdk-sample.herokuapp.com/toPayPal/sandbox"];
        [loginPaypalWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}


- (void)getTokenLive{
    loginPaypalWebView = [UIWebView new];
    [loginPaypalWebView setFrame:CGRectMake(0, 0, screenWidth, self.view.bounds.size.height)];
    loginPaypalWebView.delegate = self;
    [loginPaypalWebView setContentMode:UIViewContentModeScaleAspectFit];
    [loginPaypalWebView.scrollView setScrollEnabled:YES];
    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"SAVED_TOKEN_LIVE"];
    [self.view bringSubviewToFront:_animation];
    [_animation startAnimating];
    if (savedToken) {
        [self initializeSDKMerchantWithTokenLive:savedToken];
    } else {
        [self.view addSubview:loginPaypalWebView];
        [self.view bringSubviewToFront:_animation];
        NSURL *url = [NSURL URLWithString:@"http://pph-retail-sdk-sample.herokuapp.com/toPayPal/live"];
        [loginPaypalWebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}


- (void)initializeSDKMerchantWithToken:(NSString *)token{
    [PayPalHereSDK setupWithCompositeTokenString: token
                           thenCompletionHandler:^(PPHInitResultType status, PPHError *error, PPHMerchantInfo *info) {
                               if (!error) {
                                   [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"SAVED_TOKEN"];
                                   [loginPaypalWebView removeFromSuperview];
                                   [self startWithPayPalHere];
                               }else{
                                   [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SAVED_TOKEN"];
                                   [self getToken];
                               }
                           }];
}


- (void)initializeSDKMerchantWithTokenLive:(NSString *)token{
    [PayPalHereSDK setupWithCompositeTokenString: token
                           thenCompletionHandler:^(PPHInitResultType status, PPHError *error, PPHMerchantInfo *info) {
                               if (!error) {
                                   [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"SAVED_TOKEN_LIVE"];
                                   [loginPaypalWebView removeFromSuperview];
                                   [self startWithPayPalHere];
                               }else{
                                   [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SAVED_TOKEN_LIVE"];
                                   [self getTokenLive];
                               }
                           }];
}


- (void)initializeSDKMerchantWithCredentials:(NSString *)access_token refreshUrl:(NSString *)refresh_url tokenExpiryOrNil:(NSString *)expiry{
    [_animation startAnimating];
    [PayPalHereSDK selectEnvironmentWithType:ePPHSDKServiceType_Sandbox];
    [PayPalHereSDK setLoggingDelegate:self];
    [PayPalHereSDK clearActiveMerchant];
    [PayPalHereSDK setupWithCredentials:access_token refreshUrl:refresh_url tokenExpiryOrNil:expiry thenCompletionHandler:^(PPHInitResultType status, PPHError *error, PPHMerchantInfo *info) {
        if (!error) {
            [self startWithPayPalHere];
        }else{
//            [self getAccessToken];
            [self alertErrorHandle:@"Error Access Token"];
        }
    }];
}


- (void) startWithPayPalHere{
    [self clearAnyExistingInfo];
    [self setUpInvoiceAndAmount];
    [self updateUI];
    [_animation stopAnimating];
    self.promptedForSoftwareUpdate = NO;
}

- (void)setUpInvoiceAndAmount{
    NSMutableArray *arrItem = [[NSMutableArray alloc]initWithArray:[[Quote sharedQuote] getAllItems]];
    invoice = [[PPHInvoice alloc]initWithCurrency:[PayPalHereSDK activeMerchant].currencyCode];
    for (NSDictionary *item in arrItem) {
        NSString *strQty = [NSString stringWithFormat:@"%@",[item valueForKey:@"qty"]];
        NSDecimalNumber *qty = [NSDecimalNumber decimalNumberWithString:strQty];
        NSString *strPrice = [NSString stringWithFormat:@"%@",[item valueForKey:@"price"]];
        NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:strPrice];
        NSString *strTaxPercent = [NSString stringWithFormat:@"%@",[item valueForKey:@"tax_percent"]];
        CGFloat floatTaxPercent = [strTaxPercent floatValue];
        floatTaxPercent = floatTaxPercent/100;
        NSDecimalNumber *taxPercent = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%.02f",floatTaxPercent]] ;
        [invoice addItemWithId:[item valueForKey:@"product_id"]
                          name:[item valueForKey:@"name"]
                      quantity:qty
                     unitPrice:price
                       taxRate:taxPercent
                   taxRateName:@"tax_percent"];
    }
    NSString *strshippingAmount = [NSString stringWithFormat:@"%@",[[Quote sharedQuote] getShipping]];
    NSDecimalNumber *decShippingAmount = [NSDecimalNumber decimalNumberWithString:strshippingAmount];
    
    invoice.shippingAmount = decShippingAmount;
    
    NSString *strAmount = [NSString stringWithFormat:@"%0.2f",[[[Quote sharedQuote] getGrandTotal] floatValue]];
    
    NSDecimalNumber *decAmount = [NSDecimalNumber decimalNumberWithString:strAmount];
    amount = [[PPHAmount alloc]initWithAmount:decAmount inCurrency:[PayPalHereSDK activeMerchant].currencyCode];
    [[PayPalHereSDK sharedTransactionManager] beginPaymentUsingUIWithInvoice:invoice transactionController:self];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSURL *url = request.URL;
    if ([url.scheme isEqualToString:@"retailsdksampleapp"]) {
        NSString *token = url.query;
        if (sanbox) {
            [self initializeSDKMerchantWithToken:token];
        }else{
            [self initializeSDKMerchantWithTokenLive:token];
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [_animation stopAnimating];
}

#pragma mark -
#pragma PPHTransactionControllerDelegate implementation

-(UINavigationController *)getCurrentNavigationController {
    return self.navigationController;
}

// When the customer either taps, inserts or swipes their card, SDK would call you with this.
// Update your invoice here, if needed, before we proceed with the transaction.
// IMPORTANT NOTE : For a contactless transaction, refrain from updating the invoice once the card is tapped.
- (void)userDidSelectPaymentMethod:(PPHPaymentMethod) paymentOption {
    __weak typeof(self) weakSelf = self;
    // STEP #3 to take an EMV payment.
    [[PayPalHereSDK sharedTransactionManager] processPaymentUsingUIWithPaymentType:paymentOption
                                                                 completionHandler:^(PPHTransactionResponse *response) {
                                                                     [weakSelf gotoPaymentCompleteScreenWithResponse:response];
                                                                 }];
}

- (void)gotoPaymentCompleteScreenWithResponse:(PPHTransactionResponse *)response {
    PaymentCompleteViewController *paymenCompletetVC = [[PaymentCompleteViewController alloc] initWithTransactionResponse:response];
    [self.navigationController pushViewController:paymenCompletetVC animated:YES];
}

- (void)userDidSelectRefundMethod:(PPHPaymentMethod)refundOption {
}


#pragma mark -
#pragma PPHTransactionManagerDelegate implementation

- (void)onPaymentEvent:(PPHTransactionManagerEvent *)event {
    
    // Restart the payment if the user cancels it by presing the X button on the reader.
    if (event.eventType == ePPHTransactionType_TransactionCancelled) {
        [[PayPalHereSDK sharedTransactionManager] beginPaymentUsingUIWithInvoice:invoice transactionController:self];
    }
}

#pragma mark -
#pragma PPHCardReaderDelegate implementation



- (void)didDetectReaderDevice:(PPHCardReaderMetadata *)reader {
    [self updateUI];
    [self checkForSoftwareUpgrade];
}

- (void)didRemoveReader:(PPHReaderType)readerType{
    [self updateUI];
}


- (void)didFailToReadCard{
    [self alertErrorHandle:@"Fail To Read Card"];
}

- (void)didReceiveCardReaderMetadata:(PPHCardReaderMetadata *)metadata{
    [self checkForSoftwareUpgrade];
}

- (void)activeReaderChangedFrom:(PPHCardReaderMetadata *)previousReader to:(PPHCardReaderMetadata *)currentReader {
    [[PayPalHereSDK sharedTransactionManager] beginPaymentUsingUIWithInvoice:invoice transactionController:self];
    if ([PayPalHereSDK sharedCardReaderManager].activeReader.readerType == ePPHReaderTypeChipAndPinBluetooth){
        [[PayPalHereSDK sharedTransactionManager] activateReaderForPayments:NULL];
    }
    [self updateUI];
}

- (void)didUpgradeReader:(BOOL)successful withMessage:(NSString *)message{
    DLog(@"%@",message);
}

- (void)didRemoveCard{
    DLog(@"didRemoveCard");
}


- (void)updateUI{
    [self updateUIWithActiveReader];
    [self setCells:nil];
    [self.tableView reloadData];
}


#pragma mark -
#pragma Alert Error
- (void)alertErrorHandle:(NSString *)message{
    
    if (alertError == nil) {
        alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:message delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil, nil];
    }else if(alertError.visible){
        alertError.message = message;
    }
    [alertError show];
}



#pragma mark -
#pragma Software Update Related Implementation

- (void)checkForSoftwareUpgrade {
    if (!self.promptedForSoftwareUpdate && [[PayPalHereSDK sharedCardReaderManager].activeReader upgradeIsManadatory]) {
        self.promptedForSoftwareUpdate = YES;
        
        self.softwareUpgradeAlert = [[UIAlertView alloc] initWithTitle:@"Software Upgrade Required"
                                                               message:@"You must update your reader before it is eligible for payment."
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Start Upgrade", nil];
        [self.softwareUpgradeAlert show];
    }
}

-(void)beginReaderUpgrade {
    __weak typeof(self) weakSelf = self;
    [[PayPalHereSDK sharedCardReaderManager] beginUpgradeUsingSDKUIForReader:[[PayPalHereSDK sharedCardReaderManager] availableReaderOfType:ePPHReaderTypeChipAndPinBluetooth]
                                                           completionHandler:^(BOOL success, NSString *message) {
                                                               weakSelf.promptedForSoftwareUpdate = NO;
                                                               NSString *title = success ? @"Software Upgrade Successful" : @"Software Upgrade Failed";
                                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                                                               message:nil
                                                                                                              delegate:nil
                                                                                                     cancelButtonTitle:@"OK"
                                                                                                     otherButtonTitles:nil];
                                                               [alert show];
                                                               [[PayPalHereSDK sharedTransactionManager] beginPaymentUsingUIWithInvoice:invoice transactionController:weakSelf];
                                                           }];
}

#pragma mark -
#pragma mark Receipts

- (NSArray *)getReceiptOptions {
    
    PPHReceiptOption *receiptOption = [[PPHReceiptOption alloc] initWithBlock:^(PPHTransactionRecord *record, UIView *presentedView) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"paypalherePaymentSuccess" object:nil];
        }];
    } predicate:^BOOL(PPHTransactionRecord *record) {
        BOOL isReturn = NO;
        if (record.transactionStatus == ePPHTransactionStatusPaid){
            isReturn = YES;
        }
        return isReturn;
    } buttonLabel:@"Completed Payment"];
    
    return @[receiptOption];
}

#pragma mark - PPHSignatureViewControllerDelegate
#pragma mark ReceiPPHSignatureViewControllerDelegatepts

- (void)takeSignatureViewController:(PPHSignatureViewController *)viewController collectedSignatureImage:(UIImage *)signatureImage{
    [[PayPalHereSDK sharedTransactionManager] provideSignature:signatureImage
                                                forTransaction:currentTransctionRecord
                                             completionHandler:^(PPHError * error) {
                                                 
                                                 if (!error) {
                                                     [viewController dismissViewControllerAnimated:YES completion:nil];
                                                     
                                                 }else{
                                                     DLog(@"%@",error);
                                                 }
                                             }];
    
};
- (void)takeSignatureViewControllerCanceledCollectingSignature:(PPHSignatureViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
};




-(void)logPayPalHereError: (NSString*) message{
    DLog(@"logPayPalHereError : %@",message);
};
/*!
 * Log a message considered to be a potential issue affecting proper function.
 * @param message The fully formatted log message.
 */
-(void)logPayPalHereWarning: (NSString*) message{
    DLog(@"logPayPalHereWarning : %@",message);
};
/*!
 * Log informational events.
 * @param message The fully formatted log message.
 */
-(void)logPayPalHereInfo: (NSString*) message{
    DLog(@"logPayPalHereInfo : %@",message);
};
/*!
 * Log fxn tracing events.
 * @param message The fully formatted log message.
 */
-(void)logPayPalHereTrace: (NSString*) message{
    DLog(@"logPayPalHereTrace : %@",message);
};
/*!
 * Log debug/verbose events.
 * @param message The fully formatted log message.
 */
-(void)logPayPalHereDebug: (NSString*) message{
    DLog(@"logPayPalHereDebug : %@",message);
};

/*!
 * Log a message considered to be indicative of an error for hardware interactions.
 * @param message The fully formatted log message.
 */
- (void)logPayPalHereHardwareError:(NSString *)message{
    DLog(@"logPayPalHereHardwareError : %@",message);
};

/*!
 * Log a message considered to be a potential issue affecting proper function for hardware interactions.
 * @param message The fully formatted log message.
 */
- (void)logPayPalHereHardwareWarning:(NSString *)message{
    DLog(@"logPayPalHereHardwareWarning : %@",message);
};

/*!
 * Log informational events for hardware interactions.
 * @param message The fully formatted log message.
 */
- (void)logPayPalHereHardwareInfo:(NSString *)message{
    DLog(@"logPayPalHereHardwareInfo : %@",message);
    
    if ([message rangeOfString:@"onWaitingForCardSwipe"].location != NSNotFound) {
        [iconReady setHidden:NO];
    }else{
        [iconReady setHidden:YES];
    }
    
    //    if ()
    
    
};

#pragma mark Table Delegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PosSection *section = [_cells objectAtIndex:indexPath.section];
    PosRow *row = [section objectAtIndex:indexPath.row];
    UITableViewCell *cell;
    
    if ([row.identifier isEqualToString:Charge]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            cell.accessoryType = row.accessoryType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            chargeBtn   = [[UIButton alloc]initWithFrame:CGRectMake(padding, padding, screenWidth - 2*padding, row.height-padding)];
            [chargeBtn  setBackgroundColor:colorActiveButton];
            chargeBtn.tintColor  = colorTintButton;
            [chargeBtn.titleLabel   setFont:[UIFont systemFontOfSize:fontSize]];
        }
        [chargeBtn  setTitle:[NSString stringWithFormat:@"Amount %@",amount] forState:UIControlStateNormal];
        [cell addSubview:chargeBtn];
        return cell;
    }
    else if ([row.identifier isEqualToString:CardReaderStatus]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            cell.accessoryType = row.accessoryType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            [self.cardReaderStatus setFrame:CGRectMake(0, 0, screenWidth, row.height)];
            [cell addSubview:self.cardReaderStatus];
        }
        
        return cell;
    }
    
    else if ([row.identifier isEqualToString:AudioJack]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            cell.accessoryType = row.accessoryType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            
            UIImageView *dongLe = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"PayPalHereSDK.bundle/choose_device_dongle@2x"]];
            [dongLe setFrame:CGRectMake((screenWidth - row.height)/2, 0, row.height, row.height)];
            iconReady = [[UIImageView alloc]initWithImage:[UIImage imageNamed:nameIconSelected]];
            [iconReady setFrame:CGRectMake(screenWidth/2 + row.height/2 - 30 , 10, 30, 30)];
            [cell addSubview:dongLe];
            [cell addSubview:iconReady];
        }
        return cell;
    }
    
    else if ([row.identifier isEqualToString:DockPort]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            cell.accessoryType = row.accessoryType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        return cell;
    }
    
    else if ([row.identifier isEqualToString:ChipAndPinBluetooth]) {
        cell = [tableView dequeueReusableCellWithIdentifier:row.identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:row.identifier];
            cell.accessoryType = row.accessoryType;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell setBackgroundColor:[UIColor clearColor]];
            UIImageView *emv = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"PayPalHereSDK.bundle/choose_device_emv@2x"]];
            [emv setFrame:CGRectMake((screenWidth - row.height)/2, 10, row.height - 10, row.height - 10)];
            iconReady = [[UIImageView alloc]initWithImage:[UIImage imageNamed:nameIconSelected]];
            [iconReady setFrame:CGRectMake(screenWidth/2 + row.height/2 - 30 , 10, 30, 30)];
            [cell addSubview:emv];
            [cell addSubview:iconReady];
        }
        return cell;
    }
    
    if (cell == nil) {
        cell = [UITableViewCell new];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    PosSection *section = [_cells objectAtIndex:indexPath.section];
    //    PosRow *row = [section objectAtIndex:indexPath.row];
}



#pragma mark Table DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_cells objectAtIndex:section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return ((PosRow*)[[_cells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]).height;
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.softwareUpgradeAlert && buttonIndex != self.softwareUpgradeAlert.cancelButtonIndex) {
        [self beginReaderUpgrade];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.softwareUpgradeAlert) {
        self.softwareUpgradeAlert = nil;
    }
}


- (void)updateUIWithActiveReader {
    PPHCardReaderMetadata *reader = [PayPalHereSDK sharedCardReaderManager].activeReader;
    NSString *message = @"No Reader Found!";
    UIColor *color = [UIColor blueColor];
    
    if (reader) {
        if (reader.upgradeIsManadatory) {
            message = @"Reader Upgrade Required!";
            color = [UIColor redColor];
        } else {
            message = reader.friendlyName ?: [[PPHReaderConstants stringForReaderType:reader.readerType] stringByAppendingString:@" Reader"];
            message = [message stringByAppendingString:@" Connected!"];
        }
    }
    
    [self.cardReaderStatus setText:message];
    [self.cardReaderStatus setTextColor:color];
}

- (void)dealloc{
    [self clearAnyExistingInfo];
    [[PayPalHereSDK sharedTransactionManager] deActivateReaderForPayments];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
