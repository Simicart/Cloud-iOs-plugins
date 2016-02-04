//
//  SCEmailContactWorker.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactWorker.h"
#import "SCEmailContactViewController.h"
#import <SimiCartBundle/SimiSection.h>
#import <SimiCartBundle/SimiRow.h>
#import <SimiCartBundle/SCAppDelegate.h>
#import <SimiCartBundle/SCLeftMenuViewController.h>
#import <SimiCartBundle/SCNavigationBarPhone.h>
#import <SimiCartBundle/SCNavigationBarPad.h>

@implementation SCEmailContactWorker
{
    NSMutableArray * cells;
    NSMutableArray *activePlugins;
    NSMutableDictionary *dictInstantContact;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLeftMenu_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:SCLeftMenuDidSelectRow object:nil];
        activePlugins = [NSMutableArray new];
        activePlugins = [[SimiGlobalVar sharedInstance] activePlugin];
        for (NSMutableDictionary *activePlugin in activePlugins) {
            if ([[activePlugin valueForKey:@"sku"] isEqualToString:@"instant-contact"]) {
                dictInstantContact = [NSMutableDictionary new];
                dictInstantContact = activePlugin;
                break;
            }
        }
        if (dictInstantContact == nil) {
            [self createDataTest];
        }
    }
    return self;
}
-(void)createDataTest{
    dictInstantContact = [NSMutableDictionary new];
    [dictInstantContact setObject:@"Instant Contact" forKey:@"name"];
    [dictInstantContact setObject:@"instant-contact" forKey:@"sku"];
     NSMutableDictionary *configDict = [NSMutableDictionary new];
    [configDict setObject:@"1" forKey:@"enable"];
    [configDict setObject:@"CaoCuong@gmail.com" forKey:@"email"];
    [configDict setObject:@"01225622999" forKey:@"phone"];
    [configDict setObject:@"01225622999" forKey:@"message"];
    [configDict setObject:@"http://jsonlint.com/" forKey:@"website"];
    [configDict setObject:@"0" forKey:@"style"];
    [configDict setObject:@"#c73179" forKey:@"icon_color"];
    [dictInstantContact setObject:configDict forKey:@"config"];
    
}
-(void)didReceiveNotification:(NSNotification *)noti
{   
    if([noti.name isEqualToString:@"SCLeftMenu_InitCellsAfter"])
    {
        if (dictInstantContact && ([[[dictInstantContact valueForKey:@"config"] valueForKey:@"enable"] boolValue])) {
            cells = noti.object;
            for (int i = 0; i < cells.count; i++) {
                SimiSection *section = [cells objectAtIndex:i];
                if ([section.identifier isEqualToString:LEFTMENU_SECTION_MORE]) {
                    SimiRow *row = [[SimiRow alloc]initWithIdentifier:LEFTMENU_ROW_CONTACTUS height:50 sortOrder:50];
                    row.image = [UIImage imageNamed:@"ic_contact"];
                    row.title = SCLocalizedString(@"Contact Us");
                    row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    [section addObject:row];
                    [section sortItems];
                }
            }
        }
    }else if([noti.name isEqualToString:SCLeftMenuDidSelectRow]){
        UIViewController *currentVC = [(UITabBarController *)[[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController] selectedViewController];
        SimiRow *row = [noti.userInfo valueForKey:@"simirow"];
        if ([row.identifier isEqualToString:LEFTMENU_ROW_CONTACTUS]) {
            SCEmailContactViewController *emailViewController = [[SCEmailContactViewController alloc]init];
            emailViewController.dict = dictInstantContact ;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                SCNavigationBarPhone *navi = noti.object;
                navi.isDiscontinue = YES;
                [(UINavigationController*)currentVC pushViewController:emailViewController animated:YES];
            }else
            {
                SCNavigationBarPad *navi = noti.object;
                navi.popController = nil;
                navi.popController = [[UIPopoverController alloc] initWithContentViewController:[[UINavigationController alloc] initWithRootViewController:emailViewController]];
                emailViewController.isInPopover = YES;
                emailViewController.popover = navi.popController;
                [navi.popController presentPopoverFromRect:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1) inView:currentVC.view permittedArrowDirections:0 animated:YES];
                navi.isDiscontinue = YES;
            }
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
