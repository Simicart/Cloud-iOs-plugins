//
//  CustomerEditViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 11/24/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "CustomerEditViewController.h"

#import "Quote.h"
#import "CountryCollection.h"
#import "Region.h"
#import "RegionCollection.h"
#import "Address.h"

#import "APIManager.h"
#import "MSValidator.h"

@interface CustomerEditViewController ()
@property (strong, nonatomic) MSFormRow *country,*customerGroup,*name,*email;
@property (strong, nonatomic) MSFormAbstract *countryField, *regionField, *regionIdField, *customerGroupField;
@property (strong, nonatomic) RegionCollection *collection;

- (void)loadCustomerDataThread;
- (void)saveCustomerThread;

@property (strong, nonatomic) UIActivityIndicatorView *animation;
- (void)loadRegionThread;
@end

@implementation CustomerEditViewController
@synthesize customer, form;
@synthesize country, countryField, regionField, regionIdField, customerGroupField,customerGroup,name,email;
@synthesize collection, animation;


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //  [self performSelector:@selector(forcusFirstName) withObject:nil afterDelay:2.0];
    
  //  [self forcusFirstName];
    
}

-(void)createMenuNavigationBar{
    UIButton *buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    buttonCancel.layer.cornerRadius =3.0;
    buttonCancel.backgroundColor =[UIColor buttonCancelColor];
    [buttonCancel addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton =[[UIBarButtonItem alloc] initWithCustomView:buttonCancel];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    UIButton *rightbutton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    [rightbutton setTitle:@"Save" forState:UIControlStateNormal];
    rightbutton.backgroundColor =[UIColor buttonSubmitColor];
    rightbutton.layer.cornerRadius =3.0;
    [rightbutton addTarget:self action:@selector(saveCustomer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem =[[UIBarButtonItem alloc] initWithCustomView:rightbutton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createMenuNavigationBar];
    
    // Navigation Title
    if ([[Quote sharedQuote] hasCustomer]) {
        self.title = NSLocalizedString(@"Edit Customer", nil);
    } else {
        self.title = NSLocalizedString(@"New Customer", nil);
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // Form
    self.form = [MSForm new];
    self.form.frame = CGRectMake(0, 0, 540, 600);
    
    [self.view addSubview:self.form];
    self.form.rowHeight = 54;
    
    // Form Fields
    NSNumber *height = [NSNumber numberWithFloat:form.rowHeight];
    
    // Customer Name
    name = (MSFormRow *)[form addField:@"Row" config:@{
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
    [email addField:@"Number" config:@{
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
    
    
    // DLog(@"country:%@",[CountryCollection allCountryAsDictionary]);
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
    
    customerGroup = (MSFormRow *)[form addField:@"Row" config:@{
                                                                @"height": height
                                                                }];
    [[APIManager shareInstance] getCustomerGroups:^(BOOL success, id result) {
        if(success){
            customerGroupField = [customerGroup addField:@"Select" config:@{
                                                                            @"name": @"group_id",
                                                                            @"title": NSLocalizedString(@"Group", nil),
                                                                            @"height": height,
                                                                            @"source": [result objectForKey:@"data"]
                                                                            }];
        }
    }];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeFormHeight:) name:UIKeyboardDidShowNotification object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFormHeight:) name:UIKeyboardWillHideNotification object:nil];
    
    // Load form data
    self.customer = [Quote sharedQuote].customer;
    
    DLog(@"customer:%@",self.customer);
    
    [self loadCustomerData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountry:) name:@"MSFormFieldChange" object:nil];
    
}

- (void)resizeFormHeight:(NSNotification *)note
{
    CGRect frame = self.form.frame;
    frame.size.height -= 132;
    self.form.frame = frame;
}

- (void)returnFormHeight:(NSNotification *)note
{
    CGRect frame = self.form.frame;
    frame.size.height += 132;
    self.form.frame = frame;
}

#pragma mark - Action methods
- (void)cancelEdit
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ClosePopupWindow" object:nil];
    }];
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
    
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [self.form addSubview:animation];
    CGRect frame = self.form.bounds;
    frame.size.height -= 108;
    animation.frame = frame;
    [animation startAnimating];
    
    // Disable Save button
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveCustomerThread) object:nil] start];
}

- (void)saveCustomerThread
{
    // Process Observer
    id failtObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"QueryException" object:nil queue:nil usingBlock:^(NSNotification *note) {
        // Error when query
        NSDictionary *userInfo = [note userInfo];
        if (userInfo != nil && [userInfo objectForKey:@"reason"]) {
            [animation stopAnimating];
            [self.navigationItem.rightBarButtonItem setEnabled:YES];
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:[userInfo objectForKey:@"reason"]];
        }
    }];
    
    id successObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"CustomerSaveAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
        Customer *newCustomer = (Customer *)[note object];
        [customer setValue:[newCustomer getId] forKey:@"id"];
        
        // Save customer Address
        id saveAddressSuccess = [[NSNotificationCenter defaultCenter] addObserverForName:@"AddressSaveAfter" object:nil queue:nil usingBlock:^(NSNotification *note) {
            // Dismiss form
            [self performSelectorOnMainThread:@selector(cancelEdit) withObject:nil waitUntilDone:NO];
            // Set customer for current Quote, run on current thread
            [[Quote sharedQuote] forceAssignCustomer:newCustomer];
        }];
        Address *saveAddress = [Address new];
        [saveAddress addEntriesFromDictionary:form.formData];
        [saveAddress implodeAddressLines];
        [saveAddress setValue:[newCustomer getId] forKey:@"customer_id"];
        [saveAddress save];
        
        // Stop animation
        [animation stopAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:saveAddressSuccess];
    }];
    // Save Customer
    Customer *saveCustomer = [Customer new];
    [saveCustomer addEntriesFromDictionary:customer];
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
    if ([form.formData objectForKey:@"group_id"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"group_id"] forKey:@"group_id"];
    }
    [saveCustomer save];
    
    // remove event listener
    [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:failtObserver];
}

#pragma mark - Load customer data
- (void)loadCustomerData
{
    [self.form loadFormData:customer];
    if ([[Quote sharedQuote] hasCustomer]) {
        // Animation
        if (animation == nil) {
            animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }
        [self.form addSubview:animation];
        CGRect frame = self.form.bounds;
        frame.size.height -= 108;
        animation.frame = frame;
        [animation startAnimating];
        
        // Load address of customer
        [[[NSThread alloc] initWithTarget:self selector:@selector(loadCustomerDataThread) object:nil] start];
    } else {
        [self reloadRegion];
    }
}

- (void)loadCustomerDataThread
{
    // Load customer address data
    Address *billing = [Address new];
    [billing loadBilling:[customer getId]];
    [self.form loadFormData:billing];
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

-(void)forcusFirstName{
    NSArray *childFields = [(MSFormRow *)name childFields];
    
    MSFormText *subField = (MSFormText *)[childFields objectAtIndex:0];
    
    if(self.customer && [self.customer objectForKey:@"name"]){
        NSString * customerName =[NSString stringWithFormat:@"%@",[self.customer objectForKey:@"name"]];
        subField.inputText.text=customerName;
    }
    [subField forcusInput];
}

-(void)forcusEmail{
    NSArray *childFields = [(MSFormRow *)email childFields];
    MSFormText *subField = (MSFormText *)[childFields objectAtIndex:0];
    [subField forcusInput];
}



@end
