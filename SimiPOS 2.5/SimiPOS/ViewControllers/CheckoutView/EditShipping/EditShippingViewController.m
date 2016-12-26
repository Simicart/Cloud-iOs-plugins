//
//  EditShippingViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 12/17/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "EditShippingViewController.h"

#import "Quote.h"
#import "CountryCollection.h"
#import "Region.h"
#import "RegionCollection.h"
#import "Address.h"

@interface EditShippingViewController ()
@property (strong, nonatomic) MSFormRow *country;
@property (strong, nonatomic) MSFormAbstract *countryField, *regionField, *regionIdField;
@property (strong, nonatomic) RegionCollection *collection;

- (void)loadAddressDataThread;
- (void)saveShippingAddressThread;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)loadRegionThread;
@end

@implementation EditShippingViewController{
   //Gin
    BOOL isShowKeyboard;
}
@synthesize customer, form;
@synthesize country, countryField, regionField, regionIdField;
@synthesize collection, animation;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Navigation button
    isShowKeyboard = NO;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelEdit)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveShippingAddress)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    // Navigation Title
    self.title = NSLocalizedString(@"Edit Shipping Address", nil);
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Form
    self.form = [MSForm new];
    self.form.frame = CGRectMake(0, 0, 545, 580);
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
    // phone and address
    [form addField:@"Number" config:@{
        @"name": @"telephone",
        @"title": NSLocalizedString(@"Phone", nil),
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
    MSFormRow *company = (MSFormRow *)[form addField:@"Row" config:@{
        @"height": height
    }];
    [company addField:@"Text" config:@{
        @"name": @"company",
        @"title": NSLocalizedString(@"Company", nil),
        @"height": height
    }];
    [company addField:@"Number" config:@{
        @"name": @"fax",
        @"title": NSLocalizedString(@"Fax", nil),
        @"height": height
    }];
    
    [form addField:@"Boolean" config:@{
        @"name": @"save_in_address_book",
        @"title": NSLocalizedString(@"Save In Address Book", nil),
        @"height": height
    }];
    

    //Ravi fix bug show keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heightKeyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //End
    
    // Load form data
    self.customer = [Quote sharedQuote].customer;
    [self loadAddressData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountry:) name:@"MSFormFieldChange" object:nil];
}


//Ravi fix bug show keyboard
- (void)heightKeyboardWillChange: (NSNotification*)noti{
    NSDictionary* keyboardInfo = [noti userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    CGRect frame = self.view.bounds;
    frame.size.height = keyboardFrameEndRect.origin.y - 64;
    self.form.frame = frame;
}
//End


#pragma mark - Action methods
- (void)cancelEdit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveShippingAddress
{
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [self.form addSubview:animation];
    CGRect frame = self.form.bounds;
    frame.size.height -= 48;
    animation.frame = frame;
    [animation startAnimating];
    
    // Disable Save button
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveShippingAddressThread) object:nil] start];
}

- (void)saveShippingAddressThread
{
    id failure = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    
    id success = [[NSNotificationCenter defaultCenter] addObserverForName:@"AddressSaveAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self performSelectorOnMainThread:@selector(cancelEdit) withObject:nil waitUntilDone:NO];
        // Reload totals, shipping methods
        [[Quote sharedQuote] loadQuoteTotals];
    }];
    
    Address *saveAddress = [Address new];
    [saveAddress addEntriesFromDictionary:form.formData];
    [saveAddress implodeAddressLines];
    // Remove unexpected field
    [saveAddress removeObjectForKey:@"id"];
    [saveAddress removeObjectForKey:@"customer_address_id"];
    [saveAddress removeObjectForKey:@"email"];
    [saveAddress removeObjectForKey:@"address_type"];
    [saveAddress setValue:@"shipping" forKey:@"mode"];
    [saveAddress saveShipping];
    
    // Stop animation
    [animation stopAnimating];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
    [[NSNotificationCenter defaultCenter] removeObserver:success];
}

#pragma mark - Load Shipping Data
- (void)loadAddressData
{
    // Animation
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [self.form addSubview:animation];
    CGRect frame = self.form.bounds;
    frame.size.height -= 48;
    animation.frame = frame;
    [animation startAnimating];
    
    // Load address of customer
    [[[NSThread alloc] initWithTarget:self selector:@selector(loadAddressDataThread) object:nil] start];
}

- (void)loadAddressDataThread
{
    Address *shipping = [Address new];
    [shipping loadShipping];
//    [shipping addData:[Quote sharedQuote].shipping];
    [shipping repairStreetAddress];
    [self.form loadFormData:shipping];
    [self.form reloadData];
    
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

#pragma mark - locale methods
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

@end
