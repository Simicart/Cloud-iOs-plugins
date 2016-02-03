//
//  BarCodeWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 1/16/15.
//  Copyright (c) 2015 Trueplus. All rights reserved.
//
#import <SimiCartBundle/SCHomeViewController.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SimiGlobalVar.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/UIImage+SimiCustom.h>
#import <SimiCartBundle/SimiTable.h>

#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCLeftMenuViewControllerPad.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>
#import "BarCodeWorker.h"
@implementation BarCodeWorker
{
    SimiTable *cells;
    UISearchBar *searchBar;
    UITableViewCell *cell;
    UIButton *btnScanBarCode;
    NSIndexPath *indexPath;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didInitCellsAfter:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didSelectRow:) name:SCLeftMenuDidSelectRow object:nil];
    }
    return self;
}

- (void)didInitCellsAfter:(NSNotification*)noti
{
    if ([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"])
    {
        cells = noti.object;
        for (int i = 0; i < cells.count; i++) {
            SimiSection *section = [cells objectAtIndex:i];
            if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
                SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_BARCODE height:50 sortOrder:60];
                row.image = [UIImage imageNamed:@"barcode_icon"];
                row.title = SCLocalizedString(@"QR Barcode");
                row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [section addObject:row];
                [section sortItems];
            }
        }
    }
}

- (void)didSelectRow:(NSNotification*)noti
{
    SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
    if ([row.identifier isEqualToString:LEFTMENU_ROW_BARCODE]) {
        [self didTapButtonScan];
    }
}

- (void)didTapButtonScan
{
    UIViewController *currentViewController = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication]delegate] window] rootViewController] selectedViewController];
    if (_barCodeViewController == nil) {
        _barCodeViewController = [BarCodeViewController new];
    }
    SimiNavigationController *navi = (SimiNavigationController*)currentViewController;
    if ([navi.viewControllers containsObject:_barCodeViewController]    ) {
        [navi popToViewController:_barCodeViewController animated:NO];
    }else
    {
        [navi pushViewController:_barCodeViewController animated:NO];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
