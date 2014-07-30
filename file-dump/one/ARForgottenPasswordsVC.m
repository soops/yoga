//
//  ARForgottenPasswordsVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//


#import "ARForgottenPasswordsVC.h"
#import "AROneHelper.h"
#import "WKValidateHelper.h"

@interface ARForgottenPasswordsVC ()<UITableViewDataSource,UITableViewDelegate,OneHelperDelegate>
@property (strong, nonatomic) IBOutlet UITableView *forgotTbView;

@end

@implementation ARForgottenPasswordsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderNavigationBarWithTitle:@"Forgot Password" leftButtonTitle:nil rightButtonTitle:@"Send"];
}

- (void)didReceiveMemoryWarning {
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"ForgotPassCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Overriden methods
- (void)rightBarButtonTapped:(id)sender {
    UITableViewCell *emailCell=[self.forgotTbView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    UITextField *emailTextField=(UITextField*)[emailCell viewWithTag:10];
    if ([WIDValidateHelper isEmailAddress:emailTextField.text]) {
        [AROneHelper sharedInstance].oneDelegate=self;
        [[AROneHelper sharedInstance] sendResetPasswordRequestForEmail:emailTextField.text];
    } else {
        [self showAlertMessage:@"Please enter a valid email" withTitle:@"Error"];
    }
}

#pragma mark - OneDelegate
- (void)willStartOneService:(NSInteger)task {

}
- (void)didFinishOneServiceWithResult:(NSDictionary*)result task:(NSInteger)task {
    NSInteger resultCode=[[result objectForKey:@"code"] integerValue];
    if (resultCode==0) {
        [self showAlertMessage:[result objectForKey:@"message"]];
    } else {
        [self showAlertMessage:[result objectForKey:@"message"] withTitle:@"Error"];
    }
}
- (void)didFailOneServiceWithError:(NSError*)error {
    [self showAlertMessage:error.description withTitle:@"Error"];
}

@end
