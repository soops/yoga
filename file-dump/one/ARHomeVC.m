//
//  ARHomeVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARHomeVC.h"
#import "AROneUser.h"
#import "ARAppDelegate.h"
#import "SASlideMenuRootViewController.h"
#import "MSPageViewControllerWelcome.h"

@interface ARHomeVC ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation ARHomeVC

- (NSArray *)pageIdentifiers {
    return @[@"page1", @"page2", @"page3", @"page4"];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.homeTbView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    if ([AROneUser isAuthorized]) {
        [self enterApp];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden=YES;
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
    cell.textLabel.font=[UIFont fontWithName:@"Helvetica Neue" size:20];
    if (indexPath.row==0) {
        cell.textLabel.text=@"Sign Up";
    } else {
        cell.textLabel.text=@"Login";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row==0) {
        NSLog(@"Show signup screen");
        [self performSegueWithIdentifier:@"ShowSignUpVC" sender:self];
    } else {
        [self performSegueWithIdentifier:@"ShowLoginVC" sender:self];
    }
}

- (void)enterApp {
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabbarVC=[self.storyboard instantiateViewControllerWithIdentifier:@"tabbarVC"];
//    SASlideMenuRootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"rootVC"];
//    [UIView transitionWithView:self.view
//                      duration:1.0f
//                       options:UIViewAnimationOptionTransitionFlipFromLeft
//                    animations:^(void) {
//                        appDelegate.window.rootViewController=tabbarVC;
//                    } completion:NULL];
    appDelegate.window.rootViewController=tabbarVC;
}

@end
