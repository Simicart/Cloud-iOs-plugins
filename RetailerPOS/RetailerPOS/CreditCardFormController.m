//
//  CreditCardFormController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/28/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CreditCardFormController.h"
#import "CreditCardSwipe.h"
#import "UIView+InputNotification.h"
#import "Quote.h"
#import "Novocaine.h"

#include <stdio.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

#include "mslib.h"
#include "MSBuffer.h"

const char *audio_process( short *blocks, int len ) {
	msData *ms;
	const char *tmpStr;
    
	ms = ms_create( blocks, len );
    
	ms_peaks_find( ms );
	ms_peaks_filter_group( ms );
    
	ms_decode_peaks( ms );
	// tmpStr = ms_get_bitStream( ms );
	// printf("Decoded to bits:\n%s\n", tmpStr );
    
	if( ms_decode_bits( ms ) ) {
		// fprintf( stderr, "Warning: Appears to be unsuccessful swipe!\n" );
		// but will display the data we got anyway...
        return NULL;
	}
	tmpStr = ms_get_charStream( ms );
	// printf( "Decoded to chars:\n%s\n", tmpStr );
    
	ms = ms_free( ms );
    return tmpStr;
}

@interface CreditCardFormController()
@property (strong, nonatomic) UITextField *ccInfo;
@property (nonatomic) BOOL isPaymentPage;
- (NSDictionary *)monthOptions;
- (NSDictionary *)yearOptions;
@property (nonatomic, assign) MSBuffer *buf;
- (void)decodeCCInfo:(NSString *)inputText;
- (void)changeAudioInputSource;
@end

@implementation CreditCardFormController
@synthesize ccInfo, isPaymentPage, buf;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.form.rowHeight = 54;
    
    // Credit Card Swipe Input
    self.ccInfo = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.ccInfo.hidden= YES;
    self.ccInfo.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.ccInfo];
    [self.ccInfo performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.1];
    [self.ccInfo addTarget:self action:@selector(unserializeCCInfo) forControlEvents:UIControlEventEditingChanged];
    self.isPaymentPage = YES;
	
    // Initial form fields
    NSNumber *rowHeight = [NSNumber numberWithFloat:self.form.rowHeight];
    MSFormText *field = (MSFormText *)[self.form addField:@"Text" config:@{
        @"name": @"cc_owner",
        @"title": NSLocalizedString(@"Name On Card", nil),
        @"required": [NSNumber numberWithBool:NO],
        @"height": rowHeight
    }];
    // [field.inputText performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.25];
    [field.inputText addTarget:self action:@selector(swipeCreditCardInput:) forControlEvents:UIControlEventEditingChanged];
    
    [self.form addField:@"Select" config:@{
         @"name": @"cc_type",
         @"title": NSLocalizedString(@"Credit Card Type", nil),
         @"required": [NSNumber numberWithBool:NO],
         @"height": rowHeight,
         @"source": [self.method objectForKey:@"ccTypes"],
         @"value": [[[self.method objectForKey:@"ccTypes"] allKeys] objectAtIndex:0]
     }];
    
    field = (MSFormText *)[self.form addField:@"CCard" config:@{
         @"name": @"cc_number",
         @"title": NSLocalizedString(@"Credit Card Number", nil),
         @"required": [NSNumber numberWithBool:NO],
         @"height": rowHeight
     }];
    [field.inputText addTarget:self action:@selector(swipeCreditCardInput:) forControlEvents:UIControlEventEditingChanged];
    
    MSFormRow *expirationDate = (MSFormRow *)[self.form addField:@"Row" config:@{
         @"height": rowHeight
    }];
    
    [expirationDate addField:@"Select" config:@{
        @"name": @"cc_exp_month",
        @"title": NSLocalizedString(@"Expiration Month", nil),
        @"required": [NSNumber numberWithBool:NO],
        @"height": rowHeight,
        @"source": [self monthOptions],
    }];
    
    [expirationDate addField:@"Select" config:@{
        @"name": @"cc_exp_year",
        @"title": NSLocalizedString(@"Expiration Year", nil),
        @"required": [NSNumber numberWithBool:NO],
        @"height": rowHeight,
        @"source": [self yearOptions],
    }];
    
    field = (MSFormText *)[self.form addField:@"Number" config:@{
       @"name": @"cc_cid",
       @"title": NSLocalizedString(@"Card Verification Number", nil),
       @"required": [NSNumber numberWithBool:NO],
       @"height": rowHeight
    }];
    [field.inputText addTarget:self action:@selector(swipeCreditCardInput:) forControlEvents:UIControlEventEditingChanged];
    
    [self.form loadFormData:[Quote sharedQuote].payment];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startCheckout) name:@"GoToCheckoutPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backToShopping) name:@"GoToShoppingCartPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenCreditCardReader:) name:@"UIViewResignFirstResponder" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeCreditCardHeight:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnCreditCardHeight:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFormData:) name:@"MSFormUpdateData" object:nil];
    
    __weak CreditCardFormController *wself = self;
    __block int counter = 0;
    [[Novocaine audioManager] setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        if (wself.buf == nil) {
            wself.buf = new MSBuffer(100, numFrames);
        }
        short hasSignal = 0;
        if (counter == 0) {
            float *pointer = data;
            for (int i = 0; i < numFrames; i++) {
                if (fabsf(*pointer) > 0.01525) { // 0.015259 - Silent level
                    hasSignal++;
                    if (hasSignal > 5) {
                        break;
                    }
                } else {
                    hasSignal = 0;
                }
                pointer = pointer + numChannels;
            }
        }
        if (counter || hasSignal > 5) {
            if (numChannels > 1) {
                // Select only 1 channel
                float *destination = data + 1;
                float *source = destination + numChannels;
                for (int i = 0; i < numFrames; i++) {
                    memcpy(destination, source, sizeof(float));
                    destination = destination + 1;
                    source = source + numChannels;
                }
            }
            wself.buf->pushBuffer(data);
            if (counter > 97) {
                counter = 0;
                // [[Novocaine audioManager] pause];
                const char *result = audio_process(wself.buf->getBuffer(), 100 * numFrames);
                if (result != NULL) {
                    NSString *output = [NSString stringWithUTF8String:result];
                    // NSLog(@"%@", output);
                    NSString *input = @"";
                    for (int i = 0; i < [output length]; i++) {
                        NSString *lastInput = [output substringWithRange:NSMakeRange(i, 1)];
                        if ([lastInput isEqualToString:@"%"]
                            || [lastInput isEqualToString:@";"]
                        ) {
                            input = lastInput;
                        } else {
                            input = [input stringByAppendingString:lastInput];
                            if ([lastInput isEqualToString:@"?"]) {
                                [wself performSelectorOnMainThread:@selector(decodeCCInfo:) withObject:input waitUntilDone:NO];
                            }
                        }
                    }
                }
                // [[Novocaine audioManager] play];
            } else {
                counter++;
            }
        }
    }];
    if ([[Novocaine audioManager] isCCardSwiper]) {
        [[Novocaine audioManager] play];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAudioInputSource) name:@"MSAudioChangeInputSource" object:nil];
}

