//
//  SCEmailContactViewController.m
//  SimiCartPluginFW
//
//  Created by Nghieply91 on 10/15/14.
//  Copyright (c) 2014 Tan Hoang. All rights reserved.
//

#import "SCEmailContactViewController.h"
#import "InstantContactCollectionViewCell.h"

@interface SCEmailContactViewController ()

@end

@implementation SCEmailContactViewController
{
    NSString *stringPhoneNumber;
    NSMutableArray *arrayPhoneNumber;
    NSMutableArray *arrayPhoneNumberAfterCheck;
    NSMutableArray *arrayMessageNumber;
    NSMutableArray *arrayMessageNumberAfterCheck;
    NSMutableArray *arrayEmail;
    NSMutableArray *arrayEmailCheck;
    NSString *stringWebsite;
    NSString *stringStyle;
    NSString *stringColor;
    UIActivityIndicatorView *indicatorView;
    BOOL isFirstLoad;
    int numberItemPhone;
    int numberItemPad;
    float itemWidth,itemHeight;
    NSMutableArray *arrayIntifier;
    NSMutableArray *arrayLabel;
}

- (void)viewDidLoadBefore {
    itemWidth = [SimiGlobalVar scaleValue:130];
    itemHeight =[SimiGlobalVar scaleValue:130];
    arrayIntifier = [NSMutableArray new];
    arrayLabel = [NSMutableArray new];
    _contactModel = [NSMutableDictionary new];
    _contactModel = [_dict objectForKey:@"config"];
    arrayPhoneNumber = [NSMutableArray new];
    arrayPhoneNumberAfterCheck = [NSMutableArray new];
    arrayMessageNumber = [NSMutableArray new];
    arrayMessageNumberAfterCheck = [NSMutableArray new];
    arrayEmail = [NSMutableArray new];
    arrayEmailCheck = [NSMutableArray new];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewDidLoadBefore];
    }else{
         itemWidth = [SimiGlobalVar scaleValue:330];
    }
    self.navigationItem.title = SCLocalizedString(@"Contact Us");
    [self configInstantContact];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppearBefore:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [super viewWillAppearBefore:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

#pragma mark Action
- (void)btnCallClick
{
    if (arrayPhoneNumberAfterCheck.count == 1) {
        stringPhoneNumber = [arrayPhoneNumberAfterCheck objectAtIndex:0];
        [self call];
    }else
    {
        _isCall = YES;
        SCListPhoneViewController *listPhoneViewController = [[SCListPhoneViewController alloc]init];
        listPhoneViewController.arrayPhone = [arrayPhoneNumberAfterCheck mutableCopy];
        listPhoneViewController.delegate = self;
        [self.navigationController pushViewController:listPhoneViewController animated:YES];
    }
}

- (void)call
{
    NSString *phNo = [NSString  stringWithFormat:@"telprompt:%@",stringPhoneNumber];
    NSURL *phoneUrl = [[NSURL alloc]initWithString:[phNo stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView* calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:SCLocalizedString(@"Call facility is not available!!!") delegate:nil cancelButtonTitle:SCLocalizedString(@"Ok") otherButtonTitles:nil, nil];
        [calert show];
    }
}

- (void)btnEmailClick
{
    NSString *emailContent = SCLocalizedString(@"");
    [self sendEmailToStoreWithEmail:arrayEmailCheck andEmailContent:emailContent];
}

- (void)btnWebsiteClick
{
    if (!([stringWebsite containsString:@"http://"]||[stringWebsite containsString:@"https://"])) {
        stringWebsite = [NSString stringWithFormat:@"%@%@",@"http://",stringWebsite];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringWebsite]];
}

- (void)btnMessageClick
{
    if (arrayMessageNumberAfterCheck.count == 1) {
        stringPhoneNumber = [arrayMessageNumberAfterCheck objectAtIndex:0];
        [self sendMessage];
    }else
    {
        _isCall = NO;
        SCListPhoneViewController *listPhoneViewController = [[SCListPhoneViewController alloc]init];
        listPhoneViewController.arrayPhone = [arrayMessageNumberAfterCheck mutableCopy];
        listPhoneViewController.delegate = self;
        [self.navigationController pushViewController:listPhoneViewController animated:YES];
    }
}

- (void)sendMessage
{
    NSString *messageContent = @"";
    [self sendMessageToStoreWithPhone:stringPhoneNumber andMessageContent:messageContent];
}

