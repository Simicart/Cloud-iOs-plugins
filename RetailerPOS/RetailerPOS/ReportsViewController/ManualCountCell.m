//
//  ManualCountCellTableViewCell.m
//  RetailerPOS
//
//  Created by mac on 2/28/16.
//  Copyright © 2016 David Nguyen. All rights reserved.
//

#import "ManualCountCell.h"

@implementation ManualCountCell

- (void)awakeFromNib {
    // Initialization code
    
    self.countTextField.delegate=self;
    self.sumTextField.delegate=self;
}

-(void)setData:(Denomination *) denomination{
    
    self.noteName.text =denomination.deno_name;
    self.noteValue.text =denomination.deno_value;
    
}

#pragma mark - UITextFieldDelegat

#pragma mark Upcase String TextField Input
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range  replacementString:(NSString *)string{
    
    return [Utilities validateNumber:textField currentStringInput:string];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self caculateSumManual:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self caculateSumManual:textField];
    
    return  YES;
}

-(void)caculateSumManual:(UITextField *)textField{
    
    if(textField==self.countTextField){
        @try {
            float countNum =self.countTextField.text.floatValue;
            float noteValue =self.noteValue.text.floatValue;
            self.sumTextField.text=[NSString stringWithFormat:@"%.02f",countNum*noteValue];
        }
        @catch (NSException *exception) {
            DLog(@"%@",exception.description);
            self.sumTextField.text=@"";
        }
    }
    
    [textField resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_CACULATE_SUM_MANUAL" object:nil];
}

@end
