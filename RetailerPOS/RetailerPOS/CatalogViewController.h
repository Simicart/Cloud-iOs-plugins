//
//  CatalogViewController.h
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 8/3/16.
//  Copyright (c) 2016 Mar Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CatalogViewController : UIViewController

+(CatalogViewController *)sharedInstance;

-(void)goToCheckoutPage;
-(void)goToShoppingCartPage;
-(CGRect)translationFrame:(CGRect)frame withX:(CGFloat)x withY:(CGFloat)y;
-(CGRect)resizeFrame:(CGRect)frame width:(CGFloat)width height:(CGFloat)height;

-(void)reloadProductState;

@end
