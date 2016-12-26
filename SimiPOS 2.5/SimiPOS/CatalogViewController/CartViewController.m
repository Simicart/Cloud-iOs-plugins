//
//  CartViewController.m
//  MobilePOS
//
//  Edit by Nguyen Duc Chien on 10/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import "CartViewController.h"
#import "CartInformation.h"
#import "Quote.h"
#import "Price.h"
#import "MSFramework.h"
#import "QuoteNoteViewController.h"
#import "Configuration.h"

#import "ProductViewDetailController.h"
#import "ProductCollection.h"
#import "Product.h"


@interface CartViewController ()
@property (nonatomic) NSInteger currentPage;
@property (strong, nonatomic) UIBarButtonItem *clearButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UITextField *barcodeInput;
@property (strong, nonatomic) UIPopoverController *notePopover;
@property (strong, nonatomic) UIActivityIndicatorView *animation;

@property (weak, nonatomic) IBOutlet UIImageView *holdCancelImage;


@end

@implementation CartViewController
@synthesize productView;
@synthesize currentPage, clearButton, backButton;
@synthesize barcodeInput;
@synthesize notePopover;

@synthesize totalButton;
@synthesize totalLabel;
@synthesize cartController;
@synthesize animation;

static CartViewController *_sharedInstance = nil;

+(CartViewController*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self checkProccessHoldOrder];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sharedInstance = self;
    
    self.holdButton.layer.cornerRadius=5.0;
    self.holdButton.enabled =NO;
    self.totalButton.layer.cornerRadius=5.0;
    
    //set color
    self.holdButton.backgroundColor =[UIColor barBackgroundColor];
    self.totalButton.backgroundColor = [UIColor barBackgroundColor] ;
    
    self.totalButton.alpha =0.6;
    self.holdButton.alpha =0.6;
    
    // Navigation Button
    currentPage = SHOPPING_CART_PAGE;
    MSClearButton *clearBtn = [MSClearButton buttonWithType:UIButtonTypeRoundedRect];
    clearBtn.frame = CGRectMake(0, 0, 44, 44);
    [clearBtn addTarget:self action:@selector(clearShoppingCart) forControlEvents:UIControlEventTouchUpInside];
    clearButton = [[UIBarButtonItem alloc] initWithCustomView:clearBtn];
    self.navigationItem.leftBarButtonItem = clearButton;
    
    MSNoteButton *noteBtn = [MSNoteButton buttonWithType:UIButtonTypeRoundedRect];
    noteBtn.frame = CGRectMake(0, 0, 44, 44);
    [noteBtn addTarget:self action:@selector(showNoteForm:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
    
    // update label
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Cart (%.0f)", nil), 0.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    
    // Total button style
    [self.totalButton setEnabled:NO];

    [self.totalButton setTitle:NSLocalizedString(@"  TOTAL", nil) forState:UIControlStateNormal];
    
    [self.totalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.totalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    // add cart information
    self.cartController = [[CartInformation alloc] initWithStyle:UITableViewStylePlain];
    //self.cartController.view.frame = CGRectMake(0, 0, 427, 620);
    self.cartController.view.frame = CGRectMake(0, 0, 427, WINDOW_HEIGHT -100);

    self.cartController.view.autoresizingMask = UIViewAutoresizingNone;
    [self addChildViewController:self.cartController];
    [self.view addSubview:self.cartController.view];
    [self.cartController didMoveToParentViewController:self];
    
    
    UIView * splitView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, WINDOW_HEIGHT)];
    splitView.backgroundColor =[UIColor borderColor];
    [self.view addSubview:splitView];
    
    // Add refresh Event
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCartView) name:QuoteDidRequestNotification object:nil];
    
    // Bar Code Input
    self.barcodeInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.barcodeInput.hidden = YES;
    self.barcodeInput.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.barcodeInput];
    self.barcodeInput.delegate = self;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenBarCodeReader:) name:@"AccountLoginAfter" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenBarCodeReader:) name:@"UIViewResignFirstResponder" object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reListenBarcodeReader:) name:UIApplicationDidBecomeActiveNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceListenBarcodeRd:) name:@"ClosePopupWindow" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(holdOrderCancelSuccess) name:@"NotifyHoldOrderCancelSuccess" object:nil];
    
    //An nut back khi checkout success , user chi co the nhat nut create order
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideBackButtonWhenOrderSuccess) name:@"NofityHideBackButtonWhenOrderSuccess" object:nil];
    
}

-(void)hideBackButtonWhenOrderSuccess{
    backButton =nil;    
}

