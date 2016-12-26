//
//  DefaultPrintViewVCViewController.m
//  SimiPOS
//
//  Created by Trueplus02 on 3/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "DefaultPrintViewVCViewController.h"
#import "APIManager.h"
#import "Quote.h"
#import <sys/utsname.h>
#import "UIPrintPageRenderer+PDF.h"
#import "PrintOrderModel.h"
#define kPaperSizeA4 CGSizeMake(595.2,841.8)

@interface DefaultPrintViewVCViewController ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;

@end

@implementation DefaultPrintViewVCViewController{
    int k; //He so nhan
    PrintOrderModel *printOrderModel;
}
@synthesize animation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Navigation Title & Buttons
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelPrint)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Print Order # %@", nil), [self.order getIncrementId]];
    
    UIBarButtonItem *printBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(printOrderAction)];
    self.navigationItem.rightBarButtonItem = printBtn;
 
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.frame = CGRectMake(0, 0, 44, 44);
        float paddingAnimation;
        if (WINDOW_WIDTH > 1024) {
            paddingAnimation = 280;
        }else{
            paddingAnimation = 130;
        }
        animation.center=CGPointMake(self.webView.center.x+ paddingAnimation, self.webView.center.y);

        animation.center=CGPointMake(self.webView.center.x, self.webView.center.y);
        animation.color = [UIColor grayColor];
        [self.webView addSubview:animation];
    }
    [animation startAnimating];
    
    // Johan
    printOrderModel = [PrintOrderModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetPrintOrder:) name:@"DidGetPrintOrder" object:printOrderModel];
    [printOrderModel getPrintOrder:[self.order getIncrementId]];
    // End
}
// end

// Johan
- (void) didGetPrintOrder:(NSNotification *) noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidGetPrintOrder" object:printOrderModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        if ([[printOrderModel objectForKey:@"data"] isKindOfClass:[NSDictionary class]]){
            if([[[printOrderModel valueForKey:@"data"] valueForKey:@"type"] boolValue]){
                //Ravi fix bug crash app khi chon cancel tai popup print
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView loadHTMLString:[[printOrderModel valueForKey:@"data"] valueForKey:@"html"] baseURL:nil];
                });
//                [self.webView loadHTMLString:[[printOrderModel valueForKey:@"data"] valueForKey:@"html"] baseURL:nil];
            }else {
                NSString *urlString = [[printOrderModel objectForKey:@"data"] valueForKey:@"html"];
                //Ravi fix bug crash app khi chon cancel tai popup print
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
                });
//                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
            }
        }else{
            NSString *urlString = [printOrderModel objectForKey:@"data"];
            //Ravi fix bug crash app khi chon cancel tai popup print
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
            });
//            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
        }
    }
}
// End

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [animation stopAnimating];
}

- (void)cancelPrint
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - print order
//- (void)printOrderAction
//{
//    CGRect frame = self.webView.frame;
//    CGRect frameOld = frame;
//    frame.size.width = 302;
//    self.webView.frame = frame;
//    //to attach the image and text with sharing
//    //Gin fix bug print
//    NSString *str=[NSString stringWithFormat:@"Order #%@",[self.order getIncrementId]];
//    NSMutableArray *data =  [NSMutableArray new];
//    [data addObject:str];
//    for (int y = 0; y < self.webView.scrollView.contentSize.height ; y = y  + self.webView.frame.size.height) {
//        frame.origin.y = y;
//        self.webView.scrollView.contentOffset = CGPointMake(0, y);
//        if(self.webView.scrollView.contentSize.height - y < 20){
//            break;
//        }
//        UIImage *img = [Utilities imageWithView:self.webView];
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 561, 841.8)];
//        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0 , view.frame.size.width, view.frame.size.height)];
//        [imgView setImage:img];
//        imgView.contentMode = UIViewContentModeScaleToFill;
//        [view addSubview:imgView];
//        view.backgroundColor = [UIColor whiteColor];
//        UIImage *img1 = [Utilities imageWithView:view];
//        [data addObject:img1];
//    }
//    self.webView.frame = frameOld;
//    //Save PDF to directory for usage
//    //     Change Rect to position Popover
//    UIViewPrintFormatter *viewPrint = [self.webView viewPrintFormatter];
////    NSArray *postItems=@[str,image,image];
//    NSMutableArray *postItems = [NSMutableArray new];
//    [postItems addObject:str];
////    [postItems addObjectsFromArray:pdfData];
//    [postItems addObject:viewPrint];
//   
//    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
////     Change Rect to position Popover
//    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
//    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 1, 1)inView:self.view permittedArrowDirections:0 animated:YES];
//}


