//
//  PurchaseOrderFormController.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 11/28/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "WebposMultipaymentsFormController.h"
#import "Quote.h"
#import "MSFormTextFieldNumber.h"

@implementation WebposMultipaymentsFormController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.form.rowHeight = 54;
    
    // Initial Form Fields
    [self.form addField:@"TextFieldNumber" config:@{
                                                    @"name": @"cashforpos_ref_no",
                                                    @"title": NSLocalizedString(@"Cash", nil),
                                                    @"height": [NSNumber numberWithFloat:self.form.rowHeight]
                                                    }];
    [self.form addField:@"TextFieldNumber" config:@{
                                                    @"name": @"ccforpos_ref_no",
                                                    @"title": NSLocalizedString(@"Credit Card", nil),
                                                    @"height": [NSNumber numberWithFloat:self.form.rowHeight]
                                                    }];
    [self.form addField:@"TextFieldNumber" config:@{
                                                    @"name": @"cp1forpos_ref_no",
                                                    @"title": NSLocalizedString(@"Custom Payment 1", nil),
                                                    @"height": [NSNumber numberWithFloat:self.form.rowHeight]
                                                    }];
    [self.form addField:@"TextFieldNumber" config:@{
                                                    @"name": @"cp2forpos_ref_no",
                                                    @"title": NSLocalizedString(@"Custom Payment 2", nil),
                                                    @"height": [NSNumber numberWithFloat:self.form.rowHeight]
                                                    }];
    [self.form addField:@"TextFieldNumber" config:@{
                                                    @"name": @"codforpos_ref_no",
                                                    @"title": NSLocalizedString(@"Pay later", nil),
                                                    @"height": [NSNumber numberWithFloat:self.form.rowHeight]
                                                    }];
    [self.form addField:@"Boolean" config:@{
                                            @"name": @"is_invoice",
                                            @"title": NSLocalizedString(@"Mark as Paid?", nil),
                                            @"required": [NSNumber numberWithBool:NO],
                                            @"height": [NSNumber numberWithFloat:self.form.rowHeight]
                                            }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFormData:) name:@"MSFormUpdateData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formTextFieldNumberBegin:) name:@"MSFormTextFieldNumberBegin" object:nil];
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
    
 //   NSMutableDictionary * formData =self.form.formData;
 //   DLog(@"formData:%@",formData);

}

- (void)formTextFieldNumberBegin:(NSNotification *)note
{
    NSArray * formFields =self.form.formFields;
    
    float sumItems =0;
    
    for(id item in formFields){
        if([item isKindOfClass:[MSFormTextFieldNumber class]]){
            MSFormTextFieldNumber * textNumber =(MSFormTextFieldNumber*)item;
            sumItems += [textNumber.inputText.text floatValue];
        }
    }
    
    NSNumber *total = [[Quote sharedQuote] getGrandTotal]; // Gia tri Tong  don hang
    
    NSArray * objects = (NSArray *)[note object];
    UITextField * textField =(UITextField *)objects[0];
    
    if(textField){
        textField.text = [NSString stringWithFormat:@"%0.02f",total.floatValue -sumItems];
        
        NSString * methodName =[NSString stringWithFormat:@"%@",objects[1]];
        [self.form.formData setValue:textField.text forKey:methodName];
    }
    
    [self updatePaymentData];
    [self.checkout reloadButtonStatus];
    
  //  NSMutableDictionary * formData =self.form.formData;
   // DLog(@"formData:%@",formData);

}




@end
