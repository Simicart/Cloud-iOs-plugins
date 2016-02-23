//
//  SCFBConnectWorker.m
//  SimiCartPluginFW
//
//  Created by Axe in 2015.
//  Copyright (c) 2015 SimiCart. All rights reserved.
//

#import "SCFBConnectWorker.h"
#import "FacebookConnect.h"
#import "SimiCustomerModel+Facebook.h"
#import <SimiCartBundle/KeychainItemWrapper.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>



@implementation SCFBConnectWorker{
    NSMutableArray *cells;
    SimiCustomerModel *customer;
    SimiViewController *viewController;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCProductViewMoreController-ViewDidLoadBefore" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLoginViewController_InitCellsAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationOpenURL" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"DidLogout" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"SCLoginViewController_InitCellAfter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"ApplicationWillTerminate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"AutoLoginWithFacebook" object:nil];
        
    }
    return self;
}

- (void)didReceiveNotification:(NSNotification*)noti
{
    
    if ([noti.name isEqualToString:@"SCProductViewMoreController-ViewDidLoadBefore"]) {
        FacebookConnect *facebookConnect = [[FacebookConnect alloc]initWithObject:noti.object];
        facebookConnect.productMoreVC = noti.object;
        if (self.arrayFacebookConnect == nil) {
            self.arrayFacebookConnect = [[NSMutableArray array]init];
        }
        [self.arrayFacebookConnect addObject:facebookConnect];
    }else if ([noti.name isEqualToString:@"SCLoginViewController_InitCellsAfter"]) {
        cells = noti.object;
        viewController = (SimiViewController*)[noti.userInfo valueForKey:@"controller"];
        SimiSection *section = [cells objectAtIndex:0];
        SimiRow *row = [[SimiRow alloc] initWithIdentifier:@"FacebookLoginCell" height:60];
        [section addRow:row];
    }else if ([noti.name isEqualToString:@"SCLoginViewController_InitCellAfter"]){
        NSIndexPath *indexPath = [noti.userInfo valueForKey:@"indexPath"];
        SimiSection *section = [cells objectAtIndex:indexPath.section];
        SimiRow *row = [section objectAtIndex:indexPath.row];
        
        if ([row.identifier isEqualToString:@"FacebookLoginCell"]) {
            UITableViewCell *cell = noti.object;
            FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
            loginButton.readPermissions = @[@"email"];

            float widthCell = 7 *SCREEN_WIDTH/8;
            float heightCell = SCREEN_HEIGHT/16.2142857143f;
            float paddingY = SCREEN_HEIGHT/37.8333333333f/2;
            float paddingX = SCREEN_WIDTH/16;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                float widthTable = (SCREEN_WIDTH*2/3);
                widthCell = 7 *widthTable/8;
                heightCell = widthTable/16.2142857143f;
                paddingY = widthTable/37.8333333333f/2;
                paddingX = widthTable/16;
            }
            
            loginButton.delegate = self;
            loginButton.frame = CGRectMake(paddingX, paddingY , widthCell, heightCell);
//            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
//            [loginManager logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//                //TODO: process error or result
//            }];
            cell.backgroundColor = [UIColor clearColor];
            [cell addSubview:loginButton];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }
  
    else if ([noti.name isEqualToString:@"ApplicationOpenURL"]){
       
        BOOL numberBool = [[noti object] boolValue];
        numberBool  = [[FBSDKApplicationDelegate sharedInstance] application:[[noti userInfo] valueForKey:@"application"] openURL:[[noti userInfo] valueForKey:@"url"] sourceApplication:[[noti userInfo] valueForKey:@"source_application"] annotation:[[noti userInfo] valueForKey:@"annotation"]];
   
        
    }
    else if ([noti.name isEqualToString:@"DidLogout"] || [noti.name isEqualToString:@"ApplicationWillTerminate"]){
        [[[FBSDKLoginManager alloc] init] logOut];
    }
    else if([noti.name isEqualToString:@"DidLogin"])
    {
        
    }
    else if([noti.name isEqualToString:@"AutoLoginWithFacebook"])
    {
        
        NSString *stringEmail = noti.object;
        NSString *stringName = [noti.userInfo valueForKey:@"name"];
        if (customer == nil) {
            customer = [[SimiCustomerModel alloc]init];
            [customer loginWithFacebookEmail:stringEmail name:stringName];
        }
       
    }
}



#pragma mark FB Login Button Delegates
-(void) loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,email,name" forKey:@"fields"];
    if([FBSDKAccessToken currentAccessToken]){
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 if([result isKindOfClass:[NSDictionary class]]){
                     
                     NSString *email = [result objectForKey:@"email"];
                     NSString *name = SCLocalizedString([result objectForKey:@"name"]);
                     if(customer == nil)
                         customer = [SimiCustomerModel new];
//                     NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
//                     NSString *bundleIdentifier = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleIdentifier"]];
//                     KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:bundleIdentifier accessGroup:nil];
//                     [wrapper setObject:name forKey:(__bridge id)(kSecAttrComment)];
//                     [wrapper setObject:@"loginwithfacebook" forKey:(__bridge id)(kSecAttrLabel)];
                     
                     if(email && name){
                     [customer loginWithFacebookEmail:email name:name];
                     [[NSNotificationCenter defaultCenter] postNotificationName:@"SimiFaceBookWorker_StartLoginWithFaceBook" object:nil];
                         [viewController startLoadingData];
                     }
                 }
                 
             }
         }];
    }
}

-(void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}


#pragma mark Dead Log
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