#pragma mark Email Delegate
- (void)sendEmailToStoreWithEmail:(NSMutableArray *)email andEmailContent:(NSString *)emailContent
{
    if([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:arrayEmailCheck];
        
        [controller setSubject:[NSString stringWithFormat:@""]];
        [controller setMessageBody:emailContent isHTML:NO];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self presentViewController:controller animated:YES completion:NULL];
        }
        else {
            [self presentViewController:controller animated:YES completion:NULL];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SCLocalizedString(@"You haven’t setup email account") message:SCLocalizedString(@"You must go to Settings/ Mail, Contact, Calendars and choose Add Account.")
                                                       delegate:self cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    if(result==MFMailComposeResultCancelled)
    {
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    if(result==MFMailComposeResultSent)
    {  UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Your Email was sent succesfully.") message:nil delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [sent show];
        [controller dismissViewControllerAnimated:YES completion:NULL];
    }
    if(result==MFMailComposeResultFailed)
    {UIAlertView *sent=[[UIAlertView alloc]initWithTitle:SCLocalizedString(@"Failed") message:SCLocalizedString(@"Your mail was not sent") delegate:nil cancelButtonTitle:SCLocalizedString(@"OK") otherButtonTitles:nil];
        [sent show];
        
        [controller dismissViewControllerAnimated:YES completion:NULL];
        
    }
}

#pragma mark Message Delegate
- (void)sendMessageToStoreWithPhone:(NSString *)phone andMessageContent:(NSString *)messageContent
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = @[phone];
    NSString *message = messageContent;
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
//            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [warningAlert show];
        }
            break;
            
        case MessageComposeResultSent:
        {
//            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Send message success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [warningAlert show];
        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Did Get Email Contact
- (void)configInstantContact
{
    numberItemPad = 0;
    numberItemPhone = 0;
    if ([_contactModel valueForKey:@"email"]) {
        if (![[_contactModel valueForKey:@"email"] isEqualToString:@""]) {
            numberItemPad = numberItemPad +1;
            numberItemPhone = numberItemPhone +1;
            [arrayEmailCheck addObject:[_contactModel valueForKey:@"email"]];
            [arrayIntifier addObject:@"contactus_email"];
            [arrayLabel addObject:@"Email"];
        }
        
    }
    if ([_contactModel valueForKey:@"phone"]) {
        if (![[_contactModel valueForKey:@"phone"] isEqualToString:@""] &&(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)) {
            numberItemPhone = numberItemPhone +1;
            [arrayPhoneNumberAfterCheck addObject:[_contactModel valueForKey:@"phone"]];
            [arrayIntifier addObject:@"contactus_call"];
            [arrayLabel addObject:@"Call"];
        }
        
    }
    if ([_contactModel valueForKey:@"message"]) {
        if (![[_contactModel valueForKey:@"message"] isEqualToString:@""]) {
            numberItemPad = numberItemPad +1;
            numberItemPhone = numberItemPhone +1;
            [arrayMessageNumberAfterCheck addObject:[_contactModel valueForKey:@"message"]];
            [arrayIntifier addObject:@"contactus_message"];
            [arrayLabel addObject:@"Message"];
        }

    }
    if ([_contactModel valueForKey:@"website"]) {
        numberItemPad = numberItemPad +1;
        numberItemPhone = numberItemPhone +1;
        stringWebsite = [_contactModel valueForKey:@"website"];
        [arrayIntifier addObject:@"contactus_web"];
        [arrayLabel addObject:@"Website"];
    }
    if ([_contactModel valueForKey:@"style"]) {
        stringStyle = [_contactModel valueForKey:@"style"];
    }else{
        stringStyle = @"1";
    }
    stringColor = [_contactModel valueForKey:@"icon_color"];
    
    
    if ([stringStyle isEqualToString:@"1"]) {
        _tblViewContent = [[UITableView alloc]initWithFrame:self.view.bounds];
        [_tblViewContent setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        _tblViewContent.dataSource = self;
        _tblViewContent.delegate = self;
        [self.view addSubview:_tblViewContent];
        [self setCells:nil];
        [_tblViewContent reloadData];
        
    }else{
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        float widthCollection  = self.view.frame.size.width;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            widthCollection = SCREEN_WIDTH*2/3;
        }
        _colllectionViewContent  = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, widthCollection, self.view.frame.size.height -100) collectionViewLayout:layout];
        [_colllectionViewContent setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        _colllectionViewContent.dataSource = self;
        _colllectionViewContent.delegate = self;
        _colllectionViewContent.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_colllectionViewContent];
        [self setCells:nil];
    }

}

