//
//  SaveCustomerInfoModel.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/28/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface SaveCustomerInfoModel : RetailerPosModel

- (void)saveCustomerInfoWithData:(NSDictionary*) data;

@end