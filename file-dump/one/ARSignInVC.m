//
//  ARSignInVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARSignInVC.h"
#import "ARAppDelegate.h"
#import "SASlideMenuRootViewController.h"
#import "WKValidateHelper.h"
#import "AROneHelper.h"
#import "AROneUser.h"
#import "SHConstant.h"

@interface ARSignInVC ()<UITableViewDelegate,UITableViewDataSource,OneHelperDelegate> {
    NSString *email;
    NSString *password;
}

@property (strong, nonatomic) IBOutlet UITableView *loginTbView;
@end

@implementation ARSignInVC

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
    //-render navigation
    [self renderNavigationBarWithTitle:@"Login" leftButtonTitle:nil rightButtonTitle:@"Login"];
    
    
    UIButton *footerLb=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.loginTbView.frame.size.width, 40)];
    [footerLb setTitle:@"Forgot your password?" forState:UIControlStateNormal];
    [footerLb setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    footerLb.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    [footerLb addTarget:self action:@selector(forgotPassTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.loginTbView.tableFooterView=footerLb;
}

- (void)viewDidAppear:(BOOL)animated {
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"LoginCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    UITextField *textField=(UITextField*)[cell viewWithTag:10];
    if (indexPath.row==0) {
        textField.placeholder=@"Email";
        textField.secureTextEntry=NO;
    } else {
        textField.placeholder=@"Password";
        textField.secureTextEntry=YES;
    }
    return cell;
}

- (void)forgotPassTapped:(id)sender {
    NSLog(@"Forgot password tapped");
    [self performSegueWithIdentifier:@"ShowForgotPassVC" sender:self];
}

#pragma mark - Overriden methods
- (void)rightBarButtonTapped:(id)sender {
    UITableViewCell *emailCell=[self.loginTbView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITextField *emailTextField=(UITextField*)[emailCell viewWithTag:10];
    email=emailTextField.text;
    UITableViewCell *passwordCell=[self.loginTbView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
    UITextField *passwordTextField=(UITextField*)[passwordCell viewWithTag:10];
    password=passwordTextField.text;

    if ([WIDValidateHelper isEmailAddress:email]) {
        if ([password length]>=5) {
            //-implement login here
            NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:email,@"email",password,@"password", nil];
            [AROneHelper sharedInstance].oneDelegate=self;
            [[AROneHelper sharedInstance] loginWithUserInfo:userInfo];
        } else {
            [self showAlertMessage:@"Please enter a valid password" withTitle:@"Error"];
        }
    } else {
        [self showAlertMessage:@"Email is invalid" withTitle:@"Error"];
    }
}

- (void)leftBarButtonTapped:(id)sender {
    
}

- (void)enterApp {
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabbarVC=[self.storyboard instantiateViewControllerWithIdentifier:@"tabbarVC"];
//    [UIView transitionWithView:self.view duration:1.0f options:UIViewAnimationOptionTransitionNone animations:^(void) {
        appDelegate.window.rootViewController=tabbarVC;
//    } completion:NULL];
}

#pragma mark - OneDelegate
- (void)didFinishOneServiceWithResult:(NSDictionary*)result task:(NSInteger)task {
    NSInteger resultCode=[[result objectForKey:@"code"] integerValue];
    if (resultCode==0) {
        AROneUser *oneUser=[[AROneUser alloc] init];
        oneUser.email=[result objectForKey:@"email"];
        oneUser.name=[result objectForKey:@"name"];
        oneUser.userId=[result objectForKey:@"userId"];
        oneUser.phone=[result objectForKey:@"phone"];
        oneUser.accessToken=[result objectForKey:@"sessionToken"];
        oneUser.fbAccessToken = [result objectForKey:@"facebook_access_token"];
        oneUser.fbUserId = [result objectForKey:@"facebook_id"];
        oneUser.fbUserName = [result objectForKey:@"facebook_username"];
        [AROneUser wirteDataToFile:oneUser];
        
        [[NSUserDefaults standardUserDefaults] setObject:oneUser.email forKey:ONE_EMAIL];
        [[NSUserDefaults standardUserDefaults] setObject:oneUser.accessToken forKey:SESSION_TOKEN];
        [[NSUserDefaults standardUserDefaults] setObject:oneUser.fbAccessToken forKey:FB_ACCESSTOKEN];
        [[NSUserDefaults standardUserDefaults] setObject:oneUser.fbUserId forKey:FB_USERID];
        [[NSUserDefaults standardUserDefaults] setObject:oneUser.fbUserName forKey:FB_USERNAME];
        
        if(oneUser.fbAccessToken != nil) {
            [ARAppDelegate application].fbInsertFlag = @"1";
        } else {
            [ARAppDelegate application].fbInsertFlag = @"0";
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:ONE_EMAIL]);
        
        [self enterApp];
    } else {
        [self showAlertMessage:[result objectForKey:@"message"] withTitle:@"Error"];
    }
}

- (void)didFailOneServiceWithError:(NSError*)error {
    NSLog(@"Error description: %@",error.description);
}

@end
