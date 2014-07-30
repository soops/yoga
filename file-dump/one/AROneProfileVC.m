//
//  AROneProfileVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "AROneProfileVC.h"
#import "FacebookHelper.h"
#import "ARAppDelegate.h"
#import "FHSTwitterEngine.h"
#import "ARInstagramUser.h"
#import "ARTwitterUser.h"
#import "UIImageView+WebCache.h"

#define kUserName           @"USER_NAME"
#define kFullName           @"FULL_NAME"

@interface AROneProfileVC () {
    NSDictionary *accountInfoDict;
}

@end

@implementation AROneProfileVC

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
    self.profilePicture.layer.cornerRadius=40.0f;
    self.profilePicture.layer.borderWidth=2;
    self.profilePicture.layer.borderColor=[UIColor darkGrayColor].CGColor;
    self.profilePicture.clipsToBounds=YES;
    if (self.accountMode==1) {
        //-Facebook case
        NSString *fullName=[NSString stringWithFormat:@"%@ %@",[[ARFacebookUser sharedInstance] firstname],[[ARFacebookUser sharedInstance] lastname]];
        accountInfoDict=[NSDictionary dictionaryWithObjectsAndKeys:[[ARFacebookUser sharedInstance] username],kUserName,fullName,kFullName, nil];
        
            //-Load profile picture
        NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,[[ARFacebookUser sharedInstance] userId]];
        [self.profilePicture setImageWithURL:[NSURL URLWithString:urlSTR] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    } else if (self.accountMode==2) {
        //-Twitter case
        [self.profilePicture setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        NSString *twScreenName=[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
        twScreenName=[[[[twScreenName componentsSeparatedByString:@"&"] lastObject] componentsSeparatedByString:@"="] lastObject];
        accountInfoDict=[NSDictionary dictionaryWithObjectsAndKeys:twScreenName,kUserName, nil];
        [self.profilePicture setImageWithURL:[NSURL URLWithString:[[ARTwitterUser sharedInstance] profilePicture]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    } else {
        //-Instagram case
        [self.profilePicture setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        accountInfoDict=[NSDictionary dictionaryWithObjectsAndKeys:[[ARInstagramUser sharedInstance] username],kUserName,[[ARInstagramUser sharedInstance] fullName],kFullName, nil];
        [self.profilePicture setImageWithURL:[NSURL URLWithString:[[ARInstagramUser sharedInstance] profilePicture]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
    
    [self.profileTbView reloadData];

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

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.accountMode==2) {
        return 2;//-twitter
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.accountMode!=2) {
        if (indexPath.row!=2) {
            UITableViewCell *acell=[tableView dequeueReusableCellWithIdentifier:@"CELL"];
            if (indexPath.row==0) {
                acell.textLabel.text=@"Username";
                acell.detailTextLabel.text=[accountInfoDict objectForKey:kUserName];
            } else if (indexPath.row==1) {
                acell.textLabel.text=@"Full name";
                acell.detailTextLabel.text=[accountInfoDict objectForKey:kFullName];
            }
            
            return acell;
        } else {
            UITableViewCell *acell=[tableView dequeueReusableCellWithIdentifier:@"DELETE"];
            
            return acell;
        }
    } else {
        //-Twitter case
        if (indexPath.row!=1) {
            UITableViewCell *acell=[tableView dequeueReusableCellWithIdentifier:@"CELL"];
            acell.textLabel.text=@"Username";
            acell.detailTextLabel.text=[accountInfoDict objectForKey:kUserName];
            
            return acell;
        } else {
            UITableViewCell *acell=[tableView dequeueReusableCellWithIdentifier:@"DELETE"];
            
            return acell;
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self showConfirmMessage:@"Are you sure to delete this account?" withTitle:@"Confirmation" confirmButton:@"OK" cancelButton:@"Cancel"];
}

- (IBAction)btnCloseTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-override these methods
- (void)confirmButtonTappedAtIndex:(NSInteger)index {
    if (index==1) {
        if (self.accountMode==1) {
            //-delete facebook account
            [[FacebookHelper sharedInstance] doLogout];
            [ARFacebookUser deleFbUserInfo];
        } else if (self.accountMode==2) {
            //-delete
            [[FHSTwitterEngine sharedEngine] clearAccessToken];
            [ARTwitterUser deleITUserInfo];
        } else {
            //-instagram
            ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
            [appDelegate.instagram logout];
            [ARInstagramUser deleITUserInfo];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