- (void)changeAudioInputSource
{
    if (self.isPaymentPage && [[Novocaine audioManager] isCCardSwiper]) {
        [[Novocaine audioManager] play];
    } else {
        [[Novocaine audioManager] pause];
    }
}

- (void)startCheckout
{
    self.isPaymentPage = YES;
    [self.ccInfo becomeFirstResponder];
    if (![[Novocaine audioManager] playing] && [[Novocaine audioManager] isCCardSwiper]) {
        [[Novocaine audioManager] play];
    }
}

- (void)backToShopping
{
    self.isPaymentPage = NO;
    if ([[Novocaine audioManager] playing]) {
        [[Novocaine audioManager] pause];
    }
}

- (void)listenCreditCardReader:(NSNotification *)note
{
    if (!self.isPaymentPage) {
        return;
    }
    UIView *responder = [UIView firstResponder:nil];
    if (responder == nil) {
        [self.ccInfo becomeFirstResponder];
        return;
    }
    id sender = [note object];
    if (![responder isEqual:self.ccInfo]
        && [responder isEqual:sender]
    ) {
        [self.ccInfo becomeFirstResponder];
        return;
    }
}

- (void)resizeCreditCardHeight:(NSNotification *)note
{
    CGRect frame = self.form.frame;
    frame.size.height -= 274;
    self.form.frame = frame;
}

- (void)returnCreditCardHeight:(NSNotification *)note
{
    CGRect frame = self.form.frame;
    frame.size.height += 274;
    self.form.frame = frame;
}

- (NSDictionary *)monthOptions
{
    return @{
        [NSNumber numberWithInt:1]: NSLocalizedString(@"01 - January", nil),
        [NSNumber numberWithInt:2]: NSLocalizedString(@"02 - February", nil),
        [NSNumber numberWithInt:3]: NSLocalizedString(@"03 - March", nil),
        [NSNumber numberWithInt:4]: NSLocalizedString(@"04 - April", nil),
        [NSNumber numberWithInt:5]: NSLocalizedString(@"05 - May", nil),
        [NSNumber numberWithInt:6]: NSLocalizedString(@"06 - June", nil),
        [NSNumber numberWithInt:7]: NSLocalizedString(@"07 - July", nil),
        [NSNumber numberWithInt:8]: NSLocalizedString(@"08 - August", nil),
        [NSNumber numberWithInt:9]: NSLocalizedString(@"09 - September", nil),
        [NSNumber numberWithInt:10]: NSLocalizedString(@"10 - October", nil),
        [NSNumber numberWithInt:11]: NSLocalizedString(@"11 - November", nil),
        [NSNumber numberWithInt:12]: NSLocalizedString(@"12 - December", nil),
    };
}

