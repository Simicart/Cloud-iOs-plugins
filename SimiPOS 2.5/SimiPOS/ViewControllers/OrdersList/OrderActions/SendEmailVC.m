//
//  SendEmailVC.m
//  SimiPOS
//
//  Created by mac on 3/15/16.
//  Copyright © 2016 Nguyen Duc Chien. All rights reserved.
//

#import "SendEmailVC.h"
#import "MSValidator.h"
#import "SendEmailOrderModel.h"

@interface SendEmailVC ()
@property (strong, nonatomic) UIActivityIndicatorView *animation;
@end

@implementation SendEmailVC{
    SendEmailOrderModel *sendEmailOrderModel;
}
@synthesize animation;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.btnSend.layer.cornerRadius =5.0;
    
    UITapGestureRecognizer * tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired =1 ;
    [self.view addGestureRecognizer:tap];
}

- (IBAction)sendButtonClick:(id)sender {
    
    [self sendEmailAction];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [textField resignFirstResponder];
    
    [self sendEmailAction];
    
    return YES;
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

-(void)sendEmailAction{
    if ([MSValidator validateEmail:self.txtSend.text]) {
        [self sendEmail];
        
    }else{
        self.lblMessage.text =INPUT_INVALID_EMAIL_ADRESS;
    }
}

#pragma mark - UIText Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.lblMessage.text =@"";
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

    self.lblMessage.text =@"";
    return YES;
}

- (void)sendEmail
{
    [self.txtSend resignFirstResponder];
    if (animation == nil) {
        animation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        animation.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        animation.frame = self.view.bounds;
        [self.view addSubview:animation];
    }
    [animation startAnimating];
    [[[NSThread alloc] initWithTarget:self selector:@selector(sendEmailThread) object:nil] start];
}

- (void)sendEmailThread
{
    // Johan
    sendEmailOrderModel = [SendEmailOrderModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSendEmail:) name:@"DidSendEmail" object:sendEmailOrderModel];
    [sendEmailOrderModel sendEmail:[self.order getIncrementId] email:self.txtSend.text];
    // End
}

// Johan
- (void) didSendEmail:(NSNotification *) noti{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DidSendEmail" object:sendEmailOrderModel];
    RetailerPosResponder *respone = [noti.userInfo valueForKey:@"responder"];
    if([respone.status isEqualToString:@"SUCCESS"]){
        [self dismissViewControllerAnimated:YES completion:^{
            [Utilities alert:NSLocalizedString(@"Success", nil) withMessage:NSLocalizedString(@"The order email has been sent.", nil)];
        }];
    }else{
        NSString * message = [NSString stringWithFormat:@"%@",[respone.message objectAtIndex:0]];
        if(message){
            [Utilities alert:NSLocalizedString(@"Error", nil) withMessage:message];
        }
    }
}
// End

@end
