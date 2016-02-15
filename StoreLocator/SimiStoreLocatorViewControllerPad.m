//
//  SimiStoreLocatorViewController_iPad.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 7/18/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SimiStoreLocatorViewControllerPad.h"
#import "SimiGlobalVar+StoreLocator.h"
NSInteger const widthListView = 330;
NSInteger const heightButtonSearch = 50;



@interface SimiStoreLocatorViewControllerPad ()

@end

@implementation SimiStoreLocatorViewControllerPad
{
    BOOL ispopOverController;
    BOOL isSearchViewController;
    BOOL isDetailViewController;
}
@synthesize viewToolBar, popOverController, popOver, btnSearch, btnStoreLocatorListView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark
#pragma mark View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    sLListViewControllerLandscape = [[SimiStoreLocatorListViewController alloc]init];
    sLListViewControllerLandscape.delegate = self;
    sLListViewControllerLandscape.sLModelCollection = [[SimiStoreLocatorModelCollection alloc]init];
    
    sLListViewControllerPortrait = [[SimiStoreLocatorListViewController alloc]init];
    sLListViewControllerPortrait.delegate = self;
    sLListViewControllerPortrait.sLModelCollection = [[SimiStoreLocatorModelCollection alloc]init];
    
    sLListViewControllerLandscape.sLModelCollection = sLListViewControllerPortrait.sLModelCollection;
    
    cLController = [[SimiCLController alloc]init];
    cLController.delegate = self;
    if (SIMI_SYSTEM_IOS >= 8.0) {
        [cLController.locationManager requestAlwaysAuthorization];
    }
    [cLController.locationManager startUpdatingLocation];

    [self addChildViewController:sLListViewControllerLandscape];
    // Do any additional setup after loading the view.
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft
        || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        [self setInterfaceLandscape];
    }else
    {
        [self setInterfacePortrait];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark SimiCLController Delegate
- (void)locationUpdate:(CLLocation *)location
{
    [cLController.locationManager stopUpdatingLocation];
    [self didGetCurrentLocationWithLatitube:location.coordinate.latitude andLongitube:location.coordinate.longitude];
}

- (void)locationError:(NSError *)error
{
    [self didGetCurrentLocationWithLatitube:0 andLongitube:0];
}

- (void) didGetCurrentLocationWithLatitube:(float)la andLongitube:(float)lng
{
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    sLMapViewController.delegate = self;
    sLMapViewController.currentLatitube = la;
    sLMapViewController.currentLongitube = lng;
    sLMapViewController.sLModelCollectionSyncList = sLListViewControllerLandscape.sLModelCollection;
    
    [self addChildViewController:sLMapViewController];
}

#pragma mark
#pragma mark Search Action
- (void)btnSearch_Click
{
    if (searchViewController == nil) {
        searchViewController = [SimiStoreLocatorSearchViewController new];
        searchViewController.delegate = self;
    }
    searchViewController.currentLatitube = sLMapViewController.currentLatitube;
    searchViewController.currentLongitube = sLMapViewController.currentLongitube;
    if (popOverController == nil) {
        popOverController = [[UIPopoverController alloc]initWithContentViewController:searchViewController];
        popOverController.delegate = self;
        CGRect rect = CGRectMake(SCREEN_WIDTH - 250, SCREEN_HEIGHT/2, 1, 1);
        if (SIMI_SYSTEM_IOS > 7.0){
            [self.popOverController setBackgroundColor:[UIColor whiteColor]];
        }
        [self.popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
        ispopOverController = YES;
        isSearchViewController = YES;
    }
}

#pragma mark
#pragma mark btnListView Click
- (void)btnStoreLocatorListView_Click:(id)sender
{
    UIButton* senderButton = (UIButton*)sender;
        //Create the ColorPickerViewController.
    
    sLListViewControllerPortrait.preferredContentSize = CGSizeMake(widthListView, 800);
    
    if (popOver == nil) {
        //The color picker popover is not showing. Show it.
        popOver = [[UIPopoverController alloc] initWithContentViewController:sLListViewControllerPortrait];
        if (SIMI_SYSTEM_IOS >= 7.0)
            [popOver setBackgroundColor:[UIColor whiteColor]];
        popOver.delegate = self;
        [popOver presentPopoverFromRect:senderButton.bounds inView:senderButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [popOver dismissPopoverAnimated:YES];
        popOver = nil;
    }
}

#pragma mark
#pragma mark btnSearch
- (UIButton*)setInterfaceButtonSearch:(ButtonSearchOption)searchOption
{
    btnSearch = [[UIButton alloc]init];
    [btnSearch addTarget:self action:@selector(btnSearch_Click) forControlEvents:UIControlEventTouchUpInside];
    switch (searchOption) {
        case ButtonSearchOptionLandscape:
            [btnSearch setFrame:CGRectMake(0, 0, widthListView, heightButtonSearch)];
            [btnSearch setTitle:@"Search By Area" forState:UIControlStateNormal];
            [btnSearch setTitleColor:[self colorWithStringHex:@"adadb1"] forState:UIControlStateNormal];
            [btnSearch.titleLabel setFont:[UIFont fontWithName:THEME_FONT_NAME size:THEME_FONT_SIZE]];
            btnSearch.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:230.0/255.0 alpha:1.0];
            break;
        case ButtonSearchOptionPortrait:
            [btnSearch setFrame:CGRectMake(SCREEN_WIDTH - 60,0, 50, 50)];
            [btnSearch setTitle:@"" forState:UIControlStateNormal];
            [btnSearch setImage:[UIImage imageNamed:@"sl__search_area.png"] forState:UIControlStateNormal];
            btnSearch.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
            btnSearch.backgroundColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    return btnSearch;
}

#pragma mark
#pragma mark Set Interface List, Map
- (void)setInterfacePortrait
{
    
    [sLListViewControllerLandscape.view removeFromSuperview];
    [sLMapViewController.view removeFromSuperview];
    [btnSearch removeFromSuperview];
    
    btnStoreLocatorListView = [[UIButton alloc]init ];
    [btnStoreLocatorListView setFrame:CGRectMake(0, 0, 50, 50)];
    btnStoreLocatorListView.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    btnStoreLocatorListView.backgroundColor = [UIColor clearColor];
    [btnStoreLocatorListView setImage:[UIImage imageNamed:@"sl_icon_list.png"] forState:UIControlStateNormal];
    [btnStoreLocatorListView addTarget:self action:@selector(btnStoreLocatorListView_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    frame.size.height = 50;
    viewToolBar = [[ILTranslucentView alloc] initWithFrame:frame];
    viewToolBar.backgroundColor = [UIColor clearColor];
    viewToolBar.translucentTintColor = [UIColor clearColor];
    viewToolBar.alpha = 1;
    viewToolBar.translucentStyle = UIBarStyleDefault;
    
    [self setInterfaceButtonSearch:ButtonSearchOptionPortrait];
    [viewToolBar addSubview:btnSearch];
    [viewToolBar addSubview:btnStoreLocatorListView];
    
    [self.view addSubview:viewToolBar];
    
    [sLMapViewController.view setFrame:CGRectMake(0, viewToolBar.bounds.size.height, SCREEN_WIDTH, self.view.bounds.size.height)];
    [self.view addSubview:sLMapViewController.view];
}

- (void)setInterfaceLandscape
{
    [sLMapViewController.view removeFromSuperview];
    [viewToolBar removeFromSuperview];
    
    [self setInterfaceButtonSearch:ButtonSearchOptionLandscape];
    [self.view addSubview:btnSearch];
    
    UIImageView *imageSearch = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"storelocator_icon_search.png"]];
    [imageSearch setFrame:CGRectMake(70, 15, 16, 16)];
    [self.view addSubview:imageSearch];
    
    [sLListViewControllerLandscape.view setFrame:CGRectMake(0, heightButtonSearch, widthListView, self.view.bounds.size.height)];
    [self.view addSubview:sLListViewControllerLandscape.view];
    
    [sLMapViewController.view setFrame:CGRectMake(widthListView, 0, SCREEN_WIDTH - widthListView, self.view.bounds.size.height)];
    [self.view addSubview:sLMapViewController.view];
}


#pragma mark
#pragma mark ListViewController Delegate
-(void)didChoiseStoreFromListToMap
{
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft
        || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
    {
         sLMapViewController.sLModel = sLListViewControllerLandscape.sLModel;
    }else
    {
        sLMapViewController.sLModel = sLListViewControllerPortrait.sLModel;
    }
    sLMapViewController.mapViewOption = MapViewSelectedMarker;
    [sLMapViewController showMaker];
}


#pragma mark Modify UIColor

- (UIColor*) colorWithStringHex:(NSString*)stringHex
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:stringHex];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark
#pragma mark List View Controller Delegate
- (void)showViewDetailControllerFromList:(SimiStoreLocatorModel *)sLModel_
{
    isDetailViewController = YES;
    if (popOver != nil) {
        [popOver dismissPopoverAnimated:YES];
        popOver = nil;
    }
    detailViewController = [SimiStoreLocatorDetailViewController new];
    detailViewController.sLModel = sLModel_;
    detailViewController.currentLatitude = sLMapViewController.currentLatitube;
    detailViewController.currentLongitude = sLMapViewController.currentLongitube;
    
    detailViewController.preferredContentSize = CGSizeMake(SCREEN_WIDTH * 2/3, SCREEN_HEIGHT *2/3);
    if (popOverController == nil) {
        popOverController = [[UIPopoverController alloc]initWithContentViewController:detailViewController];
        popOverController.delegate = self;
        CGRect rect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        if (SIMI_SYSTEM_IOS > 7.0){
            [self.popOverController setBackgroundColor:[UIColor whiteColor]];
        }
        [self.popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
        ispopOverController = YES;
        isDetailViewController = YES;
    }
}


#pragma mark
#pragma mark Map View Controller Delegate
- (void)showViewDetailControllerFromMap:(SimiStoreLocatorModel *)sLModel_
{
    isDetailViewController = YES;
    detailViewController = [SimiStoreLocatorDetailViewController new];
    detailViewController.sLModel = sLModel_;
    detailViewController.currentLatitude = sLMapViewController.currentLatitube;
    detailViewController.currentLongitude = sLMapViewController.currentLongitube;
    detailViewController.preferredContentSize = CGSizeMake(SCREEN_WIDTH * 2/3, SCREEN_HEIGHT *2/3);
    
    if (popOverController == nil) {
        popOverController = [[UIPopoverController alloc]initWithContentViewController:detailViewController];
        popOverController.delegate = self;
        CGRect rect = CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, 1, 1);
        if (SIMI_SYSTEM_IOS > 7.0){
            [self.popOverController setBackgroundColor:[UIColor whiteColor]];
        }
        [self.popOverController presentPopoverFromRect:rect inView:self.view permittedArrowDirections:0 animated:YES];
        ispopOverController = YES;
        isDetailViewController = YES;
    }
}

#pragma mark 
#pragma mark popOverViewController Delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popOver) {
        popOver = nil;
    }
    
    if (popOverController) {
        popOverController = nil;
        isSearchViewController = NO;
        ispopOverController = NO;
        isDetailViewController = NO;
    }
}

