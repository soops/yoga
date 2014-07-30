//
//  SHSettingsVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARSettingsVC.h"
#import "ARAppDelegate.h"
#import "SHConstant.h"
#import "FacebookHelper.h"
#import "ARTwitterUser.h"
#import "UIImageView+WebCache.h"
#import "ASDepthModalViewController.h"

#define kProfilePictureKey                  @"PROFILE_PICTURE"
#define kUserNameKey                        @"USERNAME"
#define kAccountTypeKey                     @"ACCOUNT_TYPE"
#define FACEBOOK                            @"Facebook"
#define TWITTER                             @"Twitter"
#define INSTAGRAM                           @"Instagram"
#define PLACEHOLDER_IMAGE                   @"placeholder"

@implementation ARSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = TRUE;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars=NO;
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    [self setUpAccounts];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 173;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *cellDict=[accountsArray objectAtIndex:indexPath.row];
    SWTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AccountCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    cell.delegate = self;
    
    UIImageView *profilePic=(UIImageView*)[cell viewWithTag:100];
    profilePic.layer.borderColor=[UIColor whiteColor].CGColor;
    profilePic.layer.borderWidth=2;
    profilePic.layer.cornerRadius=30;
    profilePic.clipsToBounds=YES;
    profilePic.userInteractionEnabled=YES;
    [profilePic setHidden:TRUE];
    
//    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userProfileImageTapped:)];
//    tapGesture.numberOfTapsRequired=1;
//    [profilePic addGestureRecognizer:tapGesture];
    
    UILabel *userName=(UILabel*)[cell viewWithTag:101];
    [userName setHidden:TRUE];
    
    UILabel *accountType=(UILabel*)[cell viewWithTag:102];
    accountType.textColor=[UIColor whiteColor];
    
//    UIButton *plusButton = (UIButton *)[cell viewWithTag:103];
    
    if(indexPath.row == 0) {
        // Facebook
        cell.contentView.backgroundColor = [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
        accountType.text = FACEBOOK;
        NSDictionary *cellDict = [accountsDict objectForKey:FACEBOOK];
        if(cellDict != nil) {
            cell.leftUtilityButtons = [self leftButtons];
            [profilePic setHidden: FALSE];
            [profilePic setImageWithURL:[NSURL URLWithString:[cellDict objectForKey:kProfilePictureKey]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]];
            [userName setHidden:FALSE];
            userName.text = [cellDict objectForKey:kUserNameKey];
        }
    } else if(indexPath.row == 1) {
        // Twitter
        cell.contentView.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
        accountType.text = TWITTER;
        NSDictionary *cellDict = [accountsDict objectForKey:TWITTER];
        if(cellDict != nil){
            cell.leftUtilityButtons = [self leftButtons];
            [profilePic setHidden: FALSE];
            [profilePic setImageWithURL:[NSURL URLWithString:[cellDict objectForKey:kProfilePictureKey]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]];
            [userName setHidden:FALSE];
            userName.text = [cellDict objectForKey:kUserNameKey];
        }
    } else {
        // Instagram
        cell.contentView.backgroundColor = [UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f];
        accountType.text = INSTAGRAM;
        NSDictionary *cellDict = [accountsDict objectForKey:INSTAGRAM];
        if(cellDict != nil) {
            cell.leftUtilityButtons = [self leftButtons];
            [profilePic setHidden: FALSE];
            [profilePic setImageWithURL:[NSURL URLWithString:[cellDict objectForKey:kProfilePictureKey]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_IMAGE]];
            [userName setHidden:FALSE];
            userName.text = [cellDict objectForKey:kUserNameKey];
        }
    }
    
    return cell;
}

- (void)setUpAccounts {
    
    accountsDict = [[NSMutableDictionary alloc] init];

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
        [accountsArray addObject:facebookDict];
        [accountsDict setObject:facebookDict forKey:FACEBOOK];
    }
    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
        NSMutableDictionary *twitterDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[ARTwitterUser sharedInstance] profilePicture],kProfilePictureKey,[[ARTwitterUser sharedInstance] username],kUserNameKey,@"Twitter",kAccountTypeKey, nil];
        [accountsArray addObject:twitterDict];
        [accountsDict setObject:twitterDict forKey:TWITTER];
    }
    //-load newsfeed from Instagram
    if ([appDelegate.instagram isSessionValid]) {
        NSMutableDictionary *instaDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[ARInstagramUser sharedInstance] profilePicture],kProfilePictureKey,[[ARInstagramUser sharedInstance] username],kUserNameKey,@"Instagram",kAccountTypeKey, nil];
        [accountsArray addObject:instaDict];
        [accountsDict setObject:instaDict forKey:INSTAGRAM];
    }
    
    [self.accountsTableView beginUpdates];
    [self.accountsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.accountsTableView endUpdates];
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0] icon:[UIImage imageNamed:@"delete_sign"]];
    return leftUtilityButtons;
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

#pragma mark - IGSessionDelegate

-(void)igDidLogin {
    
}

-(void)igDidNotLogin:(BOOL)cancelled {
    
}

-(void)igDidLogout {
    
}

-(void)igSessionInvalidated {
    
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [self.accountsTableView indexPathForCell:cell];
    if (indexPath) {
        UIActionSheet *actionSheet =[[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this account" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
        actionSheet.tag = indexPath.row;
        [ASDepthModalViewController presentView:actionSheet];
        [actionSheet showInView:[[[UIApplication sharedApplication] delegate] window]];
        if(indexPath.row == 0) {
            
        } else if(indexPath.row == 1) {
            
        } else if(indexPath.row == 2) {
            
        }
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2: {
            // set to NO to disable all right utility buttons appearing
            return YES;
        }
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [ASDepthModalViewController dismiss];
    if (buttonIndex == 0) {
        switch (actionSheet.tag) {
            case 0:
                // Facebook
                [[FacebookHelper sharedInstance] doLogout];
                [accountsDict removeObjectForKey:FACEBOOK];
                break;
            case 1:
                // Twitter
                [[FHSTwitterEngine sharedEngine] clearAccessToken];
                [ARTwitterUser deleITUserInfo];
                [accountsDict removeObjectForKey:TWITTER];
                break;
            case 2:
                // Instagram
                [[ARAppDelegate application].instagram logout];
                [ARInstagramUser deleITUserInfo];
                [accountsDict removeObjectForKey:INSTAGRAM];
                break;
            default:
                break;
        }
        [self.accountsTableView reloadData];
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

@end
