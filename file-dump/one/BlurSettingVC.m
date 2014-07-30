//
//  BlurSettingVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "BlurSettingVC.h"
#import "FacebookHelper.h"
#import "ARAppDelegate.h"
#import "FHSTwitterEngine.h"
#import "Instagram.h"
#import "SHConstant.h"
#import "ARFacebookUser.h"
#import "ARTwitterUser.h"
#import "ARInstagramUser.h"
#import "UIImageView+WebCache.h"
#import "ARLinkAccountsVC.h"
#import "ASDepthModalViewController.h"
#import "IBActionSheet.h"

#define kProfilePictureKey                  @"PROFILE_PICTURE"
#define kUserNameKey                        @"USERNAME"
#define kAccountTypeKey                     @"ACCOUNT_TYPE"

extern bool fAccountsHasChanged;

@interface BlurSettingVC ()<UITableViewDelegate,UITableViewDataSource,FHSTwitterEngineAccessTokenDelegate,IGSessionDelegate,UIActionSheetDelegate,IBActionSheetDelegate> {
    NSMutableArray *accounts;
    NSInteger selectedIndex;
    UIActionSheet *actionSheetREF;
}
@property (nonatomic, strong) IBActionSheet *standardIBAS;
@end

@implementation BlurSettingVC

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
    self.btImageView.image=self.blurBgImage;
    self.title=@"Accounts";
    self.accountTbView.backgroundColor=[UIColor clearColor];
    self.accountTbView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    //-data
    accounts=[NSMutableArray array];
    selectedIndex=-1;
    
    //-for twitter handling
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:@"F2UuKjSPrf0KAXH66naiww" andSecret:@"5D78724kzHm83WuQo2ynfiBI2aW4MlO6QMrnlzON5c"];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    //-instagram
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"IGAccessToken"];
    appDelegate.instagram.sessionDelegate = self;
    //-get facebook user info
    
    NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESSTOKEN]; // [[WFFacebookUser sharedInstance] accessToken]
    NSString *fbUserId = [[NSUserDefaults standardUserDefaults] objectForKey:FB_USERID]; // [WFFacebookUser sharedInstance].userId
    NSString *fbUserName = [[NSUserDefaults standardUserDefaults] objectForKey:FB_USERNAME]; // [[WFFacebookUser sharedInstance] username]
    // if ([[FacebookHelper sharedInstance] isUserAuthenticated])
    if (fbAccessToken != nil) {
        NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,fbUserId];
        NSMutableDictionary *facebookDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:urlSTR,kProfilePictureKey,fbUserName,kUserNameKey,@"Facebook",kAccountTypeKey, nil];
        [accounts addObject:facebookDict];
    }
    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
        NSMutableDictionary *twitterDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[ARTwitterUser sharedInstance] profilePicture],kProfilePictureKey,[[ARTwitterUser sharedInstance] username],kUserNameKey,@"Twitter",kAccountTypeKey, nil];
        [accounts addObject:twitterDict];
    }
    //-load newsfeed from Instagram
    if ([appDelegate.instagram isSessionValid]) {
        NSMutableDictionary *instaDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[ARInstagramUser sharedInstance] profilePicture],kProfilePictureKey,[[ARInstagramUser sharedInstance] username],kUserNameKey,@"Instagram",kAccountTypeKey, nil];
        [accounts addObject:instaDict];
    }
    
    [self.accountTbView beginUpdates];
    [self.accountTbView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.accountTbView endUpdates];
}

- (void)viewDidAppear:(BOOL)animated {
//    self.navigationController.navigationBarHidden=YES;
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
//    self.navigationController.navigationBarHidden=NO;
    self.tabBarController.tabBar.hidden=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)btnAddTapped:(id)sender {
    ARLinkAccountsVC *linkVC=[self.storyboard instantiateViewControllerWithIdentifier:@"SHLinkVC"];
    UINavigationController *naVC=[[UINavigationController alloc] initWithRootViewController:linkVC];
    [self presentViewController:naVC animated:YES completion:nil];
}

