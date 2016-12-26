//
//  ItemsShipCell.h
//  RetailerPOS
//
//  Created by mac on 3/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldValidator.h"

@protocol ItemsShipCellDelegate <NSObject>

-(void)enableShipButton:(BOOL)status;
@end

@interface ItemsShipCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) id<ItemsShipCellDelegate>delegate;

@property (strong, nonatomic) NSString * itemId;
@property (weak, nonatomic) IBOutlet UILabel *lblProduct;
@property (weak, nonatomic) IBOutlet UILabel *lblSku;
@property (weak, nonatomic) IBOutlet UILabel *lblQtyOrdered;
@property (weak, nonatomic) IBOutlet UILabel *lblShipped;
@property (weak, nonatomic) IBOutlet UILabel *lblRefunded;
@property (weak, nonatomic) IBOutlet UILabel *lblCanceled;
@property (weak, nonatomic) IBOutlet TextFieldValidator *txtQtyShip;

-(void)setData:(NSDictionary *)dict;

//-(BOOL)validateQtyShip;

@end