- (void)printOrderAction
{
    CGRect frame = self.webView.frame;
    CGRect frameOld = frame;
    frame.size.width = 302;
    self.webView.frame = frame;
    //to attach the image and text with sharing
    //Gin fix bug print
    NSString *str=[NSString stringWithFormat:@"Order #%@",[self.order getIncrementId]];
    NSMutableArray *data =  [NSMutableArray new];
    [data addObject:str];
    NSMutableArray *postItems = [NSMutableArray new];
    [postItems addObject:str];
    UIImage *imgFirst = [Utilities imageWithView:self.webView];
    
    if (self.webView.scrollView.contentSize.height >= 750) {
        UIViewPrintFormatter *viewPrint = [self.webView viewPrintFormatter];
        [postItems addObject:viewPrint];
    }else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imgFirst.size.width, imgFirst.size.height)];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0 ,0 , imgFirst.size.width, imgFirst.size.height)];
        [imgView setImage:imgFirst];
//        imgView.contentMode = UIViewContentModeScaleAspectFill;
//        imgView.contentMode = UIViewContentModeScaleToFill;
        [view addSubview:imgView];
        UIImage *img1 = [Utilities imageWithView:view];
        [postItems addObject:img1];
    }
    //    for (int y = 0; y < self.webView.scrollView.contentSize.height ; y = y  + self.webView.frame.size.height) {
    //        frame.origin.y = y;
    //        self.webView.scrollView.contentOffset = CGPointMake(0, y);
    //        if(self.webView.scrollView.contentSize.height - y < 20){
    //            break;
    //        }
    //        UIImage *img = [Utilities imageWithView:self.webView];
    //        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 561, 841.8)];
    //        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0 , view.frame.size.width, view.frame.size.height)];
    //        [imgView setImage:img];
    //        imgView.contentMode = UIViewContentModeScaleToFill;
    //        [view addSubview:imgView];
    //        view.backgroundColor = [UIColor whiteColor];
    //        UIImage *img1 = [Utilities imageWithView:view];
    //        [data addObject:img1];
    //    }
    self.webView.frame = frameOld;
    //Save PDF to directory for usage
    //     Change Rect to position Popover
    
    //    NSArray *postItems=@[str,image,image];
    
    
    //    [postItems addObjectsFromArray:pdfData];
    
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:postItems applicationActivities:nil];
    //     Change Rect to position Popover
    UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
    [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 1, 1)inView:self.view permittedArrowDirections:0 animated:YES];
    
}


- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    //CGRect CropRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height+15);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef ];
    CGImageRelease(imageRef);
    
    return cropped;
}
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (NSString*)deviceName {
    
    static NSDictionary* deviceNamesByCode = nil;
    static NSString* deviceName = nil;
    
    if (deviceName) {
        return deviceName;
    }
    
    deviceNamesByCode = @{
                          @"i386"      :@"Simulator",
                          @"iPod1,1"   :@"iPod Touch",      // (Original)
                          @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                          @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                          @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                          @"iPhone1,1" :@"iPhone",          // (Original)
                          @"iPhone1,2" :@"iPhone",          // (3G)
                          @"iPhone2,1" :@"iPhone",          // (3GS)
                          @"iPad1,1"   :@"iPad",            // (Original)
                          @"iPad2,1"   :@"iPad 2",          //
                          @"iPad3,1"   :@"iPad",            // (3rd Generation)
                          @"iPhone3,1" :@"iPhone 4",        //
                          @"iPhone4,1" :@"iPhone 4S",       //
                          @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                          @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                          @"iPad3,4"   :@"iPad",            // (4th Generation)
                          @"iPad2,5"   :@"iPad Mini",       // (Original)
                          @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                          @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                          @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                          @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                          @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                          @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                          @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                          @"iPad4,5"   :@"iPad Mini"        // (2nd Generation iPad Mini - Cellular)
                          };
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    deviceName = [deviceNamesByCode objectForKey:code];
    return deviceName;
}

@end
