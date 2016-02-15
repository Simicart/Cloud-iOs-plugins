//
//  SimiStoreLocatorSearchViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/9/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <SimiCartBundle/SimiCartBundle.h>
#import <SimiCartBundle/SimiViewController.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import "SimiStoreLocatorModelCollection.h"
#import "SimiAddressStoreLocatorModelCollection.h"
#import "SimiAddressStoreLocatorModel.h"
#import "SimiConfigSearchStoreLocatorModel.h"
#import "SimiTagModel.h"
#import "SimiTagModelCollection.h"
#import "SimiStoreLocatorCellCountry.h"
#import "SimiTagCollectionCell.h"

@protocol SimiStoreLocatorSearchViewControllerDelegate  <NSObject>
@optional
- (void)searchStoreLocatorWithCountryName:(NSString*)countryName countryCode:(NSString*)countryCode city:(NSString*)city state:(NSString*)state zipcode:(NSString*)zipcode tag:(NSString*)tag;
- (void)cacheDataWithstoreLocatorModelCollection:(SimiStoreLocatorModelCollection*) collection simiAddressStoreLocatorModelCollection:(SimiAddressStoreLocatorModelCollection*)addressCollection simiConfigSearchStoreLocatorModel:(SimiConfigSearchStoreLocatorModel*)configSearch simiTagModelCollection:(SimiTagModelCollection*)tagModelCollection tagChoise:(NSString*)tagString;
@end


@interface SimiStoreLocatorSearchViewController : SimiViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) SimiAddressStoreLocatorModelCollection *simiAddressStoreLocatorModelCollection;
@property (nonatomic, strong) SimiConfigSearchStoreLocatorModel *simiConfigSearchStoreLocatorModel;
@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollection;
@property (nonatomic, strong) SimiTagModelCollection * tagModelCollection;
@property (nonatomic, strong) NSString *tagChoise;

@property (nonatomic) float currentLatitube;
@property (nonatomic) float currentLongitube;
@property (nonatomic, strong) NSString *stringCountrySearchCode;
@property (nonatomic, strong) NSString *stringCountrySearchName;
@property (nonatomic, strong) NSString *stringCitySearch;
@property (nonatomic, strong) NSString *stringStateSearch;
@property (nonatomic, strong) NSString *stringZipCodeSearch;
@property (nonatomic, strong) NSString *stringTagSearch;
@property (nonatomic, weak) id<SimiStoreLocatorSearchViewControllerDelegate> delegate;

/*
@property (nonatomic, strong) IBOutlet UIScrollView *scrView;

@property (nonatomic, strong) IBOutlet UILabel *lblSearchByArea;
@property (nonatomic, strong) IBOutlet UIView *viewSearchByArea;
@property (nonatomic, strong) IBOutlet UILabel *lblClearAll;

@property (nonatomic, strong) IBOutlet UIView *viewSearchByCountry;
@property (nonatomic, strong) UITableView *tblViewCountry;
@property (nonatomic, strong) IBOutlet UILabel *lblContentCountry;
@property (nonatomic, strong) IBOutlet UILabel *lblCountry;

@property (nonatomic, strong) IBOutlet UIView *viewSearchByCity;
@property (nonatomic, strong) IBOutlet UITextField *txtCitySearch;
@property (nonatomic, strong) IBOutlet UILabel *lblCity;

@property (nonatomic, strong) IBOutlet UIView *viewSearchByState;
@property (nonatomic, strong) IBOutlet UITextField *txtStateSearch;
@property (nonatomic, strong) IBOutlet UILabel *lblState;

@property (nonatomic, strong) IBOutlet UIView *viewSearchByZipcode;
@property (nonatomic, strong) IBOutlet UITextField *txtZipCode;
@property (nonatomic, strong) IBOutlet UILabel *lblZipcode;

@property (nonatomic, strong) IBOutlet UIView *viewSearch;
@property (nonatomic, strong) IBOutlet UIButton *btnSearch;

@property (nonatomic, strong) IBOutlet UIView *viewSearchByTag;
@property (nonatomic, strong) IBOutlet UILabel *lblSearchByTag;
@property (nonatomic, strong) IBOutlet UICollectionView * collectionViewTagContent;
*/
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

/*
- (IBAction)btnDropDownList_Click:(id)sender;
- (IBAction)btnSearch_Click:(id)sender;
- (IBAction)btnTouchOutLayer_Click:(id)sender;
- (IBAction)btnClear:(id)sender;
*/

@property (nonatomic, strong)  UIScrollView *scrView;

@property (nonatomic, strong)  UILabel *lblSearchByArea;
@property (nonatomic, strong)  UIButton *btnClearAll;

@property (nonatomic, strong)  UIControl *viewSearchByCountry;
@property (nonatomic, strong)  UITableView *tblViewCountry;
@property (nonatomic, strong)  UILabel *lblContentCountry;
@property (nonatomic, strong)  UILabel *lblCountry;
@property (nonatomic, strong)  UIImageView *imgCountry;
@property (nonatomic, strong)  UIButton *btnCountry;

@property (nonatomic, strong)  UIControl *viewSearchByCity;
@property (nonatomic, strong)  UIImageView *imgCity;
@property (nonatomic, strong)  UITextField *txtCitySearch;
@property (nonatomic, strong)  UILabel *lblCity;

@property (nonatomic, strong)  UIControl *viewSearchByState;
@property (nonatomic, strong)  UITextField *txtStateSearch;
@property (nonatomic, strong)  UILabel *lblState;
@property (nonatomic, strong)  UIImageView *imgState;

@property (nonatomic, strong)  UIControl *viewSearchByZipcode;
@property (nonatomic, strong)  UITextField *txtZipCode;
@property (nonatomic, strong)  UILabel *lblZipcode;
@property (nonatomic, strong)  UIImageView *imgZipCode;

@property (nonatomic, strong)  UIView *viewSearch;
@property (nonatomic, strong)  UIButton *btnSearch;

@property (nonatomic, strong)  UIView *viewSearchByTag;
@property (nonatomic, strong)  UILabel *lblSearchByTag;
@property (nonatomic, strong)  UICollectionView * collectionViewTagContent;

- (void)btnDropDownList_Click:(id)sender;
- (void)btnSearch_Click:(id)sender;
- (void)btnTouchOutLayer_Click:(id)sender;
- (void)btnClear:(id)sender;
@end
