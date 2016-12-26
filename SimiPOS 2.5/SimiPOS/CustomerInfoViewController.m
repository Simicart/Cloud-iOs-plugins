//
//  CustomerInfoViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/27/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "CustomerInfoViewController.h"
#import "CustomersListViewController.h"
#import "AddCustomerViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "MenuItem.h"
#import "Quote.h"

#import "MSFramework.h"
#import "RegionCollection.h"
#import "CountryCollection.h"
#import "Address.h"
#import "Account.h"

@interface CustomerInfoViewController ()
@property (strong, nonatomic) UIView *clearView;

@property (strong, nonatomic) MSForm *form;
@property (strong, nonatomic) MSFormRow *country;
@property (strong, nonatomic) MSFormRow *email;
@property (strong, nonatomic) MSFormRow *phoneNumber;
@property (strong, nonatomic) MSFormAbstract *countryField, *regionField, *regionIdField;
@property (strong, nonatomic) RegionCollection *collection;

- (void)loadCustomerDataThread;
- (void)saveCustomerThread;

- (void)deleteCustomerThread;

@property (strong, nonatomic) UIActivityIndicatorView *animation, *largeAnimation;
- (void)loadRegionThread;
@end

@implementation CustomerInfoViewController

@synthesize listController, currentIndexPath, customer = _customer;
@synthesize form, country, countryField, regionField, regionIdField, collection;
@synthesize createOrderBtn, deleteBtn, animation, largeAnimation;
@synthesize email,phoneNumber;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 596, 702);
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelEdit)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveCustomer)];
    
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    // Edit Customer Form
    self.form = [MSForm new];
    self.form.frame = CGRectMake(1, 0, 595, 594);
    // [self.form.layer setCornerRadius:5];
    [self.view addSubview:self.form];
    self.form.rowHeight = 54;
    
    // Form Fields
    NSNumber *height = [NSNumber numberWithFloat:form.rowHeight];
    // Customer Name
    MSFormRow *name = (MSFormRow *)[form addField:@"Row" config:@{
        @"height": height
    }];
    [name addField:@"Text" config:@{
        @"name": @"firstname",
        @"title": NSLocalizedString(@"First Name", nil),
        @"height": height
    }];
    [name addField:@"Text" config:@{
        @"name": @"lastname",
        @"title": NSLocalizedString(@"Last Name", nil),
        @"height": height
    }];
    // Email and phone
    
    email = (MSFormRow *)[form addField:@"Row" config:@{
                                                        @"height": height
                                                        }];
    
    [email addField:@"Email" config:@{
        @"name": @"email",
        @"title": NSLocalizedString(@"Email", nil),
        @"height": height
    }];
    
    phoneNumber = (MSFormRow *)[form addField:@"Row" config:@{
        @"height": height
    }];
    [phoneNumber addField:@"Number" config:@{
        @"name": @"telephone",
        @"title": NSLocalizedString(@"Phone", nil),
        @"height": height
    }];
    [phoneNumber addField:@"Number" config:@{
        @"name": @"fax",
        @"title": NSLocalizedString(@"Fax", nil),
        @"height": height
    }];
    
    [form addField:@"Text" config:@{
        @"name": @"street[0]",
        @"title": NSLocalizedString(@"Address Line 1", nil),
        @"height": height
    }];
    [form addField:@"Text" config:@{
        @"name": @"street[1]",
        @"title": NSLocalizedString(@"Address Line 2", nil),
        @"height": height
    }];
    
    // City and Zip Code
    MSFormRow *city = (MSFormRow *)[form addField:@"Row" config:@{
        @"height": height
    }];
    [city addField:@"Text" config:@{
        @"name": @"city",
        @"title": NSLocalizedString(@"City", nil),
        @"height": height
    }];
    [city addField:@"Number" config:@{
        @"name": @"postcode",
        @"title": NSLocalizedString(@"Zip/Postal Code", nil),
        @"height": height
    }];
    
    // Country and State
    country = (MSFormRow *)[form addField:@"Row" config:@{
        @"height": height
    }];
    
    countryField = [country addField:@"Select" config:@{
        @"name": @"country_id",
        @"title": NSLocalizedString(@"Country", nil),
        @"height": height,
        @"source": [CountryCollection allCountryAsDictionary],
        @"value": [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]
    }];
    
    regionField = [country addField:@"Text" config:@{
        @"name": @"region",
        @"title": NSLocalizedString(@"State/Province", nil),
        @"height": height
    }];
    
    // Company and Fax
    [form addField:@"Text" config:@{
        @"name": @"company",
        @"title": NSLocalizedString(@"Company", nil),
        @"height": height
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeFormHeight:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFormHeight:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountry:) name:@"MSFormFieldChange" object:nil];
    
    // Clear Form View
    self.clearView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.clearView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.clearView];
    
    // Footer Button
    createOrderBtn = [MSBlueButton buttonWithType:UIButtonTypeRoundedRect];
    createOrderBtn.frame = CGRectMake(148, 617, 300, 65);
    createOrderBtn.titleLabel.font = [UIFont systemFontOfSize:24];
    [createOrderBtn setTitle:NSLocalizedString(@"Create Order", nil) forState:UIControlStateNormal];
    createOrderBtn.hidden = YES;
    [self.view addSubview:createOrderBtn];
    [createOrderBtn addTarget:self action:@selector(createOrder) forControlEvents:UIControlEventTouchUpInside];
    
    if ([Account permissionValue:@"customer.delete"]) {
        createOrderBtn.frame = CGRectMake(308, 622, 260, 54);
        
        // Delete Button
        deleteBtn = [MSGrayButton buttonWithType:UIButtonTypeRoundedRect];
        deleteBtn.frame = CGRectMake(28, 622, 260, 54);
        deleteBtn.titleLabel.font = [UIFont systemFontOfSize:24];
        [deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [deleteBtn setTitle:NSLocalizedString(@"Delete", nil) forState:UIControlStateNormal];
        deleteBtn.hidden = YES;
        [self.view addSubview:deleteBtn];
        [deleteBtn addTarget:self action:@selector(deleteCustomer) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Animation
    self.largeAnimation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.largeAnimation.frame = CGRectMake(10, 0, 586, 565);
    self.largeAnimation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.largeAnimation.color = [UIColor grayColor];
    [self.view addSubview:self.largeAnimation];
}

- (void)resizeFormHeight:(NSNotification *)note
{
    CGRect frame = self.form.frame;
    frame.size.height -= 240;
    self.form.frame = frame;
}

- (void)returnFormHeight:(NSNotification *)note
{
    CGRect frame = self.form.frame;
    frame.size.height += 240;
    self.form.frame = frame;
}

#pragma mark - assign customer for form
- (void)assignCustomer:(Customer *)customer
{
    if (customer && [customer isEqual:self.customer]) {
        return;
    }
    [self.form.formData removeAllObjects];
    if (self.customer && customer && [[self.customer getId] isEqualToString:[customer getId]]) {
        [self.customer addData:customer];
    } else {
        self.customer = customer;
    }
    [self loadCustomerView];
}

- (void)loadCustomerView
{
    if (self.customer) {
        self.title = [NSString stringWithFormat:NSLocalizedString(@"Edit Customer", nil)];
        self.clearView.hidden = YES;
        createOrderBtn.hidden = NO;
        deleteBtn.hidden = NO;
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
        self.title = NSLocalizedString(@"Customer", nil);
        self.clearView.hidden = NO;
        self.createOrderBtn.hidden = YES;
        deleteBtn.hidden = YES;
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        return;
    }
    // Load customer information (if need)
    [self loadCustomerData];
}

#pragma mark - load customer data
- (void)loadCustomerData
{
    [self.form loadFormData:self.customer];
    [self.form reloadData];
    if ([self.customer objectForKey:@"firstname"] == nil) {
        // Load more information
        [self.largeAnimation startAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [[[NSThread alloc] initWithTarget:self selector:@selector(loadCustomerDataThread) object:nil] start];
    } else {
        [self reloadRegion];
    }
}

- (void)loadCustomerDataThread
{
    // Load customer address data
    Address *billing = [Address new];
    [billing loadBilling:[self.customer getId]];
    if ([billing getId] && [[self.customer getId] isEqualToString:[billing objectForKey:@"customer_id"]]) {
        [self.customer setValue:[billing getId] forKey:@"address_id"];
        [billing removeObjectForKey:@"id"];
    }
    [self.customer addData:billing];
    if ([self.customer objectForKey:@"firstname"] == nil) {
        [self.customer load:[self.customer getId]];
    }
    
    [self.form loadFormData:self.customer];
    [self.form reloadData];
    
    [self.largeAnimation stopAnimating];
    
    NSString *countryCode = [form.formData objectForKey:@"country_id"];
    if (countryCode == nil || ![countryCode isKindOfClass:[NSString class]]) {
        [animation stopAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        return;
    }
    if (collection == nil) {
        collection = [RegionCollection new];
    }
    [collection setCountry:countryCode];
    [self loadRegionThread];
}

#pragma mark - button action
- (void)addNewCustomer
{
    AddCustomerViewController *addCustomer = [AddCustomerViewController new];
    addCustomer.infoController = self;
    addCustomer.editNav=self.editNav;
    
   // MSNavigationController *navController = [[MSNavigationController alloc] initWithRootViewController:addCustomer];
    //navController.modalPresentationStyle = UIModalPresentationCurrentContext;
    //[self presentViewController:navController animated:YES completion:nil];
   
    [self.editNav pushViewController:addCustomer animated:NO];
    
    [self.listController.tableView setAllowsSelection:NO];
}

- (void)saveCustomer
{
    //check email
    NSString * emailInput = [form.formData objectForKey:@"email"];
    
    if (emailInput == nil || ![MSValidator validateEmail:emailInput]) {
       
        [Utilities toastFailTitle:@"" withMessage:INPUT_INVALID_EMAIL_ADRESS withView:self.navigationController.navigationBar];
        [self forcusEmail];
        return;
    }
    
    
    [largeAnimation startAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.listController.tableView setAllowsSelection:NO];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveCustomerThread) object:nil] start];
}

- (void)saveCustomerThread
{
    // Process Observer
    id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Error when query
        NSDictionary *userInfo = [note userInfo];
        if (userInfo == nil) {
            return ;
        }
        id model = [userInfo objectForKey:@"model"];
        if (model == nil || (![model isKindOfClass:[Customer class]] && ![model isKindOfClass:[Address class]])) {
            return;
        }
        [largeAnimation stopAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        if ([userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"CustomerSaveAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        [Utilities toastSuccessTitle:@"Customer" withMessage:MESSAGE_SAVE_SUCCESS withView:self.view];
        
        Customer *newCustomer = (Customer *)[note object];
        if (newCustomer) {
            [self.customer addData:newCustomer];
            // Update list
            if (currentIndexPath && [currentIndexPath row] < [self.listController.customerList getSize]) {
                Customer *customer = [self.listController.customerList objectAtIndex:[currentIndexPath row]];
                if ([self.customer isEqual:customer]) {
                    [self.customer setValue:[NSString stringWithFormat:@"%@ %@", [customer objectForKey:@"firstname"], [customer objectForKey:@"lastname"]] forKey:@"name"];
                    [listController.tableView reloadData];
                    [listController.tableView selectRowAtIndexPath:currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
        // Save customer Address
        id saveAddressSuccess = [[NSNotificationCenter defaultCenter] addObserverForName:@"AddressSaveAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
            Address *savedAddress = (Address *)[note object];
            if (savedAddress) {
                if ([savedAddress getId]) {
                    [self.customer setValue:[savedAddress getId] forKey:@"address_id"];
                    [savedAddress removeObjectForKey:@"id"];
                }
                [self.customer addData:savedAddress];
            }
        }];
        Address *saveAddress = [Address new];
        [saveAddress addEntriesFromDictionary:form.formData];
        [saveAddress implodeAddressLines];
        [saveAddress setValue:[self.customer getId] forKey:@"customer_id"];
        [saveAddress removeObjectForKey:@"name"];
        if ([self.customer objectForKey:@"address_id"]) {
            [saveAddress setValue:[self.customer objectForKey:@"address_id"] forKey:@"id"];
        } else {
            [saveAddress removeObjectForKey:@"id"];
        }
        [saveAddress save];
        
        // Stop animation
        [largeAnimation stopAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:saveAddressSuccess];
    }];
    
    // Save Customer
    Customer *saveCustomer = [Customer new];
    if (self.customer && [self.customer objectForKey:@"group_id"]) {
        [saveCustomer setValue:[self.customer objectForKey:@"group_id"] forKey:@"group_id"];
    }
    if (self.customer && [self.customer getId]) {
        [saveCustomer setValue:[self.customer objectForKey:@"id"] forKey:@"id"];
    }
    if ([form.formData objectForKey:@"firstname"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"firstname"] forKey:@"firstname"];
    }
    if ([form.formData objectForKey:@"lastname"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"lastname"] forKey:@"lastname"];
    }
    if ([form.formData objectForKey:@"email"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"email"] forKey:@"email"];
    }
    if ([form.formData objectForKey:@"telephone"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"telephone"] forKey:@"telephone"];
    }
    [saveCustomer save];
    
    [[NSNotificationCenter defaultCenter] removeObserver:success];
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [self.listController.tableView setAllowsSelection:YES];
}

- (void)createOrder
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_OPEN_PRODUCT" object:nil];
   // [[[NSThread alloc] initWithTarget:[Quote sharedQuote] selector:@selector(forceAssignCustomer:) object:self.customer] start];
    
   // DLog(@"customer:%@",self.customer);
      [[[NSThread alloc] initWithTarget:[Quote sharedQuote] selector:@selector(assignCustomer:) object:self.customer] start];
}

