//
//  ShowContentDetail.m
//  RetailerPOS
//
//  Created by mac on 3/4/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "ShowContentDetail.h"

@interface ShowContentDetail ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation ShowContentDetail


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.webView.layer.cornerRadius =5.0;
    self.webView.layer.borderColor =[UIColor colorWithRed:1.000f green:0.600f blue:0.000f alpha:1.00f].CGColor;
    self.webView.layer.borderWidth =1.0;
    
    if(self.contentString && self.contentString.length >0){
      [self.webView loadHTMLString:self.contentString baseURL:nil];
    }
}



@end