#pragma mark
#pragma mark SearchView Controller Delegate
- (void)searchStoreLocatorWithCountryName:(NSString *)countryName countryCode:(NSString *)countryCode city:(NSString *)city state:(NSString *)state zipcode:(NSString *)zipcode tag:(NSString *)tag
{
    [popOverController dismissPopoverAnimated:YES];
    popOverController = nil;
    
    sLListViewControllerLandscape.dictSearch = @{@"countryCode":countryCode,@"countryName":countryName,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag};
    sLListViewControllerPortrait.dictSearch = @{@"countryCode":countryCode,@"countryName":countryName,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag};
    
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    sLMapViewController.dictSearch = @{@"countryCode":countryCode,@"countryName":countryName,@"city":city,@"state":state,@"zipcode":zipcode,@"tag":tag};
    
    sLListViewControllerLandscape.listViewOption = ListViewOptionSearched;
    sLListViewControllerPortrait.listViewOption = ListViewOptionSearched;
    sLMapViewController.searchOption = SearchOptionSearched;
}

- (void)cacheDataWithstoreLocatorModelCollection:(SimiStoreLocatorModelCollection *)collection simiAddressStoreLocatorModelCollection:(SimiAddressStoreLocatorModelCollection *)addressCollection simiConfigSearchStoreLocatorModel:(SimiConfigSearchStoreLocatorModel *)configSearch simiTagModelCollection:(SimiTagModelCollection *)tagModelCollection tagChoise:(NSString *)tagString
{
//    NSLog(@"So luong model cache:%d",collection.count);
    [sLListViewControllerLandscape.sLModelCollection removeAllObjects];
    for (int i = 0; i < collection.count; i++) {
        [sLListViewControllerLandscape.sLModelCollection addObject:[collection objectAtIndex:i]];
    }
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft
        || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [sLListViewControllerLandscape.tableView reloadData];
    }
    
    [sLListViewControllerPortrait.sLModelCollection removeAllObjects];
    for (int i = 0; i < collection.count; i++) {
        [sLListViewControllerPortrait.sLModelCollection addObject:[collection objectAtIndex:i]];
    }
    
    if (sLMapViewController == nil) {
        sLMapViewController = [[SimiStoreLocatorMapViewController alloc]init];
    }
    [sLMapViewController.sLModelCollectionAll removeAllObjects];
    for (int i = 0; i < collection.count; i++) {
        [sLMapViewController.sLModelCollectionAll addObject:[collection objectAtIndex:i]];
    }
    
    [sLMapViewController showMaker];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
