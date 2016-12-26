//
//  DetailProductOptions.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/16/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "DetailProductOptions.h"
#import "ProductViewDetailController.h"
#import "Quote.h"
#import "DetailProductOptionsMaster.h"
#import "DetailProductOptionsDetail.h"
#import "MSFramework.h"

@interface DetailProductOptions ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)addProductToCartThread:(id)sender;
@end

@implementation DetailProductOptions
@synthesize animation;

- (id)init
{
    if (self = [super init]) {
        self.masterOptions = [DetailProductOptionsMaster new];
        self.detailOptions = [DetailProductOptionsDetail new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.detailOptions willMoveToParentViewController:nil];
    [self.detailOptions.view removeFromSuperview];
    [self.detailOptions removeFromParentViewController];
}

- (CGSize)reloadContentSize
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NSArray *options = [self.product getOptions];
    
    self.masterOptions.masterOptions = options;
    
    CGFloat width = 748;
    CGFloat height = 44 * [options count];
    
    self.masterOptions.tableWidth = width;
    self.masterOptions.view.frame = CGRectMake(0, 0, width, height);
    
    height += 64;
    [self.masterOptions.tableView reloadData];
    [(DetailProductOptionsMaster *)self.masterOptions addCartButton];
    
    return CGSizeMake(width, height);
}

- (void)addProductToCart:(id)sender
{
    if (![self validateOptions]) {
        return;
    }
    // Add to Cart
    animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    animation.frame = CGRectMake(((UIView *)sender).frame.size.width - 44, 0, 44, 44);
    [(UIView *)sender addSubview:animation];
    
    [(UIButton *)sender setEnabled:NO];
    [animation startAnimating];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(addProductToCartThread:) object:sender] start];
}

- (void)addProductToCartThread:(id)sender
{
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:QuoteEndRequestNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.parentViewController performSelectorOnMainThread:@selector(closeDetailPage) withObject:nil waitUntilDone:YES];
    }];
    [[Quote sharedQuote] addProduct:self.product withOptions:self.productOptions];
    
    [[NSNotificationCenter defaultCenter] removeObserver:success];
    [animation stopAnimating];
    [(UIButton *)sender setEnabled:YES];
}

@end
