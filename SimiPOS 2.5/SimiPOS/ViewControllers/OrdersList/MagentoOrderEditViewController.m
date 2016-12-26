//
//  MagentoOrderEditViewController.m
//  SimiPOS
//
//  Created by Nguyen Dac Doan on 4/24/14.
//  Copyright (c) 2014 David Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MagentoOrderEditViewController.h"
#import "MSFramework.h"

@interface MagentoOrderEditViewController ()
@property (strong, nonatomic) UIView *itemView, *commentView;
@end

@implementation MagentoOrderEditViewController
@synthesize itemView = _itemView, commentView = _commentView;

#pragma mark - reload order view
- (void)reloadData
{
    // Reload Items and Comment View
    self.itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.withParent, 1)];
    self.commentView = [self.itemView clone];
    
    [self showOrderItemsDetail];
    [self showOrderComments];
    
    // Super reload
    [super reloadData];
}

#pragma mark - table view datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.order objectForKey:@"items"] == nil || self.itemView == nil) {
        return 0;
    }
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 2:
            return [[[self.order objectForKey:@"totals"] allKeys] count];
        case 3:
            if (![MSValidator isEmptyString:[self.order objectForKey:@"total_refunded"]]){
                return 3;
            }
//            if ([self.order objectForKey:@"total_refunded"]) {
//                return 3;
//            }
            return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:self.itemView];
        return cell;
    } else if ([indexPath section] == 4) {
        UITableViewCell *cell = [UITableViewCell new];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:self.commentView];
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        return self.itemView.frame.size.height + 1;
    } else if ([indexPath section] == 4) {
        return self.commentView.frame.size.height + 1;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

#pragma mark - view order item detail
- (void)showOrderItemsDetail
{
    CGFloat height = 1;
    UIView *page = self.itemView;
    
    page.backgroundColor =[UIColor whiteColor];
    
    // Order Info
    NSArray *orderInfo = [[self.order objectForKey:@"details"] objectForKey:@"order_info"];
    for (NSUInteger j = 0; j < [orderInfo count]; j++) {
        NSDictionary *left = [orderInfo objectAtIndex:j];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(-1, height-1, (self.withParent / 2), 30)];
        headerLabel.text = [NSString stringWithFormat:@"    %@",[left objectForKey:@"header"]];
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
        [headerLabel setBackgroundColor:[UIColor backgroundColor]];
        [headerLabel.layer setBorderColor:[UIColor lightBorderColor].CGColor];
        [headerLabel.layer setBorderWidth:1.0];
        [page addSubview:headerLabel];
        j++;
        NSDictionary *right = [orderInfo objectAtIndex:j];
        headerLabel = [headerLabel clone];
        headerLabel.frame = CGRectMake((self.withParent / 2), height-1, (self.withParent / 2), 30);
        headerLabel.text = [NSString stringWithFormat:@"    %@",[right objectForKey:@"header"]];
        [headerLabel.layer setBorderColor:[UIColor lightBorderColor].CGColor];
        [headerLabel.layer setBorderWidth:1.0];
        [page addSubview:headerLabel];
        height += 29;
        // Order Info Detail
        UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(-1, height, self.withParent, 9)];
        [detailView.layer setBorderColor:[UIColor lightBorderColor].CGColor];
        [detailView.layer setBorderWidth:1.0];
        [page addSubview:detailView];
        
        UITextView *detailText = [[UITextView alloc] initWithFrame:CGRectMake(9, 1, (self.withParent / 2), 9)];
        
        NSString * strLeftDetail =[[left objectForKey:@"text"] componentsJoinedByString:@"\n"]  ;
        detailText.text =[strLeftDetail stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
        detailText.font = [UIFont systemFontOfSize:15];
        [detailText setEditable:NO];
        [detailText setScrollEnabled:NO];
        [detailView addSubview:detailText];
        
        
        //CGFloat detailTextHeight = detailText.contentSize.height;
        //chiennd change
        CGFloat fixedWidth = detailText.frame.size.width;
        CGSize newSize = [detailText sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = detailText.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        detailText.frame = newFrame;
        
        CGFloat detailTextHeight =newSize.height;
       // detailText.frame = CGRectMake(9, 1, 288, detailTextHeight);
        
        detailText = [detailText clone];
        detailText.font = [UIFont systemFontOfSize:15];
        NSString * strRightDetail =[[right objectForKey:@"text"] componentsJoinedByString:@"\n"];
        detailText.text =[strRightDetail stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];;
        [detailView addSubview:detailText];
        if (detailTextHeight < detailText.contentSize.height) {
            detailTextHeight = detailText.contentSize.height;
        }
        detailText.frame = CGRectMake(((self.withParent / 2) + 10), 1, (self.withParent / 2), detailTextHeight);
        
        detailView.frame = CGRectMake(-1, height-1, self.withParent, detailTextHeight + 2);
        height += detailView.bounds.size.height - 1;
    }
    
    // Order Item
    [self drawItemHeader:page height:&height];
    NSArray *items = [[self.order objectForKey:@"details"] objectForKey:@"items"];
    for (NSArray *item in items) {
        [self drawOrderItem:item onPage:page height:&height];
    }
    
    self.itemView.frame = CGRectMake(0, 1, self.withParent, height);
}

- (void)drawItemHeader:(UIView *)page height:(CGFloat *)height
{
    NSArray *headerData = [[self.order objectForKey:@"details"] objectForKey:@"items_header"];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(-1, *height-1, self.withParent, 24)];
    [header setBackgroundColor:[UIColor backgroundColor]];
    [header.layer setBorderColor:[UIColor lightBorderColor].CGColor];
    [header.layer setBorderWidth:1.0];
    [page addSubview:header];
    *height += 27;
    
    // Each Label
    CGFloat start = 12;
    
    UILabel *headerLabel;
    if(WINDOW_WIDTH - 1024){
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(start, 2, (self.withParent - 372), 20)];
        headerLabel.backgroundColor = [UIColor backgroundColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
    }else{
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(start, 2, (self.withParent - 282), 20)];
        headerLabel.backgroundColor = [UIColor backgroundColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    
    // Products & SKU
    headerLabel.text = [headerData objectAtIndex:0];
    [header addSubview:headerLabel];
    if(WINDOW_WIDTH > 1024){
        start += (self.withParent - 372);
    }else{
        start += (self.withParent - 282);
    }
    
    // Price
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:3];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    if(WINDOW_WIDTH > 1024){
        headerLabel.frame = CGRectMake(start, 2, 138, 20);
        [header addSubview:headerLabel];
        start += 138;
    }else{
        headerLabel.frame = CGRectMake(start, 2, 128, 20);
        [header addSubview:headerLabel];
        start += 128;
    }
    
    // Qty
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:2];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    if(WINDOW_WIDTH > 1024){
        headerLabel.frame = CGRectMake(start, 2, 75, 20);
        [header addSubview:headerLabel];
        start += 75;
    }else{
        headerLabel.frame = CGRectMake(start, 2, 65, 20);
        [header addSubview:headerLabel];
        start += 65;
    }
    
    // Subtotal
    headerLabel = [headerLabel clone];
    headerLabel.text = [headerData objectAtIndex:5];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    if(WINDOW_WIDTH > 1024){
        headerLabel.frame = CGRectMake(start, 2, 87, 20);
    }else{
        headerLabel.frame = CGRectMake(start, 2, 77, 20);
    }
    [header addSubview:headerLabel];
}

