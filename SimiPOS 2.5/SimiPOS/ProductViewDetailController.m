//
//  ProductViewDetailController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 1/6/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "ProductViewDetailController.h"
#import "ProductImagesView.h"
#import "Price.h"
#import "Quote.h"
#import "MSFramework.h"
#import "DetailProductOptions.h"

@interface ProductViewDetailController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)loadViewProductDetail;
- (void)viewProductDetail;

- (void)addProductToCartThread:(id)sender;
@end

@implementation ProductViewDetailController
@synthesize product = _product, animation;
@synthesize detailView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 768, 702)];
    detailView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WINDOW_HEIGHT, WINDOW_HEIGHT -66)];
    [self.view addSubview:detailView];
    
    // Add navigation button
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(closeDetailPage)];
    
    self.title = [self.product getName];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Start animation and load product detail
    animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    animation.frame = CGRectMake(0, 0, WINDOW_HEIGHT, 100);
    [detailView addSubview:animation];
    [animation startAnimating];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadViewProductDetail) object:nil] start];
}

- (void)closeDetailPage
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClosePopupWindow" object:nil];
    }];
}

// Load view product detail
- (void)loadViewProductDetail
{
    Product *detailProduct = [Product new];
    [detailProduct loadDetail:[self.product getId]];
    [animation stopAnimating];
    if (![detailProduct getId]) {
        return;
    }
    self.product = detailProduct;
    [self performSelectorOnMainThread:@selector(viewProductDetail) withObject:nil waitUntilDone:NO];
}

