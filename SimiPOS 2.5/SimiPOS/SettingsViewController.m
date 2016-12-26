//  Created by Nguyen Duc Chien on 8/3/16.
//  Copyright (c) 2016 Marcus Nguyen. All rights reserved.


#import "SettingsViewController.h"
#import "SettingSectionsViewController.h"
#import "SettingFormViewController.h"
#import "MSFramework.h"

@interface SettingsViewController ()
@property (strong, nonatomic) SettingSectionsViewController *sections;
@property (strong, nonatomic) MSNavigationController *settingForms;
@end

@implementation SettingsViewController
@synthesize sections, settingForms;

static SettingsViewController *_sharedInstance = nil;

+(SettingsViewController*)sharedInstance
{
    if (_sharedInstance != nil) {
        return _sharedInstance;
    }
    
    @synchronized(self) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    return _sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _sharedInstance = self;
    
	// Do any additional setup after loading the view.
    self.view.frame = CGRectMake(0, 0, 1024, WINDOW_HEIGHT);
   // [self.view setBackgroundColor:[UIColor lightGrayColor]];

    
    // Add settings view
    sections = [SettingSectionsViewController new];
    MSNavigationController *sectionsNav = [[MSNavigationController alloc] initWithRootViewController:sections];
    sectionsNav.view.frame = CGRectMake(0, 0, 427, WINDOW_HEIGHT);
    
    [self addChildViewController:sectionsNav];
    [self.view addSubview:sectionsNav.view];
    [sectionsNav didMoveToParentViewController:self];
    
    SettingFormViewController *form = [[SettingFormViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingForms = [[MSNavigationController alloc] initWithRootViewController:form];
    settingForms.view.frame = CGRectMake(WINDOW_WIDTH -600, 0, 600, WINDOW_HEIGHT);
    
    [self addChildViewController:settingForms];
    [self.view addSubview:settingForms.view];
    [settingForms didMoveToParentViewController:self];
    
    form.sections = sections;
    sections.settingForms = settingForms;
}


@end