#pragma mark - load data from server
- (void)loadCartInformation
{
    if (currentPage == CHECKOUT_PAGE) {
        [self performSelectorOnMainThread:@selector(backToShoppingCart) withObject:nil waitUntilDone:NO];
    }
    [[Configuration globalConfig].globalAccess removeObjectForKey:@"modelPrice"];
    [[Configuration globalConfig].globalAccess removeObjectForKey:@"modelStore"];
    [Price format:[NSNumber numberWithInt:0]];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadCartInformationThread) object:nil] start];
}

- (void)loadCartInformationThread
{
    //[[Quote sharedQuote] cleanData];
    // [self.cartController.tableView reloadData];
    // [[Quote sharedQuote] load:nil];
 
    self.cartController.quote =[Quote sharedQuote];
    // [[Quote sharedQuote] loadQuoteItems];
    
    [self.cartController.tableView reloadData];
    
}

#pragma mark - refresh display
- (void)clearShoppingCart
{
    self.isHoldOrder =NO;
    self.order =nil;
    
    [self checkProccessHoldOrder];
    
    [[[NSThread alloc] initWithTarget:[Quote sharedQuote] selector:@selector(clearCart) object:nil] start];
    [[[NSThread alloc] initWithTarget:[Quote sharedQuote] selector:@selector(assignCustomer:) object:nil] start];
}

- (void)refreshCartView
{
    // Update title
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Cart (%.0f)", nil), [[Quote sharedQuote] totalItemsQty]];
    
    // Total Button Status
    if ([[Quote sharedQuote] totalItemsQty] == 0.0) {
        [self.totalButton setEnabled:NO];
        [self.holdButton setEnabled:NO];
        
        self.totalButton.alpha =0.6;
        self.holdButton.alpha =0.6;
        
    } else {
        [self.totalButton setEnabled:YES];
        [self.holdButton setEnabled:YES];
        
        self.totalButton.alpha =1.0;
        self.holdButton.alpha =1.0;
    }
    
    // Refresh total label
    self.totalLabel.text = [Price format:[[Quote sharedQuote] getGrandTotal]];
    
    self.cartController.quote =[Quote sharedQuote];
    [self.cartController.tableView reloadData];
}

