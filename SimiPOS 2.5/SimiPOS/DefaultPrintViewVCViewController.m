//
//  DefaultPrintViewVCViewController.m
//  SimiPOS
//
//  Created by Trueplus02 on 3/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "DefaultPrintViewVCViewController.h"
#import "APIManager.h"
#import "Quote.h"

@interface DefaultPrintViewVCViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;

@end

@implementation DefaultPrintViewVCViewController
@synthesize animation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Title & Buttons
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPrint)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Print Order # %@", nil), [self.order getIncrementId]];
    
    UIBarButtonItem *printBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printOrderAction)];
    self.navigationItem.rightBarButtonItem = printBtn;
 
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = CGRectMake(0, 0, 44, 44);
        animation.center=CGPointMake(self.webView.center.x+130, self.webView.center.y);
        animation.color = [UIColor grayColor];
        [self.webView addSubview:animation];
    }
    [animation startAnimating];

    [[APIManager shareInstance] getOrderPrintLink:[self.order getIncrementId] Callback:^(BOOL success, id result) {
        if(success && [result objectForKey:@"data"]){
            NSString *urlString = [result objectForKey:@"data"];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        }
    }];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [animation stopAnimating];
}

- (void)cancelPrint
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - print order
- (void)printOrderAction
{
    //to attach the image and text with sharing
    UIImage *image=[Utilities imageWithView:self.webView];
    NSString *str=[NSString stringWithFormat:@"Order #%@",[self.order getIncrementId]];
    NSArray *postItems=@[str,image];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    
    // Change Rect to position Popover
    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 1, 1)inView:self.view permittedArrowDirections:0 animated:YES];
}
@end