#pragma mark - action sheet delegate
- (void)deleteCustomer
{
    UIActionSheet *confirm = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete this customer?", nil) delegate:self cancelButtonTitle:@"" destructiveButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:NSLocalizedString(@"Cancel", nil), nil];
    [confirm showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        return;
    }
    // Start animation and delete customer in new thread
    [largeAnimation startAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.listController.tableView setAllowsSelection:NO];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(deleteCustomerThread) object:nil] start];
}

- (void)deleteCustomerThread
{
    id failt = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo == nil) {
            return ;
        }
        id model = [userInfo objectForKey:@"model"];
        if (![self.customer isEqual:model]) {
            return ;
        }
        if ([userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
        [largeAnimation stopAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.listController.tableView setAllowsSelection:YES];
    }];
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"CustomerDeleteAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [largeAnimation stopAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.listController.tableView setAllowsSelection:YES];
        // Update List View
        if (currentIndexPath) {
            [listController.customerList removeObjectForKey:[listController.customerList.sortedIndex objectAtIndex:[currentIndexPath row]]];
            [listController.customerList.sortedIndex removeObjectAtIndex:[currentIndexPath row]];
            [listController.tableView performSelectorOnMainThread:@selector(deleteRowsAtIndexPaths:withRowAnimation:) withObject:@[currentIndexPath] waitUntilDone:YES];
        }
        // Select Other Row
        if (currentIndexPath && [currentIndexPath row] >= [listController.customerList getSize]) {
            if ([listController.customerList getSize]) {
                currentIndexPath = [NSIndexPath indexPathForRow:([listController.customerList getSize] - 1) inSection:[currentIndexPath section]];
            } else {
                currentIndexPath = nil;
            }
        }
        if (currentIndexPath) {
            [listController.tableView performSelectorOnMainThread:@selector(selectRowAtIndexPath:animated:scrollPosition:) withObject:currentIndexPath waitUntilDone:YES];
            [self performSelectorOnMainThread:@selector(assignCustomer:) withObject:[listController.customerList objectAtIndex:[currentIndexPath row]] waitUntilDone:NO];
        }
    }];
    [self.customer deleteCustomer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:failt];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

