 //
//  IDTechSwipeViewController.m
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 6/22/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "IDTechSwipeViewController.h"
#import "Quote.h"
#import "CreditCardSwipe.h"
#import "CreditCard-Validator.h"

@interface IDTechSwipeViewController (){
    BOOL isRequireCVV;
}
@property (strong, nonatomic) UILabel *statusCardReader;
@property (nonatomic) BOOL isPaymentPage;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *sessionToken;
@end

@implementation IDTechSwipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(purchaseWithCreditCardInfo) name:@"startPaymentCreditCard" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveCardData) name:@"MSFormUpdateData" object:nil];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(backToPaymentView) name:@"gotoShoppingCartPage" object:nil];

    self.form.rowHeight = 54;

    // Credit Card Swipe Input
    if(WINDOW_WIDTH > 1024){
        [self.form setFrame:CGRectMake(0, 54, 700, self.view.bounds.size.height - 54)];
        self.statusCardReader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 700, 54)];
    }else{
        [self.form setFrame:CGRectMake(0, 54, 496, self.view.bounds.size.height - 54)];
        self.statusCardReader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 496, 54)];
    }
    self.statusCardReader.hidden = NO;
    self.statusCardReader.text = @"Card Reader not connect";
    self.statusCardReader.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.statusCardReader];

    self.isPaymentPage = YES;
    
    // Initial form fields
    NSNumber *rowHeight = [NSNumber numberWithFloat:self.form.rowHeight];
    
    
    if ([self.method objectForKey:@"cvv_enable"] != nil) {
        isRequireCVV = [[self.method objectForKey:@"cvv_enable"] boolValue];
    }else{
        isRequireCVV = NO;
    }
    
    
    [self.form addField:@"Text" config:@{
                                       @"name": @"cc_owner",
                                       @"title": NSLocalizedString(@"Name On Card", nil),
                                       @"required": [NSNumber numberWithBool:NO],
                                       @"height": rowHeight
                                       }];

    MSFormRow *cardNumber = (MSFormRow *)[self.form addField:@"Row"
                                                      config:@{
                                                               @"height": rowHeight
                                                             }];
    
    
    [cardNumber addField:@"Select"
                  config:@{
                            @"name": @"cc_type",
                            @"title": NSLocalizedString(@"Credit Card Type", nil),
                            @"required": [NSNumber numberWithBool:YES],
                            @"height": rowHeight,
                            @"source": [self.method objectForKey:@"ccTypes"],
                            @"value": [[[self.method objectForKey:@"ccTypes"] allKeys] objectAtIndex:0]
                            }];
    
    
  
    [cardNumber addField:@"CCNumber"
                  config:@{
                          @"name": @"cc_number",
                          @"title": NSLocalizedString(@"Credit Card Number", nil),
                          @"required": [NSNumber numberWithBool:YES],
                          @"height": rowHeight
                          }];
    

    MSFormRow *expirationDate = (MSFormRow *)[self.form addField:@"Row"
                                                          config:@{
                                                                 @"height": rowHeight
                                                                 }];

    [expirationDate addField:@"CCDate" config:@{
                                                @"name": @"cc_exp_month",
                                                @"name1": @"cc_exp_year",
                                                @"title": NSLocalizedString(@"MM/YY", nil),
                                                @"required": [NSNumber numberWithBool:YES],
                                                @"height": rowHeight,
                                                }];

    [expirationDate addField:@"Cvv" config:@{
                                             @"name": @"cc_cid",
                                             @"title": NSLocalizedString(@"CVV", nil),
                                             @"required": [NSNumber numberWithBool:isRequireCVV],
                                             @"height": rowHeight
                                             }];
    
    [self.form addField:@"Boolean" config:@{
                                            @"name": @"is_swipe_card",
                                            @"title": NSLocalizedString(@"Payment with Swipe Card", nil),
                                            @"required": [NSNumber numberWithBool:YES],
                                            @"height": rowHeight,
                                            @"value" : [NSNumber numberWithBool:YES]
                                            }];

    [self.form setHidden:NO];
    
    [uniMag enableLogging:true];
    self.uniMagPos = [[uniMag alloc] init];
    [self uniMag_registerObservers:true];
    [self.uniMagPos setAutoConnect:true];
    [self.uniMagPos setSwipeTimeoutDuration:0];
    [self.uniMagPos setAutoAdjustVolume:true];
    
//    [self uniMag_activate];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UniMag SDK activation/deactivation -

- (void)uniMag_activate {
//    CFTimeInterval endTime = CACurrentMediaTime() + 1;
//    while (CACurrentMediaTime() < endTime) {
//        // Wait 2 second
//    }
    [self.uniMagPos startUniMag:true];
//    [self uniMag_registerObservers:true];
}

-(void)uniMag_deactivate {
//    if (self.uniMagPos != NULL && self.uniMagPos.getConnectionStatus)
//    {
        [self.uniMagPos startUniMag:false];
//    }
    
//    [self uniMag_registerObservers:false];
}