- (void)viewProductDetail
{
    // Generate view detail
    CGFloat width = 748;
    CGFloat height = 10;
    
    // Product name label
    UILabel *productName = [[UILabel alloc] initWithFrame:CGRectMake(10, height, width, 36)];
    productName.text = [self.product getName];
    productName.font = [UIFont boldSystemFontOfSize:24];
    [self.detailView addSubview:productName];
    height += 36;
    
    UILabel *productSKU = [[UILabel alloc] initWithFrame:CGRectMake(10, height, width, 28)];
    productSKU.text = [self.product objectForKey:@"sku"];
    productSKU.font = [UIFont systemFontOfSize:20];
    [self.detailView addSubview:productSKU];
    height += 38;
    
    // Image View
    NSArray *images = [self.product objectForKey:@"images"];
    if (!images || ![images isKindOfClass:[NSArray class]] || ![images count]) {
        images = [NSArray new];
    }
    ProductImagesView *imagesView = [[ProductImagesView alloc] initWithFrame:CGRectMake(10, height, 448, 504)];
    imagesView.images = images;
    [self.detailView addSubview:imagesView];
    
    // Product price, short description
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(468, height, 290, 36)];
    priceLabel.text = [Price format:[self.product objectForKey:@"price"]];
    priceLabel.font = [UIFont boldSystemFontOfSize:24];
    priceLabel.textColor = [UIColor buttonPressedColor];
    [self.detailView addSubview:priceLabel];
    height += 36;
    
    if ([self.product objectForKey:@"final_price"] && [[self.product objectForKey:@"final_price"] doubleValue] < [[self.product objectForKey:@"price"] doubleValue]) {
        // Regular Price
        UILabel *regLabel = [[UILabel alloc] initWithFrame:CGRectMake(468, height, 290, 28)];
        NSMutableAttributedString *regPrice = [[NSMutableAttributedString alloc] initWithString:priceLabel.text];
        [regPrice addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithBool:YES] range:NSMakeRange(0, regPrice.length)];
        // regLabel.text = priceLabel.text;
        regLabel.attributedText = regPrice;
        regLabel.font = [UIFont systemFontOfSize:20];
        [self.detailView addSubview:regLabel];
        height += 28;
        // Special Price
        priceLabel.text = [Price format:[self.product objectForKey:@"final_price"]];
    }
    height += 10;
    
    // Stock information
    BOOL isAvailable = [[self.product objectForKey:@"is_salable"] boolValue];
    UILabel *stockLabel = [[UILabel alloc] initWithFrame:CGRectMake(468, height, 290, 24)];
    stockLabel.font = [UIFont systemFontOfSize:18];
    [self.detailView addSubview:stockLabel];
    if (isAvailable) {
        stockLabel.textColor = [UIColor completedColor];
        stockLabel.text = NSLocalizedString(@"In stock", nil);
    } else {
        stockLabel.textColor = [UIColor buttonPressedColor];
        stockLabel.text = NSLocalizedString(@"Out of stock", nil);
    }
    height += 34;
    // Stock Item Info
    if ([self.product objectForKey:@"qty"]) {
        UILabel *stockQty = [[UILabel alloc] initWithFrame:CGRectMake(468, height, 290, 24)];
        stockQty.font = [UIFont systemFontOfSize:18];
        [self.detailView addSubview:stockQty];
        stockQty.text = [NSString stringWithFormat:NSLocalizedString(@"Qty In Stock: %.0f", nil), [[self.product objectForKey:@"qty"] floatValue]];
        height += 34;
    }
    
    isAvailable |= [[self.product objectForKey:@"is_available"] boolValue];
    if (isAvailable && ![self.product hasOptions]) {
        // Place Order now
        MSBlueButton *addToCart = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
        addToCart.frame = CGRectMake(468, height, 280, 44);
        [addToCart setTitle:NSLocalizedString(@"Add to Cart", nil) forState:UIControlStateNormal];
        [self.detailView addSubview:addToCart];
        [addToCart addTarget:self action:@selector(addProductToCart:) forControlEvents:UIControlEventTouchUpInside];
        height += 54;
    }
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 27, width, 1)];
    [separator setBackgroundColor:[UIColor lightBorderColor]];
    
    // Overview
    if ([self.product objectForKey:@"short_description"]) {
        height += 5;
        UILabel *overViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(468, height, 290, 28)];
        overViewLabel.font = [UIFont boldSystemFontOfSize:20];
        overViewLabel.text = NSLocalizedString(@"Quick Overview", nil);
        overViewLabel.textColor = [UIColor barBackgroundColor];
        [self.detailView addSubview:overViewLabel];
        [overViewLabel addSubview:separator];
        height += 33;
        
        UITextView *overView = [[UITextView alloc] initWithFrame:CGRectMake(461, height, 304, 588 - height)];
        overView.text = [self.product objectForKey:@"short_description"];
        overView.font = [UIFont systemFontOfSize:18];
        [overView setEditable:NO];
        [overView setScrollEnabled:NO];
        [self.detailView addSubview:overView];
    }
    
    // Product Option
    height = 588;
    if ([self.product hasOptions] && isAvailable) {
        UILabel *optionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, width, 28)];
        optionLabel.font = [UIFont boldSystemFontOfSize:20];
        optionLabel.text = NSLocalizedString(@"Select Options", nil);
        optionLabel.textColor = [UIColor barBackgroundColor];
        [self.detailView addSubview:optionLabel];
        [optionLabel addSubview:[separator clone]];
        height += 33;
        
        // Show Product Option and Add To Cart Button
        DetailProductOptions *productOptions = [DetailProductOptions new];
        productOptions.product = self.product;
        [self addChildViewController:productOptions];
        [self.detailView addSubview:productOptions.view];
        [productOptions didMoveToParentViewController:self];
        CGSize optionsSize = [productOptions reloadContentSize];
        productOptions.view.frame = CGRectMake(10, height, width, optionsSize.height);
        height += optionsSize.height + 10;
    }
    
    // Description
    if ([self.product objectForKey:@"description"]) {
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, width, 28)];
        descriptionLabel.font = [UIFont boldSystemFontOfSize:20];
        descriptionLabel.text = NSLocalizedString(@"Details", nil);
        descriptionLabel.textColor = [UIColor barBackgroundColor];
        [self.detailView addSubview:descriptionLabel];
        [descriptionLabel addSubview:[separator clone]];
        
        height += 33;
        
        UITextView *description = [[UITextView alloc] initWithFrame:CGRectMake(5, height, width + 10, 24)];
        description.text = [self.product objectForKey:@"description"];
        description.font = [UIFont systemFontOfSize:18];
        [description setEditable:NO];
        [description setScrollEnabled:NO];
        [self.detailView addSubview:description];
       
        //Auto height
        CGFloat fixedWidth = description.frame.size.width;
        CGSize newSize = [description sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = description.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        description.frame = newFrame;
        
        height += newSize.height + 10;
    }
    
    // Additional Information
    if ([self.product objectForKey:@"additional"] && [[self.product objectForKey:@"additional"] isKindOfClass:[NSArray class]] && [[self.product objectForKey:@"additional"] count]) {
        UILabel *additionalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, width, 28)];
        additionalLabel.font = [UIFont boldSystemFontOfSize:20];
        additionalLabel.text = NSLocalizedString(@"Additional Information", nil);
        additionalLabel.textColor = [UIColor barBackgroundColor];
        [self.detailView addSubview:additionalLabel];
        [additionalLabel addSubview:[separator clone]];
        height += 33;
        
        for (NSDictionary *additional in [self.product objectForKey:@"additional"]) {
            UITextView *addLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, height, 224, 24)];
            addLabel.text = [additional objectForKey:@"label"];
            addLabel.font = [UIFont boldSystemFontOfSize:18];
            [addLabel setEditable:NO];
            [addLabel setScrollEnabled:NO];
            [self.detailView addSubview:addLabel];
           
            //addLabel.frame = CGRectMake(10, height, 224, addLabel.contentSize.height);
            //Auto height
            CGFloat fixedWidth1 = addLabel.frame.size.width;
            CGSize newSize1 = [addLabel sizeThatFits:CGSizeMake(fixedWidth1, MAXFLOAT)];
            CGRect newFrame1 = addLabel.frame;
            newFrame1.size = CGSizeMake(fmaxf(newSize1.width, fixedWidth1), newSize1.height);
            addLabel.frame = newFrame1;
            
            
            UITextView *addValue = [[UITextView alloc] initWithFrame:CGRectMake(244, height, 514, 24)];
            addValue.text = [additional objectForKey:@"value"];
            addValue.font = [UIFont systemFontOfSize:18];
            [addValue setEditable:NO];
            [addValue setScrollEnabled:NO];
            [self.detailView addSubview:addValue];
            
            //addValue.frame = CGRectMake(244, height, 514, addValue.contentSize.height);
            //Auto height
            CGFloat fixedWidth2 = addValue.frame.size.width;
            CGSize newSize2 = [addValue sizeThatFits:CGSizeMake(fixedWidth2, MAXFLOAT)];
            CGRect newFrame2 = addValue.frame;
            newFrame2.size = CGSizeMake(fmaxf(newSize2.width, fixedWidth2), newSize2.height);
            addValue.frame = newFrame2;
            
            height += MAX(newSize1.height,newSize2.height) + 5;
        }
        height += 5;
    }
    
    // Update Scroll Content Size
    self.detailView.contentSize = CGSizeMake(width + 20, height);
}

#pragma mark - actions
- (void)addProductToCart:(id)sender
{
    animation.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    animation.frame = CGRectMake(((UIView *)sender).frame.size.width - 44, 0, 44, 44);
    [(UIView *)sender addSubview:animation];
    
    [(UIButton *)sender setEnabled:NO];
    [animation startAnimating];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(addProductToCartThread:) object:sender] start];
}

- (void)addProductToCartThread:(id)sender
{
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:QuoteEndRequestNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self performSelectorOnMainThread:@selector(closeDetailPage) withObject:nil waitUntilDone:YES];
    }];
    [[Quote sharedQuote] addProduct:self.product withOptions:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:success];
    [animation stopAnimating];
    [(UIButton *)sender setEnabled:YES];
}

@end