- (IBAction)btnSettingTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowSettingExtension" sender:self];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return accounts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellDict=[accounts objectAtIndex:indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];
    UIImageView *profilePic=(UIImageView*)[cell viewWithTag:10];
    [profilePic setImageWithURL:[NSURL URLWithString:[cellDict objectForKey:kProfilePictureKey]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    profilePic.layer.borderColor=[UIColor whiteColor].CGColor;
    profilePic.layer.borderWidth=1;
    profilePic.layer.cornerRadius=26;
    profilePic.clipsToBounds=YES;
    profilePic.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileImageTapped:)];
    tapGesture.numberOfTapsRequired=1;
    [profilePic addGestureRecognizer:tapGesture];
    
    UILabel *userName=(UILabel*)[cell viewWithTag:11];
    userName.textColor=[UIColor blackColor];
    userName.text=[cellDict objectForKey:kUserNameKey];
    UILabel *accountType=(UILabel*)[cell viewWithTag:12];
    accountType.textColor=[UIColor lightGrayColor];
    accountType.text=[cellDict objectForKey:kAccountTypeKey];
    
    return cell;
}

- (void)userProfileImageTapped:(UITapGestureRecognizer*)tapGesture {
    UIImageView *userPicture=(UIImageView*)[tapGesture view];
    UITableViewCell *parentCell=(UITableViewCell*)[[[userPicture superview] superview] superview];
    NSInteger cellIndex=[self.accountTbView indexPathForCell:parentCell].row;
    if (selectedIndex!=-1) {
        if (selectedIndex==cellIndex) {
            //-show Action sheet here
            UIActionSheet *actionSheet =[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this account" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
            [ASDepthModalViewController presentView:actionSheet];
            [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
        } else {
            //-remove delete icon for the previous row
            UITableViewCell *previousCell=[self.accountTbView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
            UIImageView *prevUserPicture=(UIImageView*)[previousCell viewWithTag:10];
//            [UIView transitionWithView:prevUserPicture duration:0.3 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                prevUserPicture.image=[UIImage imageNamed:@"profile_user.png"];
//            } completion:nil];
            
            //-show delete icon for current row
            [UIView transitionWithView:userPicture duration:0.3 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
                userPicture.image=[UIImage imageNamed:@"delete_sign-100"];
            } completion:nil];
            selectedIndex=cellIndex;
        }
    } else {
        //-no cell selected before
        [UIView transitionWithView:userPicture duration:0.3 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            userPicture.image=[UIImage imageNamed:@"delete_sign-100"];
        } completion:nil];
        selectedIndex=cellIndex;
    }
}

#pragma mark - Twitter Oauth delegate
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"SavedAccessHTTPBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)loadAccessToken {
    NSLog(@"access token: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"]);
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark - Internal method
- (void)handleDeleteAccount {
    NSDictionary *cellData=[accounts objectAtIndex:selectedIndex];
    NSString *accountTypeStr=[cellData objectForKey:kAccountTypeKey];
    if ([accountTypeStr isEqualToString:@"Facebook"]) {
        [[FacebookHelper sharedInstance] doLogout];
    } else if ([accountTypeStr isEqualToString:@"Twitter"]) {
        //-delete
        [[FHSTwitterEngine sharedEngine] clearAccessToken];
        [ARTwitterUser deleITUserInfo];
    } else if ([accountTypeStr isEqualToString:@"Instagram"]) {
        ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.instagram logout];
        [ARInstagramUser deleITUserInfo];
    }
    //-delete this row
    [accounts removeObjectAtIndex:selectedIndex];
    [self.accountTbView reloadData];
    selectedIndex=-1;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [ASDepthModalViewController dismiss];
    if (buttonIndex==0) {
        [self handleDeleteAccount];
        fAccountsHasChanged=YES;
    } else if (buttonIndex==1) {
        selectedIndex=-1;
        [self.accountTbView reloadData];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    [ASDepthModalViewController dismiss];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    [ASDepthModalViewController dismiss];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [ASDepthModalViewController dismiss];
}

#pragma mark - IGSessionDelegate

-(void)igDidLogin {
    
}

-(void)igDidNotLogin:(BOOL)cancelled {
    
}

-(void)igDidLogout {
    
}

-(void)igSessionInvalidated {
    
}

@end