#pragma mark - UniMag SDK observers -

-(void) uniMag_registerObservers:(BOOL) reg {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (reg) {
        [nc addObserver:self selector:@selector(umDevice_attachment:) name:uniMagAttachmentNotification object:nil];
        [nc addObserver:self selector:@selector(umDevice_detachment:) name:uniMagDetachmentNotification object:nil];
        [nc addObserver:self selector:@selector(umConnection_lowVolume:) name:uniMagInsufficientPowerNotification object:nil];
        [nc addObserver:self selector:@selector(umConnection_starting:) name:uniMagPoweringNotification object:nil];
        [nc addObserver:self selector:@selector(umConnection_timeout:) name:uniMagTimeoutNotification object:nil];
        [nc addObserver:self selector:@selector(umConnection_connected:) name:uniMagDidConnectNotification object:nil];
        [nc addObserver:self selector:@selector(umConnection_disconnected:) name:uniMagDidDisconnectNotification object:nil];
        [nc addObserver:self selector:@selector(umSwipe_starting:) name:uniMagSwipeNotification object:nil];
        [nc addObserver:self selector:@selector(umSwipe_timeout:) name:uniMagTimeoutSwipeNotification object:nil];
        [nc addObserver:self selector:@selector(umDataProcessing:) name:uniMagDataProcessingNotification object:nil];
        [nc addObserver:self selector:@selector(umSwipe_invalid:) name:uniMagInvalidSwipeNotification object:nil];
        [nc addObserver:self selector:@selector(umSwipe_receivedSwipe:) name:uniMagDidReceiveDataNotification object:nil];
        [nc addObserver:self selector:@selector(umCommand_starting:) name:uniMagCmdSendingNotification object:nil];
        [nc addObserver:self selector:@selector(umCommand_timeout:) name:uniMagCommandTimeoutNotification object:nil];
        [nc addObserver:self selector:@selector(umCommand_receivedResponse:) name:uniMagDidReceiveCmdNotification object:nil];
        [nc addObserver:self selector:@selector(umSystemMessage:) name:uniMagSystemMessageNotification object:nil];
    }
    else {
        [nc removeObserver:self];
    }
    
}

//called when uniMag is physically attached
- (void)umDevice_attachment:(NSNotification *)notification {
    CFTimeInterval endTime = CACurrentMediaTime() + 2
    ;
    while (CACurrentMediaTime() < endTime) {
        // Wait 2 second
    }
    [self uniMag_activate];
}

//called when uniMag is physically detached
- (void)umDevice_detachment:(NSNotification *)notification {
    [self uniMag_deactivate];
}

//called when attempting to start the connection task but iDevice's headphone playback volume is too low
- (void)umConnection_lowVolume:(NSNotification *)notification {
}

//called when successfully starting the connection task
- (void)umConnection_starting:(NSNotification *)notification {
}

//called when SDK failed to handshake with reader in time. ie, the connection task has timed out
- (void)umConnection_timeout:(NSNotification *)notification {
    [self.uniMagPos startUniMag:true];
}

////called when the connection task is successful. SDK's connection state changes to true
- (void)umConnection_connected:(NSNotification *)notification {
    DLog(@"umConnection_connected ------ %hhd",self.uniMagPos.getConnectionStatus);
    
    [self.uniMagPos requestSwipe];
    self.statusCardReader.text = @"Card Reader connected";
    [self.statusCardReader setTextColor:[UIColor greenColor]];
}

//called when SDK's connection state changes to false. This happens when reader becomes
// physically detached or when a disconnect API is called
- (void)umConnection_disconnected:(NSNotification *)notification {
    self.statusCardReader.text = @"Card Reader not connect";
    [self.statusCardReader setTextColor:[UIColor blackColor]];
}

#pragma mark swipe task

//called when the swipe task is successfully starting, meaning the SDK starts to
// wait for a swipe to be made
- (void)umSwipe_starting:(NSNotification *)notification {
}

//called when the SDK hasn't received a swipe from the device within a configured
// "swipe timeout interval".
- (void)umSwipe_timeout:(NSNotification *)notification {
}

//called when the SDK has read something from the uniMag device
// (eg a swipe, a response to a command) and is in the process of decoding it
// Use this to provide an early feedback on the UI
- (void)umDataProcessing:(NSNotification *)notification {
}

//called when SDK failed to read a valid card swipe
- (void)umSwipe_invalid:(NSNotification *)notification {
    [self.uniMagPos requestSwipe];
}

