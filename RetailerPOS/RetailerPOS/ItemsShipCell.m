//
//  ItemsShipCell.m
//  RetailerPOS
//
//  Created by mac on 3/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ItemsShipCell.h"

#define REGEX_NUMERIC @"[0-9]"
#define MESSAGE_CHECK_VALUE @"Qty is illegal"

@implementation ItemsShipCell
{
    float _qtyOrdered;
    float _qtyShip;
    float _qtyRefund;
    float _qtyCancel;
}

- (void)awakeFromNib {
    
    self.txtQtyShip.delegate=self;
}

#pragma mark Upcase String TextField Input
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range  replacementString:(NSString *)string{
    
    BOOL checkNumber =[Utilities validateNumber:textField currentStringInput:string];
    
    if(checkNumber ==NO){
        return checkNumber ;
    }
    
    //Xoa
    if([string isEqualToString:@""]){
        
        if(self.txtQtyShip.text.length == 1){
            [self.delegate enableShipButton:NO];
            return YES;
        }
    }
    
    
    NSString * valueInput =[self.txtQtyShip.text stringByAppendingString:string];
 
    BOOL checkQtyInput= [self validateQtyShip:valueInput];
    if(checkQtyInput ==NO){
        [self.txtQtyShip showErrorIconForMsg:MESSAGE_CHECK_VALUE];
        // [self.delegate enableShipButton:NO];
        
       [self checkValueInput];
    }else{
        [self.txtQtyShip dismissPopup];
        [self.delegate enableShipButton:YES];
    }
    
    return checkQtyInput;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    [self checkValueInput];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
   
    [self checkValueInput];
    return YES;
}

-(void)checkValueInput{
    BOOL checkQtyInput= [self validateQtyShip:self.txtQtyShip.text];
    if(checkQtyInput ==NO){
        [self.txtQtyShip showErrorIconForMsg:MESSAGE_CHECK_VALUE];
        [self.delegate enableShipButton:NO];
    }else{
        [self.txtQtyShip dismissPopup];
        [self.delegate enableShipButton:YES];
    }
}


-(void)setData:(NSDictionary *)dict{
    if(dict){
        
        self.lblProduct.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
        self.lblSku.text =[NSString stringWithFormat:@"%@",[dict objectForKey:@"sku"]];
        
        NSString * qtyOrder =[NSString stringWithFormat:@"%@",[dict objectForKey:@"qty_ordered"]];
        _qtyOrdered =qtyOrder.floatValue;
        self.lblQtyOrdered.text =[self convertFloatFormat:_qtyOrdered];
        
        NSString * qtyShip =[NSString stringWithFormat:@"%@",[dict objectForKey:@"qty_shipped"]];
        _qtyShip =qtyShip.floatValue;
        self.lblShipped.text =[self convertFloatFormat:_qtyShip];
        
        NSString * qtyRefund =[NSString stringWithFormat:@"%@",[dict objectForKey:@"qty_refunded"]];
        _qtyRefund=qtyRefund.floatValue;
        self.lblRefunded.text =[self convertFloatFormat:_qtyRefund];
        
        NSString * qtyCancel =[NSString stringWithFormat:@"%@",[dict objectForKey:@"qty_canceled"]];
        _qtyCancel=qtyCancel.floatValue;
        self.lblCanceled.text =[self convertFloatFormat:_qtyCancel];
        
        self.itemId =[NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
        
        
        
        
        float qtyCompare =_qtyOrdered - _qtyShip-_qtyCancel-_qtyRefund;
        
        if(qtyCompare == 0){
            self.txtQtyShip.hidden =YES;
        }else{
            self.txtQtyShip.text =[self convertFloatFormat:qtyCompare];
        }        
    }
}

-(NSString *)convertFloatFormat:(float)valueFloat{
    return [NSString stringWithFormat:@"%@",[NSNumber numberWithFloat:valueFloat]];
}

-(BOOL)validateQtyShip:(NSString *)valueInput{
    
    if(valueInput.length >0 && ![valueInput isEqualToString:@"0"]){
        
        float qtyShipInput =valueInput.floatValue;
        float qtyCompare =_qtyOrdered - _qtyShip-_qtyCancel-_qtyRefund;
        
        if(qtyShipInput <=qtyCompare){
            return YES;
        }else{
             return NO;
        }
       
    }else{
        return NO;
    }
}


@end