- (IBAction)startCheckout
{
    currentPage = CHECKOUT_PAGE;
    if (backButton == nil) {
        MSBackButton *backBtn = [MSBackButton buttonWithType:UIButtonTypeRoundedRect];
        backBtn.frame = CGRectMake(0, 0, 44, 44);
        [backBtn addTarget:self action:@selector(backToShoppingCart) forControlEvents:UIControlEventTouchUpInside];
        backButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    }
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.cartController.currentPage = currentPage;
    [self.cartController.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GoToCheckoutPage" object:nil];
}

- (IBAction)backToShoppingCart
{
    [self.barcodeInput becomeFirstResponder];
    currentPage = SHOPPING_CART_PAGE;
    self.navigationItem.leftBarButtonItem = clearButton;
    
    self.cartController.currentPage = currentPage;
    [self.cartController.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GoToShoppingCartPage" object:nil];
}

#pragma mark - Show note form
- (void)showNoteForm:(id)sender
{
    if (notePopover == nil) {
        QuoteNoteViewController *quoteNote = [QuoteNoteViewController new];
        notePopover = [[UIPopoverController alloc] initWithContentViewController:quoteNote];
        notePopover.delegate = quoteNote;
        quoteNote.notePopover = notePopover;
    }
    QuoteNoteViewController *quoteNote = (QuoteNoteViewController *)notePopover.delegate;
    notePopover.popoverContentSize = [quoteNote reloadContentSize];
    [notePopover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Barcode methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([Configuration isDev]) {
        NSLog(@"%@", textField.text);
    }
    // Take action for Bar Code
    for (NSInteger i = [productView.allProducts getSize]; i > 0; ) {
        i--;
        Product *product = [productView.allProducts objectAtIndex:i];
        if ([[product objectForKey:@"barcode"] isEqualToString:textField.text]) {
            if ([[product objectForKey:@"has_options"] boolValue]) {
                // View detail
                ProductViewDetailController *viewController = [ProductViewDetailController new];
                viewController.product = product;
                MSNavigationController *navControl = [[MSNavigationController alloc] initWithRootViewController:viewController];
                navControl.modalPresentationStyle = UIModalPresentationPageSheet;
                [productView presentViewController:navControl animated:YES completion:nil];
            } else {
                // Add to Cart
                [[[NSThread alloc] initWithTarget:productView selector:@selector(addProductToCart:) object:product] start];
            }
            // Reset input text
            textField.text = nil;
            return YES;
        }
    }
    // Online search for barcode
    [[[NSThread alloc] initWithTarget:self selector:@selector(addProductByBarcode:) object:textField.text] start];
    
    // Reset input text
    textField.text = nil;
    return YES;
}

- (void)addProductByBarcode:(NSString *)barcode
{
    [[Quote sharedQuote] addByBarcode:barcode];
}

- (void)listenBarCodeReader:(NSNotification *)note
{
    if (currentPage == CHECKOUT_PAGE) {
        return;
    }
    UIView *responder = [UIView firstResponder:nil];
    if (responder == nil) {
        [self.barcodeInput performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:NO];
        return;
    }
    id sender = [note object];
    if (sender == nil) {
        [self.barcodeInput performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:NO];
        return;
    }
    if (![responder isEqual:self.barcodeInput]
        && [responder isEqual:sender]
        ) {
        [self.barcodeInput performSelectorOnMainThread:@selector(becomeFirstResponder) withObject:nil waitUntilDone:NO];
    }
}

- (void)reListenBarcodeReader:(NSNotification *)note
{
    if (currentPage == CHECKOUT_PAGE) {
        return;
    }
    UIView *responder = [UIView firstResponder:nil];
    if ([self.barcodeInput isEqual:responder]) {
        [self.barcodeInput resignFirstResponder];
        [self.barcodeInput becomeFirstResponder];
    }
}

- (void)forceListenBarcodeRd:(NSNotification *)note
{
    if (currentPage == CHECKOUT_PAGE) {
        return;
    }
    [self.barcodeInput resignFirstResponder];
    [self.barcodeInput becomeFirstResponder];
}

#pragma mark - external methods
- (void)showBackButton
{
    if (currentPage == CHECKOUT_PAGE) {
        self.navigationItem.leftBarButtonItem = backButton;
    } else {
        self.navigationItem.leftBarButtonItem = clearButton;
    }
}

#pragma mark - Kiem tra trang thai normal , hay su kien bam continue tu ben hold order sang
-(void)checkProccessHoldOrder{
    if(self.isHoldOrder){
        [self.holdButton setTitle:@"CANCEL" forState:UIControlStateNormal];
        self.holdCancelImage.image =[UIImage imageNamed:@"cancel_filled.png"];
        
    }else{
        [self.holdButton setTitle:@"HOLD" forState:UIControlStateNormal];
        self.holdCancelImage.image =[UIImage imageNamed:@"save.png"];
    }
}

-(IBAction)holdButtonClick:(id)sender{
    
     if(self.isHoldOrder){
         [self cancelOnHoldOrder];
         
     }else{
         [self holdOrderCart];
     }
}


#pragma mark - Huy onHold Order : truong hop khi nhan button Continue tu man hinh OnHoldOrder chuyen sang
-(void)cancelOnHoldOrder{
    DLog(@"cancel hold order");    
    if(!self.order){
        return;
    }
    
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        animation.frame = self.view.bounds;
        animation.color = [UIColor grayColor];
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        [self.view addSubview:animation];
    }
    
    [animation startAnimating];
    
   // DLog(@"order:%@",self.order);
    
    [self.order cancelHoldOrder];
    
    [animation stopAnimating];
}

#pragma mark - Hold Order trường hợp mặc đinh
-(void)holdOrderCart{
    
    [cartController startAnimation];
    
    NSString * orderComment =@"";
    if([[Quote sharedQuote] objectForKey:@"order_comment"]){
        orderComment=[[Quote sharedQuote] objectForKey:@"order_comment"];
    }
    NSString * cashIn= [NSString stringWithFormat:@"%Lf",[Quote sharedQuote].cashIn];
    
   // DLog(@"orderComment:%@ ; cashIn:%@",orderComment,cashIn);
    
    [[APIManager shareInstance] holdOrderCashIn:cashIn Note:orderComment Callback:^(BOOL success, id result) {
        [cartController stopAnimation];
        
     //   DLog(@"%@",result);
        if(success){
            
            [Utilities toastSuccessTitle:@"Hold Order" withMessage:MESSAGE_SUBMIT_SUCCESS withView:self.view];
            
            [[Quote sharedQuote] cleanData];
            [self refreshCartView];
        }else{
            
            
            NSString * message =[result objectForKey:@"data"];
            if(message){
                 [Utilities alert:@"Hold Order" withMessage:message];
                
            }else{
                 [Utilities alert:@"Hold Order" withMessage:MESSAGE_SUBMIT_FAIL];
            }
                                   
        }
    }];
    
}

#pragma mark - Lang nghe su kien khi cancel thanh cong
-(void)holdOrderCancelSuccess{
    
    [Utilities toastSuccessTitle:@"Hold Order" withMessage:MESSAGE_CANCEL_SUCCESS withView:self.view];
    
    self.isHoldOrder =NO;
    self.order =nil;
    
    [self clearShoppingCart];
    
    [self checkProccessHoldOrder];    
}

@end