//called when SDK received a swipe successfully
- (void)umSwipe_receivedSwipe:(NSNotification *)notification {
    if ([[self.form.formData objectForKey:@"is_swipe_card"] boolValue]) {
        @try {
            NSData *cardData = [notification object];
            NSString *strData = [[NSString alloc] initWithData:cardData encoding:NSASCIIStringEncoding];
            NSDictionary *dictCardSwipe = [NSDictionary new];
            dictCardSwipe = [CreditCardSwipe decodeSerialized:strData];
            
            [self.form.formData setObject:[dictCardSwipe valueForKey:@"cc_owner"] forKey:@"cc_owner"];
            [self.form.formData setObject:[dictCardSwipe valueForKey:@"cc_number"] forKey:@"cc_number"];
//            [self.form.formData setObject:[NSString stringWithFormat:@"%@",[dictCardSwipe valueForKey:@"cc_cid"]] forKey:@"cc_cid"];
            [self.form.formData setObject:[NSString stringWithFormat:@"%@",[dictCardSwipe valueForKey:@"cc_type"]] forKey:@"cc_type"];
            [self.form.formData setObject:[NSString stringWithFormat:@"%@",[dictCardSwipe valueForKey:@"cc_exp_year"]] forKey:@"cc_exp_year"];
            [self.form.formData setObject:[NSString stringWithFormat:@"%@",[dictCardSwipe valueForKey:@"cc_exp_month"]] forKey:@"cc_exp_month"];
            
            [self.form reloadData];
            NSString *cardNumber = [self.form.formData valueForKey:@"cc_number"];
            if ([CreditCard_Validator checkCardBrandWithNumber:cardNumber] == CreditCardBrandUnknown) {
                UIAlertView *checkCardAlertView = [[UIAlertView alloc] initWithTitle:@"Card Type" message:@"Unknown Card" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [checkCardAlertView show];
            }else {
                [self saveCardData];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"swipeCardDataReady" object:nil];
            }
        } @catch (NSException *exception) {
            DLog(@"Swiper Again");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:NSLocalizedString(@"Swipe Card Again", @"")
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    [self.uniMagPos requestSwipe];
}

#pragma mark command task

//called when SDK successfully starts to send a command. SDK starts the command
// task
- (void)umCommand_starting:(NSNotification *)notification {
}

//called when SDK failed to receive a command response within a configured
// "command timeout interval"
- (void)umCommand_timeout:(NSNotification *)notification {
}

//called when SDK successfully received a response to a command
- (void)umCommand_receivedResponse:(NSNotification *)notification {
}

#pragma mark -
#pragma mark Private Method

- (void) purchaseWithCreditCardInfo {
    if ([self.form.formData valueForKey:@"cc_number"] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"A card number is required to continue.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"creditCardPaymentFail" object:nil];
        return;
    }
    
    
    if ([CreditCard_Validator checkCardBrandWithNumber:[self.form.formData valueForKey:@"cc_number"]] == CreditCardBrandUnknown) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"Please enter a valid card number.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"creditCardPaymentFail" object:nil];
        return;
    }
    
    if (    [self.form.formData valueForKey:@"cc_exp_month"] == nil
        ||  [self.form.formData valueForKey:@"cc_exp_year"] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"An expiration date is required to continue.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"creditCardPaymentFail" object:nil];
        return;
    }
    
    if ([self.form.formData valueForKey:@"cc_cid"] == nil && isRequireCVV) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"CVV number is required to continue.", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"creditCardPaymentFail" object:nil];
        return;
    }
    
    //Ravi payment authorize.net
    /*
     Server thực hiện payment, app chỉ đảm nhiệm việc đưa thông tin lên cho server
     */

    [[NSNotificationCenter defaultCenter] postNotificationName:@"paymentCreditCardSuccess" object:nil];
    return;
    //End
}


- (void)saveCardData{
    if (self.form.formData != nil) {
        [[Quote sharedQuote].payment setValue:[self.form.formData valueForKey:@"cc_cid"] forKey:@"cc_cid"];
        [[Quote sharedQuote].payment setValue:[self.form.formData valueForKey:@"cc_type"] forKey:@"cc_type"];
        [[Quote sharedQuote].payment setValue:[self.form.formData valueForKey:@"cc_owner"] forKey:@"cc_owner"];
        [[Quote sharedQuote].payment setValue:[self.form.formData valueForKey:@"cc_number"] forKey:@"cc_number"];
        [[Quote sharedQuote].payment setValue:[self.form.formData valueForKey:@"cc_exp_year"] forKey:@"cc_exp_year"];
        [[Quote sharedQuote].payment setValue:[self.form.formData valueForKey:@"cc_exp_month"] forKey:@"cc_exp_month"];
    }
}

- (void)backToPaymentView{
    [self clearPayment];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
//    [self backToPaymentView];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"uncheckPaymentMethod" object:nil];
}

- (void) clearPayment{
    [[Quote sharedQuote].payment removeObjectForKey:@"cc_cid"];
    [[Quote sharedQuote].payment removeObjectForKey:@"cc_type"];
    [[Quote sharedQuote].payment removeObjectForKey:@"cc_owner"];
    [[Quote sharedQuote].payment removeObjectForKey:@"cc_number"];
    [[Quote sharedQuote].payment removeObjectForKey:@"cc_exp_year"];
    [[Quote sharedQuote].payment removeObjectForKey:@"cc_exp_month"];
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