- (NSDictionary *)yearOptions
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy"];
    NSInteger currentYear = [[dateFormater stringFromDate:[NSDate date]] integerValue];
    NSMutableDictionary *yearOptions = [[NSMutableDictionary alloc] init];
    for (NSInteger i = 0; i < 11; i++) {
        [yearOptions setObject:[NSString stringWithFormat:@"%d", currentYear] forKey:[NSNumber numberWithInt:currentYear]];
        currentYear++;
    }
    return yearOptions;
}

- (void)swipeCreditCardInput:(id)sender
{
    NSString *inputText = [(UITextField *)sender text];
    if (inputText == nil || inputText.length == 0) {
        return;
    }
    
    NSRange range = [inputText rangeOfString:@"%"];
    NSRange second = [inputText rangeOfString:@";"];
    NSString *lastInput = [inputText substringFromIndex:inputText.length - 1];
    if ([lastInput isEqualToString:@"%"]
        || [lastInput isEqualToString:@";"]
    ) {
        ((UITextField *)sender).text = [inputText substringToIndex:inputText.length - 1];
        // Start Swipe Input
        self.ccInfo.text = lastInput;
        [self.ccInfo becomeFirstResponder];
    } else if (range.location != NSNotFound) {
        ((UITextField *)sender).text = [[inputText substringToIndex:range.location] stringByAppendingString:[inputText substringFromIndex:range.location+1]];
        self.ccInfo.text = @"%";
        [self.ccInfo becomeFirstResponder];
    } else if (second.location != NSNotFound) {
        ((UITextField *)sender).text = [[inputText substringToIndex:second.location] stringByAppendingString:[inputText substringFromIndex:second.location+1]];
        self.ccInfo.text = @";";
        [self.ccInfo becomeFirstResponder];
    }
    
    if ([sender isKindOfClass:[MSFormCCard class]]) {
        [(MSFormCCard *)sender changeInputCard];
    }
}

- (void)unserializeCCInfo
{
    NSString *inputText = self.ccInfo.text;
    if (inputText == nil || inputText.length == 0) {
        return;
    }
    NSString *lastInput = [inputText substringFromIndex:inputText.length - 1];
    if ([lastInput isEqualToString:@"%"]
        || [lastInput isEqualToString:@";"]
    ) {
        self.ccInfo.text = lastInput;
        return;
    }
    if (![lastInput isEqualToString:@"?"]) {
        return;
    }
    // Unserialize Credit Card Info
    NSDictionary *swipeCCInfo = [CreditCardSwipe decodeSerialized:self.ccInfo.text];
    MSFormCCard *field = (MSFormCCard *)[self.form getFieldByName:@"cc_number"];
    [field addCCNumberMask:[swipeCCInfo objectForKey:@"cc_number"]];
    
    // Update credit card inputs
    [self.form.formData addEntriesFromDictionary:swipeCCInfo];
    [self.form reloadData];
    
    // Clear input cache
    self.ccInfo.text = nil;
    // [self.ccInfo resignFirstResponder];
    [self updatePaymentData];
    [self.checkout reloadButtonStatus];
}

- (void)decodeCCInfo:(NSString *)inputText
{
    // Unserialize Credit Card Info
    NSDictionary *swipeCCInfo = [CreditCardSwipe decodeSerialized:inputText];
    MSFormCCard *field = (MSFormCCard *)[self.form getFieldByName:@"cc_number"];
    [field addCCNumberMask:[swipeCCInfo objectForKey:@"cc_number"]];
    
    // Update credit card inputs
    [self.form.formData addEntriesFromDictionary:swipeCCInfo];
    [self.form reloadData];
    
    // Clear input cache
    self.ccInfo.text = nil;
    // [self.ccInfo resignFirstResponder];
    [self updatePaymentData];
    [self.checkout reloadButtonStatus];
}

- (void)updateFormData:(NSNotification *)note
{
    id sender = [note object];
    if (sender == nil
        || ![sender isEqual:self.form]
    ) {
        return;
    }
    [self updatePaymentData];
    [self.checkout reloadButtonStatus];
}

@end
