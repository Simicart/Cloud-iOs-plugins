//
//  ProductImagesView.m
//  RetailerPOS
//
//  Created by Nguyen Duc Chien on 1/15/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import "ProductImagesView.h"
#import "UIImageView+WebCache.h"
#import "MSFramework.h"

@interface ProductImagesView ()
@property (strong, nonatomic) UIScrollView *imageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@end

@implementation ProductImagesView
@synthesize images = _images;
@synthesize imageView, pageControl;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Init sub views
        imageView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 22)];
        imageView.showsVerticalScrollIndicator = NO;
        imageView.pagingEnabled = YES;
        imageView.delegate = self;
        [self addSubview:imageView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 22, frame.size.width, 22)];
        pageControl.hidesForSinglePage = YES;
        pageControl.currentPageIndicatorTintColor = [UIColor barBackgroundColor];
        [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:pageControl];
    }
    return self;
}

- (void)setImages:(NSArray *)images
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    if ([images count]) {
        if ([images count] > 1) {
            height -= 22;
            pageControl.currentPage = 1;
            pageControl.numberOfPages = [images count];
            pageControl.pageIndicatorTintColor = [UIColor borderColor];
        }
        _images = images;
        CGFloat x = 0;
        for (NSDictionary *image in self.images) {
            // Add Image View
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            [imgView setImageWithURL:[NSURL URLWithString:[image objectForKey:@"url"]] placeholderImage:[UIImage imageNamed:@"product_placeholder.png"]];
            [imageView addSubview:imgView];
            x += width;
        }
        imageView.contentSize = CGSizeMake(x, height);
    } else {
        // Place holder image
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = [UIImage imageNamed:@"product_placeholder.png"];
        [imageView addSubview:imgView];
        imageView.contentSize = CGSizeMake(width, height);
    }
    imageView.bounds = CGRectMake(0, 0, width, height);
}

- (void)changePage:(id)sender
{
    CGFloat x = pageControl.currentPage * self.frame.size.width;
    [imageView setContentOffset:CGPointMake(x, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.frame.size.width;
    NSUInteger page = (int)floor((imageView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

@end
