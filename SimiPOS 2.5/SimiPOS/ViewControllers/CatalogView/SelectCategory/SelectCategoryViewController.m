//
//  SelectCategoryViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 10/23/13.
//  Copyright (c) 2013 David Nguyen. All rights reserved.
//

#import "SelectCategoryViewController.h"
#import "Utilities.h"
#import "RPCategory.h"
#import "CategoryModel.h"

@interface SelectCategoryViewController ()
@property (strong, nonatomic) SVInfiniteScrollingView *loadingAnimation;
@property (strong, nonatomic) id successObserver, failObserver;
@end

@implementation SelectCategoryViewController{
    CategoryModel *categoryModel;
    NSMutableDictionary *dataCategory;
    NSMutableArray *arrCategory;
}
@synthesize loadingAnimation;
@synthesize successObserver, failObserver;

@synthesize productController;
@synthesize popoverController;
@synthesize categories;

- (id)init
{
    if (self = [super init]) {
        self.categories = [[CategoryCollection alloc] init];
        self.loadingAnimation = [[SVInfiniteScrollingView alloc] initWithFrame:CGRectZero];
        [self.tableView addSubview:self.loadingAnimation];
        arrCategory = [NSMutableArray new];
        //Ravi
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.backgroundColor = [UIColor whiteColor];
        self.refreshControl.tintColor = [UIColor blackColor];
        [self.refreshControl addTarget:self
                                action:@selector(getCategory)
                      forControlEvents:UIControlEventValueChanged];
        //End
    }
    return self;
}

- (CGSize)reloadContentSize
{
    if (arrCategory.count == 0) {
        self.view.frame = CGRectMake(0, 0, 320, 44);
        self.loadingAnimation.frame = self.view.frame;
        [self.loadingAnimation startAnimating];
        [self getCategory];
    }
    CGFloat height = 44;
    height += 44 * arrCategory.count;
    if (height > 528) {
        height = 528;
    }
    
    self.preferredContentSize = CGSizeMake(320, height);
     [self.tableView reloadData];
    return self.preferredContentSize;
}

- (void) didGetCategory:(NSNotification *) noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidGetCategory" object:categoryModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    self.loadingAnimation.frame = CGRectZero;
    [self.loadingAnimation stopAnimating];
    
    if (self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor blackColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        [self.refreshControl endRefreshing];
    }
    
    if([respone.status isEqualToString:@"SUCCESS"]){
        if([categoryModel isKindOfClass:[NSDictionary class]]){
            [self parseData:categoryModel];
        }
    }
}

- (void) parseData:(NSDictionary*) respone {
    NSMutableDictionary *data = [respone valueForKey:@"data"];
    
    dataCategory = [NSMutableDictionary new];
    
    dataCategory = [self newData:data categoryID:nil];

    [self reloadContentSize];
}

-(NSMutableDictionary*)newData:(NSMutableDictionary*)child categoryID:(NSString*) category_id{
    NSMutableDictionary *categoryChild = [NSMutableDictionary new];
    [categoryChild setObject:[child valueForKey:@"name"] forKey:@"name"];
    [categoryChild setObject:[child valueForKey:@"level"] forKey:@"level"];
    if(category_id){
        [categoryChild setObject:category_id forKey:@"id"];
    }else{
        [categoryChild setObject:@"" forKey:@"id"];
    }
    [categoryChild setObject:@"0" forKey:@"has_child"];
    [arrCategory addObject:categoryChild];
    
    NSMutableDictionary * returnData = [NSMutableDictionary new];
    [returnData setObject:[NSMutableArray new] forKey:@"arr_child"];
    for (NSString *key in [child allKeys]) {
        if ([key isEqual:@"root"]) {}
        
        else if ([key isEqual:@"name"]) {
            [returnData setValue:[child valueForKey:key] forKey:key];
        }
        else if ([key isEqual:@"level"]) {
            [returnData setValue:[child valueForKey:key] forKey:key];
        }
        else {
            [categoryChild setObject:@"1" forKey:@"has_child"];
            [[returnData objectForKey:@"arr_child"] addObject:[self newData:[child valueForKey:key] categoryID:key]];
        }
    }
    return returnData;
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arrCategory.count) {
        if (section){
            return (arrCategory.count - 1);
        }
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CategoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if ([indexPath section] == 0) {
        cell.textLabel.text = NSLocalizedString(@"All Products", nil);
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
        cell.accessoryView = nil;
        return cell;
    }
    
    NSMutableString *title = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < ([[[arrCategory objectAtIndex:(indexPath.row + 1)] valueForKey:@"level"] integerValue] - 2); i++) {
        [title appendString:@"    "];
    }
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:(19 - [[[arrCategory objectAtIndex:(indexPath.row + 1)] valueForKey:@"level"] integerValue])]];
    [title appendString:[[arrCategory objectAtIndex:(indexPath.row + 1)] valueForKey:@"name"]];
    cell.textLabel.text = title;
    
    if([[[arrCategory objectAtIndex:(indexPath.row + 1)] valueForKey:@"has_child"] boolValue]){
        UIImageView *disclosureView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure_indicator_down.png"]];
        cell.accessoryView = disclosureView;
    }else{
        cell.accessoryView = nil;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section]) {
        RPCategory *category = [RPCategory new];
        [category setData:[arrCategory objectAtIndex:(indexPath.row  + 1)]];
        [self.productController didSelectCategory:category];
    } else {
        [self.productController didSelectCategory:nil];
    }
    [self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark - Popover controller delegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // Reset view button here
    
    // Remove Observers
    if (successObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:successObserver];
    }
    if (failObserver != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:failObserver];
    }
    self.loadingAnimation.frame = CGRectZero;
    [self.loadingAnimation stopAnimating];
}

- (void)getCategory{
    categoryModel = [CategoryModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetCategory:) name:@"DidGetCategory" object:categoryModel];
    [categoryModel getCategory];
}

@end
