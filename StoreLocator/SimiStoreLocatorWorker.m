//
//  SimiStoreLocatorWorker.m
//  SimiCartPluginFW
//
//  Created by SimiCommerce on 6/25/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import "SimiStoreLocatorWorker.h"
#import <SimiCartBundle/SimiTableView.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiTable.h>
#import "SimiStoreLocatorViewController.h"
#import "SimiStoreLocatorViewControllerPad.h"
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
@implementation SimiStoreLocatorWorker
{
    SimiTable *cells;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectRow:) name:@"SCLeftMenuDidSelectRow" object:nil];
    }
    [GMSServices provideAPIKey:@"AIzaSyAmBe73HHr9CU1lYU96CFg6PTwG2i6NDwU"];
    return self;
}

- (void)initCellsAfter:(NSNotification*)noti
{
    cells = noti.object;
    for (int i = 0; i < cells.count; i++) {
        SimiSection *section = [cells objectAtIndex:i];
        if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
            SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_STORELOCATOR height:50 sortOrder:70];
            row.image = [UIImage imageNamed:@"storelocator_locator"];
            row.title = SCLocalizedString(@"Store Locator");
            row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            [section addObject:row];
            [section sortItems];
        }
    }
}

- (void)didSelectRow:(NSNotification*)noti
{
    SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
    SCNavigationBarPhone *navi = noti.object;
    if ([row.identifier isEqualToString:LEFTMENU_ROW_STORELOCATOR]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            SimiStoreLocatorViewControllerPad *storeLocatorViewController = [[SimiStoreLocatorViewControllerPad alloc]init];
            [(UINavigationController *)currentVC pushViewController:storeLocatorViewController animated:YES];
        }else
        {
            UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
            SimiStoreLocatorViewController *storeLocatorViewController = [[SimiStoreLocatorViewController alloc]init];
            [(UINavigationController *)currentVC pushViewController:storeLocatorViewController animated:YES];
        }
        navi.isDiscontinue = YES;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
