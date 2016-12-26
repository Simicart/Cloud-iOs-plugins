//
//  ProductOptions.m
//  MobilePOS
//
//  Created by Nguyen Duc Chien on 10/9/2016.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "ProductOptions.h"
#import "ProductOptionsMaster.h"
#import "ProductOptionsDetail.h"
#import "SVPullToRefresh.h"
#import "Utilities.h"

#import "Product.h"
#import "Quote.h"

@interface ProductOptions ()
@property (strong, nonatomic) UIActivityIndicatorView *loadingAnimation;
@property (strong, nonatomic) id successObserver, failObserver;
@end


@implementation ProductOptions
@synthesize loadingAnimation;
@synthesize successObserver, failObserver;

@synthesize collectionView;
@synthesize indexPath;
@synthesize popoverController;
@synthesize masterOptions;
@synthesize detailOptions;

@synthesize product = _product;
// Selected options for current product (maybe item)
@synthesize productOptions = _productOptions;

- (id)init
{
    if (self = [super init]) {
        // Init selected product options
        self.productOptions = [[NSMutableDictionary alloc] init];
        self.masterOptions = [[ProductOptionsMaster alloc] init];
        self.detailOptions = [[ProductOptionsDetail alloc] init];
        // Init loading animation
        self.loadingAnimation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    // Add sub view controller (include Master and Detail view controller)
    [self addChildViewController:self.masterOptions];
    [self.view addSubview:self.masterOptions.view];
    [self.masterOptions didMoveToParentViewController:self];
    self.masterOptions.view.autoresizingMask = UIViewAutoresizingNone;
    
    [self addChildViewController:self.detailOptions];
    [self.view addSubview:self.detailOptions.view];
    [self.detailOptions didMoveToParentViewController:self];
    self.detailOptions.view.autoresizingMask = UIViewAutoresizingNone;
    
    // Link for sub view
    self.masterOptions.detailControl = self.detailOptions;
    self.detailOptions.masterControl = self.masterOptions;
    
    // Add animation
    [self.view addSubview:self.loadingAnimation];
}

#pragma mark - estimate content size for popover
- (CGSize)reloadContentSize {
    CGFloat width = 320;
    CGFloat height = 44;
    if (![self.product isLoadedOptions]) {
        // Load Option by other thread
        successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"ProductLoadOptionsSuccess" object:nil queue:nil usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            [[NSNotificationCenter defaultCenter] removeObserver:failObserver];
            [self.loadingAnimation stopAnimating];
            // Reload popover
            self.popoverController.popoverContentSize = [self reloadContentSize];
            CGRect frame = [[collectionView layoutAttributesForItemAtIndexPath:indexPath] frame];
            [self.popoverController presentPopoverFromRect:frame inView:collectionView permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        }];
        failObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
            [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
            [[NSNotificationCenter defaultCenter] removeObserver:failObserver];
            [self.loadingAnimation stopAnimating];
            // Fail to load - Show alert
            NSDictionary *userInfo = [note userInfo];
            if ([userInfo objectForKey:@"reason"] != nil) {
                [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
            }
            // Dismiss popover
            [self.popoverController dismissPopoverAnimated:YES];
        }];
        if (!self.product.isLoadingOptions) {
            [[[NSThread alloc] initWithTarget:self.product selector:@selector(getOptions) object:nil] start];
        }
        // Show animations
        self.view.frame = CGRectMake(0, 0, width, height);
        self.loadingAnimation.frame = CGRectMake(0, 0, width, height);
        [self.view setBackgroundColor:[UIColor whiteColor]];
        [self.loadingAnimation startAnimating];
        // Hide options view
        self.masterOptions.view.hidden = YES;
        self.detailOptions.view.hidden = YES;
    } else {
        [self.view setBackgroundColor:[UIColor lightGrayColor]];
        [self.loadingAnimation stopAnimating];
        self.loadingAnimation.frame = CGRectZero;
        // Calculate popover width and height
        NSArray *options = [self.product getOptions];
        NSDictionary *selectOptions;
        NSUInteger showView = 0;
        for (NSDictionary *option in options) {
            if ( ([option objectForKey:@"group"] && [[option objectForKey:@"group"] isEqualToString:@"select"])
                || ([option objectForKey:@"group"] && [[option objectForKey:@"group"] isEqualToString:@"date"])
            ) {
                if (showView & 1) {
                    showView |= 2;
                    break;
                }
                selectOptions = option;
                showView |= 1;
            } else {
                showView |= 2;
            }
        }
        self.masterOptions.masterOptions = options;
        switch (showView) {
            case 1: // 01 - Show detail (right) options
                self.detailOptions.detailOptions = selectOptions;
                self.detailOptions.hasOptionsLabel = YES;
                selectOptions = [self.detailOptions productOptionsValue];
                if ([self.detailOptions.detailOptions objectForKey:@"group"] && [[self.detailOptions.detailOptions objectForKey:@"group"] isEqualToString:@"date"]) {
                    height *= 3;
                } else if ([[selectOptions allKeys] count] > 7) {
                    height *= 7;
                } else {
                    height *= [[selectOptions allKeys] count];
                }
                height += 44; // Used for section label
                if (height < 176) {
                    height = 176; // Min select is 3 options
                }
                self.view.frame = CGRectMake(0, 0, width, height);
                self.detailOptions.view.frame = self.view.frame;
                
                self.masterOptions.view.hidden = YES;
                self.detailOptions.view.hidden = NO;
                [self.detailOptions.tableView reloadData];
                break;
            case 2: // 10 - Show master (left) options
                self.masterOptions.masterOptions = options;
                if ([options count] > 7) {
                    height *= 8;
                } else if ([options count] > 1) {
                    height *= [options count] + 1;
                }
                if (height < 176) {
                    height = 176; // Min select is 3 options
                }
                self.view.frame = CGRectMake(0, 0, width, height);
                self.masterOptions.tableWidth = width;
                self.masterOptions.view.frame = self.view.frame;
                
                self.masterOptions.view.hidden = NO;
                self.detailOptions.view.hidden = YES;
                [self.masterOptions.tableView reloadData];
                [self.masterOptions.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                break;
            case 3: // 11 - Show both options
                self.masterOptions.masterOptions = options;
                self.detailOptions.detailOptions = selectOptions;
                self.detailOptions.hasOptionsLabel = YES;
                
                selectOptions = [self.detailOptions productOptionsValue];
                NSUInteger numberRows = ([[selectOptions allKeys] count] > [options count]) ? [[selectOptions allKeys] count] : [options count];
                if (numberRows > 7) {
                    numberRows = 7;
                }
                numberRows++;
                width = 234; // Update width for two row display
                height *= numberRows;
                if (height < 264) {
                    height = 264; // Min select is 5 options
                }
                
                self.view.frame = CGRectMake(0, 0, 2 * width + 1, height);
                self.masterOptions.tableWidth = width;
                self.masterOptions.view.frame = CGRectMake(0, 0, width, height);
                self.detailOptions.view.frame = CGRectMake(width + 1, 0, width, height);
                
                width = 2 * width + 1;
                self.masterOptions.view.hidden = NO;
                self.detailOptions.view.hidden = NO;
                [self.masterOptions.tableView reloadData];
                [self.masterOptions.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [self.detailOptions.tableView reloadData];
                break;
        }
    }
    //self.contentSizeForViewInPopover = CGSizeMake(width, height);
    //return self.contentSizeForViewInPopover;

    [self setPreferredContentSize:CGSizeMake(width, height)];
    return self.preferredContentSize;
}

#pragma mark - Validate options and add product to cart
- (BOOL)validateOptions
{
    NSArray *options = [self.product getOptions];
    for (NSDictionary *option in options) {
        if ([[option objectForKey:@"required"] boolValue]) {
            id selectedOption = [self.productOptions objectForKey:[option objectForKey:@"name"]];
            if (selectedOption == nil
                || ([selectedOption isKindOfClass:[NSArray class]] && ![selectedOption count])
                || ([selectedOption isKindOfClass:[NSString class]] && [selectedOption isEqualToString:@""])
            ) {
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)addProductToCart
{
    if (![self validateOptions]) {
        return NO;
    }
    [[[NSThread alloc] initWithTarget:self selector:@selector(threadAddProductToCart) object:nil] start];
    
    [self.popoverController dismissPopoverAnimated:YES];
    return YES;
}

- (void)threadAddProductToCart
{
    [[Quote sharedQuote] addProductOffline:self.product withOptions:self.productOptions];
}

#pragma mark - Popover controller delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // dismiss popover event, remove failt & complete observer
    if (successObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
    }
    if (failObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:failObserver];
    }
    [self.loadingAnimation stopAnimating];
}

@end