#pragma mark Table View Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TableViewContact"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    if ([simiSection.identifier isEqualToString:EMAILCONTACT_SECTIONMAIN]) {
        SimiRow *row = [simiSection objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWEMAIL]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusemail_tbl"]imageWithColor:[[SimiGlobalVar sharedInstance]colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Email")];
            [cell addSubview:lblName];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWCALL]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 11, 28 , 28)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusphone_tbl"]imageWithColor:[[SimiGlobalVar sharedInstance]colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Call")];
            [cell addSubview:lblName];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWMESSAGE]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusmessage_tbl"]imageWithColor:[[SimiGlobalVar sharedInstance]colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Message")];
            [cell addSubview:lblName];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWWEBSITE]) {
            UIImageView *imageIcon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 15, 33, 20)];
            [imageIcon setImage:[[UIImage imageNamed:@"contactusweb_tbl"]imageWithColor:[[SimiGlobalVar sharedInstance]colorWithHexString:stringColor]]];
            [cell addSubview:imageIcon];
            
            UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, 200, 50)];
            [lblName setFont:[UIFont fontWithName:THEME_FONT_NAME size:18]];
            [lblName setText:SCLocalizedString(@"Website")];
            [cell addSubview:lblName];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return numberItemPhone;
    }else
        return numberItemPad;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
#pragma mark Table View DataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SimiSection *simiSection = [_cells objectAtIndex:indexPath.section];
    if ([simiSection.identifier isEqualToString:EMAILCONTACT_SECTIONMAIN]) {
        SimiRow *row = [simiSection objectAtIndex:indexPath.row];
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWEMAIL]) {
            [self btnEmailClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWCALL]) {
            [self btnCallClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWMESSAGE]) {
            [self btnMessageClick];
        }
        
        if ([row.identifier isEqualToString:EMAILCONTACT_ROWWEBSITE]) {
            [self btnWebsiteClick];
        }
    }
}
#pragma mark ListPhone Delegate

- (void)didSelectPhoneNumber:(NSString *)stringPhone
{
    stringPhoneNumber = stringPhone;
    if (_isCall) {
        [self call];
    }else
    {
        [self sendMessage];
    }
}

//  Liam ADD 150504
#pragma mark set Table

- (void)setCells:(SimiTable *)cells_
{
    if (cells_) {
        _cells = cells_;
    }else
    {
        _cells = [SimiTable new];
        SimiSection *section = [[SimiSection alloc]initWithIdentifier:EMAILCONTACT_SECTIONMAIN];
        
        if (arrayEmailCheck.count > 0) {
            SimiRow *rowEmail = [SimiRow new];
            rowEmail.identifier = EMAILCONTACT_ROWEMAIL;
            [section addRow:rowEmail];
        }
        
        if (arrayPhoneNumberAfterCheck.count > 0 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            SimiRow *rowCall = [SimiRow new];
            rowCall.identifier = EMAILCONTACT_ROWCALL;
            [section addRow:rowCall];
        }
        
        if (arrayMessageNumberAfterCheck.count > 0) {
            SimiRow *rowMessage = [SimiRow new];
            rowMessage.identifier = EMAILCONTACT_ROWMESSAGE;
            [section addRow:rowMessage];
        }
        
        if (![stringWebsite isEqualToString:@""]) {
            SimiRow *rowWebsite = [SimiRow new];
            rowWebsite.identifier = EMAILCONTACT_ROWWEBSITE;
            [section addRow:rowWebsite];
        }
        [_cells addObject:section];
    }
}
//  End 150504
#pragma mark DataSource CollectionView
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPhone) {
        return numberItemPhone;
    }else{
        return numberItemPad;
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return  1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(itemWidth, itemHeight);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [arrayIntifier objectAtIndex:indexPath.row];
    [self.colllectionViewContent registerClass:[InstantContactCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    InstantContactCollectionViewCell *cell =[self.colllectionViewContent dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.stringColor = stringColor;
//    cell.backgroundColor = [UIColor blueColor];
    [cell setCellCollection:[arrayIntifier objectAtIndex:indexPath.row]:[arrayLabel objectAtIndex:indexPath.row]];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *string = [arrayLabel objectAtIndex:indexPath.row];
    if ([string isEqualToString:@"Email"]) {
        
        [self btnEmailClick];
        
    }else if ([string isEqualToString:@"Call"]){
        [self btnCallClick];
        
    }else if ([string isEqualToString:@"Message"]){
        [self btnMessageClick];
        
    }else if ([string isEqualToString:@"Website"]){
        
        [self btnWebsiteClick];
    }
    
   
}

@end
