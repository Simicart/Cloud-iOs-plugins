//
//  ZReportCashInfoCell.m
//  SimiPOS
//
//  Created by mac on 2/26/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import "ZReportCashInfoCell.h"

@implementation ZReportCashInfoCell{
    float moneySystem;
}

- (void)awakeFromNib {
    // Initialization code
    self.btnCount.layer.cornerRadius =5.0;
    self.btnCount.backgroundColor = [UIColor barBackgroundColor];
    
     self.manualCountLabel.hidden=YES;
    self.manualCountTextField.delegate=self;
}

-(void)setHideManualCount{
    self.btnCount.hidden=YES;
    self.manualCountTextField.hidden=YES;    
    self.manualCountLabel.hidden=YES;
    self.differenceLabel.hidden=YES;
    self.numberOrderLabel.hidden =YES;
    self.recordGrandTotalLabel.hidden =YES;
        
}

-(void)setShowManualCount{
    self.btnCount.hidden=NO;
    self.manualCountTextField.hidden=NO;
    self.manualCountLabel.hidden=YES;
    self.differenceLabel.hidden=NO;
}

- (IBAction)countButtonClick:(id)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(manualCountEventClick)]){
        [self.delegate manualCountEventClick];
    }
}

-(void)setDataWithDict:(NSDictionary*)dict{
    
    if(dict){
        [self.paymentMethodWebView loadHTMLString:[NSString stringWithFormat:@"%@",[dict objectForKey:@"payment_name"]] baseURL:nil];
        self.numberOrderLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"order_count"]];
        self.recordGrandTotalLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"money_formated"]];
        self.manualCountLabel.text = @"";//[NSString stringWithFormat:@"%@",[dict objectForKey:@"money_system"]];
        self.differenceLabel.text = @"0";//[NSString stringWithFormat:@"%@",[dict objectForKey:@""]];
       // self.manualCountTextField.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"money_system"]];
        
        //Luu lai gia tri de tinh toan lan sau
        moneySystem = [NSString stringWithFormat:@"%@",[dict objectForKey:@"money_system"]].floatValue;
    }
}

#pragma mark - caculate difference
-(void)setDifferenceValue:(float)manualCount{
    float difference =fabsf(manualCount -moneySystem);
    self.differenceLabel.text =[NSString stringWithFormat:@"%.02f",difference];
}

-(void)caculateDiffenceValue{
    
    float manualCount =self.manualCountTextField.text.floatValue;
    float difference =manualCount -moneySystem;
    self.differenceLabel.text =[NSString stringWithFormat:@"%.02f",difference];
}

#pragma mark - UITextField Delegate

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range  replacementString:(NSString *)string{
    
    return [Utilities validateNumber:textField currentStringInput:string];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(self.delegate && [self.delegate respondsToSelector:@selector(disableScrollViewKeyboardShow)]){
        [self.delegate disableScrollViewKeyboardShow];
    }
    
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self caculateDiffenceValue];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self caculateDiffenceValue];
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
