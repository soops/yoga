//
//  ARRegistrationVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARRegistrationVC.h"
#import "WKValidateHelper.h"
#import "AROneHelper.h"
#import "ARAppDelegate.h"
#import "SASlideMenuRootViewController.h"
#import "AROneUser.h"
#import "SHConstant.h"

@interface ARRegistrationVC ()<UITableViewDataSource,UITableViewDelegate,OneHelperDelegate> {
    NSString *emailRef;
    NSString *passwordRef;
}

@end

@implementation ARRegistrationVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderNavigationBarWithTitle:@"Sign up" leftButtonTitle:nil rightButtonTitle:@"Done"];
    self.navigationController.navigationBarHidden=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *signupCell=[tableView dequeueReusableCellWithIdentifier:@"SignUpCell"];
    signupCell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (indexPath.row==0) {
        UITextField *textField=(UITextField*)[signupCell viewWithTag:10];
        textField.placeholder=@"Email";
        textField.secureTextEntry=NO;
    } else {
        UITextField *textField=(UITextField*)[signupCell viewWithTag:10];
        textField.placeholder=@"Password";
        textField.secureTextEntry=YES;
    }
    return signupCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 100;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLb=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    headerLb.text=@"  Account";
    headerLb.backgroundColor=[UIColor clearColor];
    headerLb.textColor=UIColorFromRGB(0xababb0);
    headerLb.font=[UIFont fontWithName:@"Helvetica Neue" size:18];
    
    return headerLb;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UILabel *footerLb=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    footerLb.text=@"By creating an account, I accept One's Terms of Services and Privacy Policy";
    footerLb.numberOfLines=0;
    footerLb.textAlignment=NSTextAlignmentCenter;
    footerLb.backgroundColor=[UIColor clearColor];
    footerLb.textColor=UIColorFromRGB(0xababb0);
    footerLb.font=[UIFont fontWithName:@"Helvetica Neue" size:12];
    
    return footerLb;
}

#pragma mark - Overriden metods
- (void)rightBarButtonTapped:(id)sender {
    UITableViewCell *emailCell=[self.signUpTbView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITextField *emailTextField=(UITextField*)[emailCell viewWithTag:10];
    NSString *email=emailTextField.text;
    emailRef=email;
    UITableViewCell *passCell=[self.signUpTbView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    UITextField *passTextField=(UITextField*)[passCell viewWithTag:10];
    NSString *password=passTextField.text;
    passwordRef=password;
    if ([WIDValidateHelper isEmailAddress:email]) {
        if ([password length]>=5) {
            //-implement login here
            [AROneHelper sharedInstance].oneDelegate=self;
            NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:@"hero",@"name",email,@"email",password,@"password",@"0978765431",@"phone", nil];
            [[AROneHelper sharedInstance] createAccountWithUserInfo:userInfo];
        } else {
            [self showAlertMessage:@"Please enter a valid password" withTitle:@"Error"];
        }
    } else {
        [self showAlertMessage:@"Email is invalid" withTitle:@"Error"];
    }
}

#pragma mark - OneHelperDelegate
- (void)willStartOneService:(NSInteger)task {
    NSLog(@"will start service: %d",task);
}

- (void)didFinishOneServiceWithResult:(NSDictionary*)result task:(NSInteger)task {
    NSLog(@"response: %@",result);
    
    [[NSUserDefaults standardUserDefaults] setObject:[result valueForKey:@"email"] forKey:ONE_EMAIL];
    [[NSUserDefaults standardUserDefaults] setObject:[result valueForKey:@"sessionToken"] forKey:SESSION_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [ARAppDelegate application].fbInsertFlag = @"0";
    
    if (task==SHOneCreateAccount) {
        NSInteger resultCode=[[result objectForKey:@"code"] integerValue];
        if (resultCode==0) {
            //-create account successfully, relogin here
            NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:emailRef,@"email",passwordRef,@"password", nil];
            [AROneHelper sharedInstance].oneDelegate=self;
            [[AROneHelper sharedInstance] loginWithUserInfo:userInfo];
        } else {
            [self showAlertMessage:[result objectForKey:@"message"] withTitle:@"Error"];
        }
    } else if (task==SHOneLogin) {
        NSInteger resultCode=[[result objectForKey:@"code"] integerValue];
        if (resultCode==0) {
            AROneUser *oneUser=[[AROneUser alloc] init];
            oneUser.email=[result objectForKey:@"email"];
            oneUser.name=[result objectForKey:@"name"];
            oneUser.userId=[result objectForKey:@"userId"];
            oneUser.phone=[result objectForKey:@"phone"];
            oneUser.accessToken=[result objectForKey:@"sessionToken"];
            [AROneUser wirteDataToFile:oneUser];
            [self performSegueWithIdentifier:@"ShowLinkVC" sender:self];
        } else {
            [self showAlertMessage:[result objectForKey:@"message"] withTitle:@"Error"];
        }
    }
}

- (void)didFailOneServiceWithError:(NSError*)error {
    [self showAlertMessage:[error description] withTitle:@"Error"];
}

#pragma mark - Utilities method
- (void)enterApp {
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    SASlideMenuRootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"rootVC"];
    [UIView transitionWithView:self.view
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^(void) {
                        appDelegate.window.rootViewController=rootVC;
                    } completion:NULL];
}

@end