#pragma mark - Locale methods
- (void)reloadRegion
{
    NSString *countryCode = [form.formData objectForKey:@"country_id"];
    if (countryCode == nil || ![countryCode isKindOfClass:[NSString class]]) {
        return;
    }
    if (collection == nil) {
        collection = [RegionCollection new];
    }
    [collection setCountry:countryCode];
    // Animation and load
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [[country.childFields objectAtIndex:1] addSubview:animation];
    animation.frame = CGRectMake(0, 0, 280, 54);
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadRegionThread) object:nil] start];
}

- (void)loadRegionThread
{
    [collection load];
    [animation stopAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    if (!collection.loadCollectionFlag) {
        return;
    }
    MSFormAbstract *currentInput = [country.childFields objectAtIndex:1];
    if (![collection getSize]) {
        // Show Region Input
        if (![currentInput isEqual:regionField]) {
            regionIdField.hidden = YES;
            regionField.hidden = NO;
            [country.childFields removeObjectAtIndex:1];
            [country.childFields addObject:regionField];
        }
        [self.form reloadData];
        return;
    }
    // Show Region Id Input
    if (regionIdField == nil) {
        regionField.hidden = YES;
        [country.childFields removeObjectAtIndex:1];
        regionIdField = [country addField:@"Select" config:@{
            @"name": @"region_id",
            @"title": NSLocalizedString(@"State/Province", nil),
            @"height": [NSNumber numberWithInt:54]
        }];
    } else if (![currentInput isEqual:regionIdField]) {
        regionField.hidden = YES;
        regionIdField.hidden = NO;
        [country.childFields removeObjectAtIndex:1];
        [country.childFields addObject:regionIdField];
    }
    ((MSFormSelect *)regionIdField).dataSource = [collection regionAsDictionary];
    if ([self.form.formData objectForKey:@"region_id"] && [[((MSFormSelect *)regionIdField).dataSource allKeys] indexOfObject:[self.form.formData objectForKey:@"region_id"]] == NSNotFound) {
        [self.form.formData removeObjectForKey:@"region_id"];
    }
    [self.form reloadData];
}

- (void)changeCountry:(NSNotification *)note
{
    id sender = [note object];
    if (sender == nil || ![sender isEqual:countryField]) {
        return;
    }
    NSString *countryCode = [form.formData objectForKey:@"country_id"];
    if (countryCode == nil || [countryCode isEqualToString:@""]) {
        return;
    }
    [self reloadRegion];
}

#pragma mark - Action methods
- (void)cancelEdit
{
   [self.form.formData removeAllObjects];
   [self loadCustomerView];
    
}


-(void)forcusEmail{
    NSArray *childFields = [(MSFormRow *)self.email childFields];
    MSFormText *subField = (MSFormText *)[childFields objectAtIndex:0];
    [subField forcusInput];
}

@end
