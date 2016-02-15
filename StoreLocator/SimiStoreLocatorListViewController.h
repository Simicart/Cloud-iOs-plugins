//
//  SimiStoreLocatorListViewController.h
//  SimiCartPluginFW
//
//  Created by NghiepLy on 7/1/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <SimiCartBundle/UIScrollView+SVInfiniteScrolling.h>
#import "SimiCLController.h"
#import "SimiStoreLocatorModelCollection.h"
#import "SimiStoreLocatorModel.h"
#import "SCStoreListTableViewCell.h"
#import "UILabel+DynamicSizeMe.h"

typedef NS_ENUM(NSInteger, ListViewOption){
    ListViewOptionNoneSearch,
    ListViewOptionSearched
};

@protocol SimiStoreLocatorListViewControllerDelegate<NSObject>
@optional
- (void)didChoiseStoreFromListToMap;
- (void)showViewDetailControllerFromList:(SimiStoreLocatorModel*) sLModel_;
@end


@interface SimiStoreLocatorListViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate, SCStoreListTableViewCellDelegate,MFMailComposeViewControllerDelegate>
{
    SimiCLController *cLController;
}
@property (nonatomic, strong) id<SimiStoreLocatorListViewControllerDelegate> delegate;
@property (nonatomic, strong) SimiStoreLocatorModelCollection *sLModelCollection;
@property (nonatomic, strong) SimiStoreLocatorModel *sLModel;
@property (nonatomic) ListViewOption listViewOption;
@property (nonatomic) float currentLatitube;
@property (nonatomic) float currentLongitube;
@property (nonatomic, strong) NSDictionary *dictSearch;

- (void)getStoreLocatorList;
- (void)didGetStoreLocatorList;

@end