- (void)drawOrderItem:(NSArray *)item onPage:(UIView *)page height:(CGFloat *)height
{
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(7, *height, self.withParent, 16)];
    
    itemView.backgroundColor =[UIColor clearColor];
    [page addSubview:itemView];
    
    CGFloat x = 0, y = 0;
    
    // Product Name
    NSDictionary *productName = [item objectAtIndex:0];
    CGFloat delta = -7;
    if ([productName objectForKey:@"name"]) {
        delta = 0;
        UITextView *name;
        if(WINDOW_WIDTH > 1024){
            name = [[UITextView alloc] initWithFrame:CGRectMake(x, y, (self.withParent - 382), 30)];
        }else{
            name = [[UITextView alloc] initWithFrame:CGRectMake(x, y, (self.withParent - 294), 30)];
        }
        
        [name setBackgroundColor:[UIColor clearColor]];
        name.text = [productName objectForKey:@"name"];
        name.font = [UIFont boldSystemFontOfSize:15];
        [name setEditable:NO];
        [name setScrollEnabled:NO];
        
        //Auto height
        CGFloat fixedWidth = name.frame.size.width;
        CGSize newSize = [name sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = name.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        name.frame = newFrame;
        
        [itemView addSubview:name];
        
        y += newSize.height;
        
        if (![MSValidator isEmptyString:[item objectAtIndex:1]]) {
            UITextView *sku = [name clone];
            [sku setBackgroundColor:[UIColor clearColor]];
            [sku setScrollEnabled:NO];
            sku.font = [UIFont systemFontOfSize:15];
            sku.text = [NSString stringWithFormat:@"SKU: %@", [item objectAtIndex:1]];
            [itemView addSubview:sku];
            
            //auto height
            CGFloat fixedWidth = sku.frame.size.width;
            CGSize newSize = [sku sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
            CGRect newFrame = sku.frame;
            newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
            newFrame.origin.y =y;
            sku.frame = newFrame;
            
            y += newSize.height;
        }
    }
    x += 12;
    if ([productName objectForKey:@"options"]) {
        NSArray *options = [productName objectForKey:@"options"];
        for (NSDictionary *option in options) {
            // Title
            if ([option objectForKey:@"title"]) {
                UITextView *title;
                if(WINDOW_WIDTH > 1024){
                    title = [[UITextView alloc] initWithFrame:CGRectMake(0, y-7, (self.withParent - 382), 9)];
                }else{
                    title = [[UITextView alloc] initWithFrame:CGRectMake(0, y-7, (self.withParent - 294), 9)];
                }
                
                [title setBackgroundColor:[UIColor clearColor]];
                title.text = [option objectForKey:@"title"];
                title.font = [UIFont italicSystemFontOfSize:15];
                [title setEditable:NO];
                [title setScrollEnabled:NO];
                [itemView addSubview:title];
                
                //title.frame = CGRectMake(0, y-7, 274, title.contentSize.height);
                //Auto height
               
                CGFloat fixedWidth = title.frame.size.width;
                CGSize newSize = [title sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                CGRect newFrame = title.frame;
                newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
                title.frame = newFrame;
                
                y += newSize.height - 7;
            }
            // Value
            if ([option objectForKey:@"value"]) {
                UITextView *value;
                if(WINDOW_WIDTH > 1024){
                    value = [[UITextView alloc] initWithFrame:CGRectMake(x, y-7, (self.withParent - 382), 9)];
                }else{
                    value = [[UITextView alloc] initWithFrame:CGRectMake(x, y-7, (self.withParent - 294), 9)];
                }
                
                [value setBackgroundColor:[UIColor clearColor]];
                value.text = [[option objectForKey:@"value"] componentsJoinedByString:@"\n"];
                value.font = [UIFont systemFontOfSize:15];
                [value setEditable:NO];
                [value setScrollEnabled:NO];
                [itemView addSubview:value];
                
                CGFloat fixedWidth = value.frame.size.width;
                CGSize newSize = [value sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
                CGRect newFrame = value.frame;
                newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
                value.frame = newFrame;
                
                //value.frame = CGRectMake(x, y-7, 262, value.contentSize.height);                                
                y += newSize.height - 7;
            }
        }
        y += 7;
    }
    if(WINDOW_WIDTH > 1024){
        x += (self.withParent - 382);
    }else{
        x += (self.withParent - 294);
    }
    
    // Price
    UITextView *content;
    if(WINDOW_WIDTH > 1024){
        content = [[UITextView alloc] initWithFrame:CGRectMake(x, delta, 138, 9)];
    }else{
        content = [[UITextView alloc] initWithFrame:CGRectMake(x, delta, 128, 9)];
    }
    
    [content setBackgroundColor:[UIColor clearColor]];
    [content setEditable:NO];
    [content setScrollEnabled:NO];
    content.textAlignment = NSTextAlignmentLeft;
    content.font = [UIFont boldSystemFontOfSize:15];
    content.text = [[item objectAtIndex:3] componentsJoinedByString:@"\n"];
    [itemView addSubview:content];
    
    //Auto height
    CGFloat fixedWidth = content.frame.size.width;
    CGSize newSize = [content sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = content.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    content.frame = newFrame;
    
    if(WINDOW_WIDTH > 1024){
        x += 138;
    }else{
        x += 128;
    }
   
    if (y < newSize.height) {
        y = newSize.height;
    }
    
    // Qty
    content = [content clone];
    [content setBackgroundColor:[UIColor clearColor]];
    content.textAlignment = NSTextAlignmentLeft;
    if(WINDOW_WIDTH > 1024){
        content.frame = CGRectMake(x, delta, 75, 9);
    }else{
        content.frame = CGRectMake(x, delta, 65, 9);
    }
    
    content.text = [item objectAtIndex:2];
    [itemView addSubview:content];
    
    //Auto height
     fixedWidth = content.frame.size.width;
     newSize = [content sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
     newFrame = content.frame;
     newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
     content.frame = newFrame;
    //content.frame = CGRectMake(x, delta, 75, content.contentSize.height);
    
    if(WINDOW_WIDTH > 1024){
        x += 75;
    }else{
        x += 65;
    }
    
    if (y < newSize.height) {
        y = newSize.height;
    }
    
    // Subtotal
    content = [content clone];
    [content setBackgroundColor:[UIColor clearColor]];
    content.textAlignment = NSTextAlignmentLeft;
    if(WINDOW_WIDTH > 1024){
        content.frame = CGRectMake(x, delta, 87, 9);
    }else{
        content.frame = CGRectMake(x, delta, 77, 9);
    }
    
    content.text = [[item objectAtIndex:5] componentsJoinedByString:@"\n"];
    [itemView addSubview:content];
   
    //content.frame = CGRectMake(x, delta, 99, content.contentSize.height);
    fixedWidth = content.frame.size.width;
    newSize = [content sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    newFrame = content.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    content.frame = newFrame;
    
    if(WINDOW_WIDTH > 1024){
        x += 87;
    }else{
        x += 77;
    }
    if (y < newSize.height) {
        y = newSize.height;
    }
    
    itemView.frame = CGRectMake(7, *height, self.withParent, y);
    *height += y;
}

#pragma mark - view order comment
- (void)showOrderComments
{
    CGFloat height = 10;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(-1, height, self.withParent, 24)];
    [header setBackgroundColor:[UIColor backgroundColor]];
    [header.layer setBorderColor:[UIColor lightBorderColor].CGColor];
    [header.layer setBorderWidth:1.0];
    [self.commentView addSubview:header];
    height += 30;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 2, 500, 20)];
    headerLabel.backgroundColor = [UIColor backgroundColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.text = NSLocalizedString(@"Comments History", nil);
    [header addSubview:headerLabel];
    
    NSArray *keys = [[[self.order objectForKey:@"history"] allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSInteger i = [keys count] - 1; i >= 0; i--) {
        NSDictionary *history = [[self.order objectForKey:@"history"] objectForKey:[keys objectAtIndex:i]];
        // Comment History
        headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, height, 574, 20)];
        headerLabel.font = [UIFont systemFontOfSize:15];
        headerLabel.text = [NSString stringWithFormat:@"%@  |  %@", [MSDateTime formatDateTime:[history objectForKey:@"created_at"]], [history objectForKey:@"status_label"]];
        [self.commentView addSubview:headerLabel];
        height += 24;
        if (![MSValidator isEmptyString:[history objectForKey:@"comment"]]) {
            UITextView *comment = [[UITextView alloc] initWithFrame:CGRectMake(16, height - 5, 566, 20)];
            comment.font = [UIFont italicSystemFontOfSize:15];
            comment.text = [history objectForKey:@"comment"];
            [comment setEditable:NO];
            [comment setScrollEnabled:NO];
            [self.commentView addSubview:comment];

            //comment.frame = CGRectMake(16, height - 5, 566, comment.contentSize.height);
           
            CGFloat fixedWidth = comment.frame.size.width;
            CGSize newSize = [comment sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
            CGRect newFrame = comment.frame;
            newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
            comment.frame = newFrame;
            
            
            height += newSize.height - 5;
        }
        height += 5;
    }
    
    self.commentView.frame = CGRectMake(0, 1, self.withParent, height);
}

@end
