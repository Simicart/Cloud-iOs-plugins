//
//  SearchCustomerModel.h
//  SimiPOS
//
//  Created by Vịnh Nguyễn Đức Thuỷ on 9/19/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "RetailerPosModel.h"

@interface SearchCustomerModel : RetailerPosModel

- (void)searchCustomerWidthKeySearch:(NSString *)keySearch index:(NSString*)index length:(NSString*)length;

@end
