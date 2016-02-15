//
//  SimiStoreLocatorViewController_iPad.h
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/ILTranslucentView.h>
#import <SimiCartBundle/SimiViewController.h>
#import "SimiStoreLocatorListViewController.h"
#import "SimiStoreLocatorMapViewController.h"
#import "SimiCLController.h"
#import "SimiStoreLocatorDetailViewController.h"
#import "SimiStoreLocatorSearchViewController.h"
extern NSInteger const widthListView;
extern NSInteger const heightButtonSearch;

typedef NS_ENUM(NSInteger, ButtonSearchOption)
{
    ButtonSearchOptionPortrait,
    ButtonSearchOptionLandscape
};

@interface SimiStoreLocatorViewControllerPad : SimiViewController<SimiStoreLocatorListViewControllerDelegate, SimiStoreLocatorMapViewControllerDelegate, UIPopoverControllerDelegate,SimiCLControllerDelegate, SimiStoreLocatorSearchViewControllerDelegate>
{
    SimiStoreLocatorListViewController *sLListViewControllerPortrait;
    SimiStoreLocatorListViewController *sLListViewControllerLandscape;
    SimiStoreLocatorMapViewController *sLMapViewController;
    SimiCLController *cLController;
    SimiStoreLocatorSearchViewController *searchViewController;
    SimiStoreLocatorDetailViewController *detailViewController;
}

@property (nonatomic, strong) ILTranslucentView *viewToolBar;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) UIButton *btnSearch;
@property (nonatomic, strong) UIButton *btnStoreLocatorListView;
@end
