//
//  AddCustomerViewController.m
//
//  Created by Nguyen Duc Chien
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.
//

#import "AddCustomerViewController.h"
#import "CustomersViewController.h"
#import "ShowMenuButton.h"
#import "MarkLayerController.h"
#import "CustomerInfoViewController.h"
#import "CustomersListViewController.h"

#import "MSForm.h"
#import "RegionCollection.h"
#import "CountryCollection.h"

#import "Utilities.h"
#import "Address.h"
#import "MSValidator.h"

//Ravi
#import "GetCustomerAddressModel.h"
#import "RegionListModel.h"
#import "SaveCustomerAddressModel.h"
#import "SaveCustomerInfoModel.h"
#import "GetCustomerGroupsModel.h"
//End

@interface AddCustomerViewController (){
    Customer *newCustomer;
}
@property (strong, nonatomic) MSForm *form;
@property (strong, nonatomic) MSFormRow *country , *email ,*telephone;
@property (strong, nonatomic) MSFormAbstract *countryField, *regionField, *regionIdField;
@property (strong, nonatomic) RegionCollection *collection;

@property (strong, nonatomic) Customer *customer;
- (void)saveCustomerThread;

@property (strong, nonatomic) UIActivityIndicatorView *animation, *largeAnimation;
- (void)loadRegionThread;
@end

@implementation AddCustomerViewController

@synthesize infoController;
@synthesize form, country, countryField, regionField, regionIdField, collection;
@synthesize customer;
@synthesize animation, largeAnimation;
@synthesize email,telephone;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"New Customer", nil);
    
    [self createMenuNavigationBar];
    
    [self registerNotify];
    
    [self createForm];
    
    self.customer = [Customer new];
    
    [self reloadRegion];
    
    self.largeAnimation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.largeAnimation.frame = CGRectMake(10, 0, 586, 565);
    self.largeAnimation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.largeAnimation.color = [UIColor grayColor];
    [self.view addSubview:self.largeAnimation];
    
    
    
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

-(void)createMenuNavigationBar{

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelAddCustomer)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", nil) style:UIBarButtonItemStyleDone target:self action:@selector(saveCustomer)];
    self.navigationItem.rightBarButtonItem = saveButton;

}

-(void)registerNotify{
    //Ravi fix bug show keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(heightKeyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //End
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCountry:) name:@"MSFormFieldChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissController:) name:@"globalToggleViewMenu" object:nil];
}

