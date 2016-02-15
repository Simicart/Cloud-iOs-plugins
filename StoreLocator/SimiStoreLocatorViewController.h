//
//  SimiStoreLocatorViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 6/30/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiTabViewController.h>
#import "SimiCLController.h"
#import "SimiStoreLocatorListViewController.h"
#import "SimiStoreLocatorMapViewController.h"
#import "SimiStoreLocatorModelCollection.h"
#import "SimiStoreLocatorDetailViewController.h"
#import "SimiStoreLocatorModel.h"
#import "SimiStoreLocatorSearchViewController.h"

#import "SimiAddressStoreLocatorModelCollection.h"
#import "SimiConfigSearchStoreLocatorModel.h"
#import "SimiTagModelCollection.h"

@interface SimiStoreLocatorViewController : SimiTabViewController<
                                            CLLocationManagerDelegate,
                                            SimiTabViewDataSource,
                                            SimiTabViewDelegate,
                                            SimiStoreLocatorListViewControllerDelegate,
                                            SimiStoreLocatorDetailViewControllerDelegate,
                                            SimiStoreLocatorMapViewControllerDelegate,
                                            SimiStoreLocatorSearchViewControllerDelegate>
{
    SimiStoreLocatorListViewController *sLListViewController;
    SimiStoreLocatorMapViewController *sLMapViewController;
}

@property (nonatomic, strong) SimiStoreLocatorModelCollection *storeLocatorModelCollection;
@property (nonatomic, strong) SimiStoreLocatorModel *slModel;
@property (nonatomic, strong) SimiAddressStoreLocatorModelCollection *simiAddressStoreLocatorModelCollection;
@property (nonatomic, strong) SimiConfigSearchStoreLocatorModel *simiConfigSearchStoreLocatorModel;
@property (nonatomic, strong) SimiTagModelCollection *simiTagModelCollection;
@property (nonatomic, strong) NSString *tagChoise;
@property (nonatomic, strong) UIBarButtonItem *searchButton;

@end