-(void)createForm{
    // Edit Customer Form
    self.form = [MSForm new];
    self.form.frame = CGRectMake(1, 0, 595, 688);
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

    
    telephone = (MSFormRow *)[form addField:@"Row" config:@{
                                                                   @"height": height
                                                                   }];
    [telephone addField:@"Number" config:@{
                                       @"name": @"telephone",
                                       @"title": NSLocalizedString(@"Phone", nil),
                                       @"height": height
                                       }];
    [telephone addField:@"Number" config:@{
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
    
    
}

- (void)cancelAddCustomer
{
    [self.infoController.listController.tableView setAllowsSelection:YES];
    [self.editNav popViewControllerAnimated:NO];
}

- (void)dismissController:(NSNotification *)note
{
    id object = [note object];
    if (object && ![object isKindOfClass:[CustomersViewController class]] && ![object isKindOfClass:[ShowMenuButton class]] && ![object isKindOfClass:[MarkLayerController class]]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

-(void)forcusEmail{
    NSArray *childFields = [(MSFormRow *)self.email childFields];
    MSFormText *subField = (MSFormText *)[childFields objectAtIndex:0];
    [subField forcusInput];
}


#pragma mark - save customer
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
    
    [[[NSThread alloc] initWithTarget:self selector:@selector(saveCustomerThread) object:nil] start];
}

- (void)saveCustomerThread
{
    //Ravi
    NSMutableDictionary *newDataCustomer = [NSMutableDictionary new];
    [newDataCustomer addEntriesFromDictionary:customer];
    if ([form.formData objectForKey:@"firstname"]) {
        [newDataCustomer setValue:[form.formData objectForKey:@"firstname"] forKey:@"firstname"];
    }
    if ([form.formData objectForKey:@"lastname"]) {
        [newDataCustomer setValue:[form.formData objectForKey:@"lastname"] forKey:@"lastname"];
    }
    if ([form.formData objectForKey:@"email"]) {
        [newDataCustomer setValue:[form.formData objectForKey:@"email"] forKey:@"email"];
    }
    if ([form.formData objectForKey:@"telephone"]) {
        [newDataCustomer setValue:[form.formData objectForKey:@"telephone"] forKey:@"telephone"];
    }
    if ([form.formData objectForKey:@"group_id"]) {
        [newDataCustomer setValue:[form.formData objectForKey:@"group_id"] forKey:@"group_id"];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveCustomerInfo:) name:@"DidSaveCustomerInfo" object:nil];
    SaveCustomerInfoModel *saveCustomerInfoModel = [SaveCustomerInfoModel new];
    [saveCustomerInfoModel saveCustomerInfoWithData:newDataCustomer];
    return;
    //End
    
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
        [largeAnimation stopAnimating];
        
        [Utilities toastSuccessTitle:@"Customer" withMessage:MESSAGE_ADD_SUCCESS withView:self.view];
        
        Customer *newCustomer = (Customer *)[note object];
        [self.infoController.listController findCustomer:newCustomer];
        
        if (newCustomer) {
            // Change size of customer list
            if (![self.customer getId]) {
                CustomerCollection *list = self.infoController.listController.customerList;
                if ([list getSize] >= [list getTotalItems]) {
                    NSUInteger index = [list getSize];
                    [list.sortedIndex setObject:[NSNumber numberWithInteger:index] atIndexedSubscript:index];
                    [list setValue:self.customer forKey:[list.sortedIndex objectAtIndex:index]];
                    [list setTotalItems:([list getTotalItems] + 1)];
                    [self.customer addData:newCustomer];
                    [self.infoController.listController.tableView reloadData];
                    
                } else {
                    [self.customer addData:newCustomer];
                }
            } else {
                [self.customer addData:newCustomer];
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
                [savedAddress repairStreetAddress];
                [self.customer addData:savedAddress];
            }
            [self performSelectorOnMainThread:@selector(cancelAddCustomer) withObject:nil waitUntilDone:NO];
        }];
        Address *saveAddress = [Address new];
        [saveAddress addEntriesFromDictionary:form.formData];
        [saveAddress implodeAddressLines];
        [saveAddress setValue:[self.customer getId] forKey:@"customer_id"];
        if ([self.customer objectForKey:@"address_id"]) {
            [saveAddress setValue:[self.customer objectForKey:@"address_id"] forKey:@"id"];
        } else {
            [saveAddress removeObjectForKey:@"id"];
        }
        [saveAddress setValue:[NSNumber numberWithBool:YES] forKey:@"is_default_billing"];
        [saveAddress setValue:[NSNumber numberWithBool:YES] forKey:@"is_default_shipping"];
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
    
    //
    if ([form.formData objectForKey:@"fax"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"fax"] forKey:@"fax"];
    }
    
    if ([form.formData objectForKey:@"street[0]"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"street[0]"] forKey:@"street[0]"];
    }
    
    if ([form.formData objectForKey:@"street[1]"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"street[1]"] forKey:@"street[1]"];
    }
    
    if ([form.formData objectForKey:@"city"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"city"] forKey:@"city"];
    }
    
    if ([form.formData objectForKey:@"postcode"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"postcode"] forKey:@"postcode"];
    }
    
    if ([form.formData objectForKey:@"country_id"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"country_id"] forKey:@"country_id"];
    }
    
    if ([form.formData objectForKey:@"region"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"region"] forKey:@"region"];
    }
    
    if ([form.formData objectForKey:@"company"]) {
        [saveCustomer setValue:[form.formData objectForKey:@"company"] forKey:@"company"];
    }
    
    
    [saveCustomer save];
    
    [[NSNotificationCenter defaultCenter] removeObserver:success];
    [[NSNotificationCenter defaultCenter] removeObserver:failure];
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
    //Ravi
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRegionList:) name:@"DidGetRegionList" object:nil];
    RegionListModel *regionListModel = [RegionListModel new];
    [regionListModel getRegionListWithCountryCode:collection.countryCode];
    return;
    
    
    //End
    
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

//Ravi
- (void)didGetRegionList :(NSNotification*)noti{
    [animation stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didGetRegionList - %@",respone.data);
        
        //        [collection addEntriesFromDictionary:respone.data];
        if (collection.sortedIndex == nil) {
            collection.sortedIndex = [NSMutableArray new];
        }
        [collection.sortedIndex removeAllObjects];
        [collection removeAllObjects];
        for (NSString *key in [respone.data allKeys]) {
            if (![key isEqualToString:@"total"]) {
                [collection.sortedIndex addObject:key];
                ModelAbstract *region = [ModelAbstract new];
                [region setData:[respone.data objectForKey:key]];
                [region setValue:key forKey:@"id"];
                [collection setObject:region forKey:key];
            }
        }
        
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        //        if (!collection.loadCollectionFlag) {
        //            return;
        //        }
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
        
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) didSaveCustomerInfo : (NSNotification *)noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didSaveCustomerInfo - %@",respone.data);
        newCustomer = [Customer new];
        [newCustomer addEntriesFromDictionary:respone.data];
        [customer setValue:[newCustomer getId] forKey:@"id"];
        
        Address *saveAddress = [Address new];
        [saveAddress addEntriesFromDictionary:form.formData];
        [saveAddress implodeAddressLines];
        [saveAddress setValue:[newCustomer getId] forKey:@"customer_id"];
        //        [saveAddress save];
        
        NSDictionary *dataAddressNew = [[NSDictionary alloc]initWithDictionary:saveAddress];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveCustomerAddress:) name:@"DidSaveCustomerAddress" object:nil];
        SaveCustomerAddressModel * saveCustomerAddressModel = [SaveCustomerAddressModel new];
        [saveCustomerAddressModel saveCustomerAddressWithData:dataAddressNew];
        // Stop animation
        [animation stopAnimating];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }else{
        [animation stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void) didSaveCustomerAddress : (NSNotification *)noti{
    [largeAnimation stopAnimating];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:noti.name object:nil];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        DLog(@"didSaveCustomerAddress - %@",respone.data);
        [customer addData:form.formData];
        [self performSelectorOnMainThread:@selector(cancelAddCustomer) withObject:nil waitUntilDone:NO];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message: [respone.message objectAtIndex:0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//End

@end
