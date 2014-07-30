//
//  WelcomeViewController.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "WelcomeViewController.h"
#import "SASlideMenuRootViewController.h"
#import "ARAppDelegate.h"
#import "FacebookHelper.h"
#import "FHSTwitterEngine.h"
#import "SASlideMenuNavigationController.h"
#import "SHFeedVC.h"
#import "ARInstagramUser.h"
#import "ARTwitterUser.h"


#define APP_ID @"c5a4d1a13b14470ba84941f483df0845"


#define PULL_THRESHOULD         60
#define facebookButtonTag       8
#define twitterButtonTag        9
#define instagramButtonTag      10
#define continueButtonTag       11

extern int feedMode;

@interface WelcomeViewController ()<UIScrollViewDelegate,FacebookHelperDelegate,FHSTwitterEngineAccessTokenDelegate,IGSessionDelegate,IGRequestDelegate> {
    ARAppDelegate *appDelegate;
    NSString *twScreenName;
    UIButton *fbButtonRef;
    UIButton *twButtonRef;
    UIButton *itButtonRef;
    UIButton *continueButtonRef;
    NSString *interacting_button;
}

@end

@implementation WelcomeViewController

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
    appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    //-setup paging for scrollview
    self.scrollView.pagingEnabled=YES;
    self.scrollView.delegate=self;
    
    self.welcomeBg.frame=CGRectMake(self.scrollView.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.welcomeBg.image=[UIImage imageNamed:@"Welcome"];
    
    UIViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"LinkVC"];
    UIView *linkVCView = vc.view;
    linkVCView.frame=self.scrollView.frame;
    [self.scrollView addSubview:linkVCView];
    
    self.scrollView.contentSize =  CGSizeMake(self.scrollView.frame.size.width * 2, self.scrollView.frame.size.height);
    self.scrollView.contentOffset=CGPointMake(self.scrollView.frame.size.width, 0);
    
    //-Continue button
    UIButton *continueBtn=(UIButton*)[linkVCView viewWithTag:continueButtonTag];
    continueBtn.hidden=YES;
    continueButtonRef=continueBtn;
    [continueBtn addTarget:self action:@selector(continueButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //-Add button action
    UIButton *fbButton = (UIButton*)[linkVCView viewWithTag:facebookButtonTag];
    fbButtonRef=fbButton;
    fbButton.titleLabel.font=[UIFont systemFontOfSize:12];
    [fbButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        continueBtn.hidden=NO;
        NSString *fbButtonTitle=[NSString stringWithFormat:@"Logged in as %@",[[ARFacebookUser sharedInstance] username]];
        [fbButton setTitle:fbButtonTitle forState:UIControlStateNormal];
    } else {
        NSString *fbButtonTitle=@"Add a Facebook account";
        [fbButton setTitle:fbButtonTitle forState:UIControlStateNormal];
    }
    [fbButton addTarget:self action:@selector(facebookTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //-Twitter integration
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:@"F2UuKjSPrf0KAXH66naiww" andSecret:@"5D78724kzHm83WuQo2ynfiBI2aW4MlO6QMrnlzON5c"];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    UIButton *twButton = (UIButton*)[linkVCView viewWithTag:twitterButtonTag];
    twButtonRef=twButton;
    twButton.titleLabel.font=[UIFont systemFontOfSize:12];
    [twButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
        //logged in already
        continueBtn.hidden=NO;
        NSString *twButtonTitle=[NSString stringWithFormat:@"Logged in as %@",twScreenName];
        [twButton setTitle:twButtonTitle forState:UIControlStateNormal];
    } else {
        [twButton setTitle:@"Add a Twitter account" forState:UIControlStateNormal];
    }
    [twButton addTarget:self action:@selector(twitterTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //-Instagram
    UIButton *instButton = (UIButton*)[linkVCView viewWithTag:instagramButtonTag];
    itButtonRef=instButton;
    [instButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    instButton.titleLabel.font=[UIFont systemFontOfSize:12];
    [instButton addTarget:self action:@selector(instagramTapped:) forControlEvents:UIControlEventTouchUpInside];
    appDelegate.instagram = [[Instagram alloc] initWithClientId:APP_ID
                                                delegate:nil];
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"IGAccessToken"];
    if ([appDelegate.instagram isSessionValid]) {
            //logged in already
        continueBtn.hidden=NO;
        NSString *itBtTitle=[NSString stringWithFormat:@"Logged in as %@",[ARInstagramUser sharedInstance].username];
        [instButton setTitle:itBtTitle forState:UIControlStateNormal];
    } else {
        [instButton setTitle:@"Add an Instagram account" forState:UIControlStateNormal];
    }
    [appDelegate.instagram setSessionDelegate:self];
    interacting_button=@"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //-do nothing now
}

#pragma mark - button handling action
- (void)continueButtonTapped:(id)sender {
    interacting_button=@"continue";
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]||[appDelegate.instagram isSessionValid]||[[FHSTwitterEngine sharedEngine] isAuthorized]) {
        SASlideMenuRootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier:@"rootVC"];
        [UIView transitionWithView:self.view
                          duration:1.0f
                           options:UIViewAnimationOptionTransitionFlipFromLeft
                        animations:^(void) {
                            appDelegate.window.rootViewController=rootVC;
                        } completion:NULL];
    } else {
        [self showAlertMessage:@"Please link at least one social account"];
    }
}
- (void)facebookTapped:(id)sender {
    interacting_button=@"facebook";
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        //-logged already, log out popup here
        [self showConfirmMessage:@"Are you sure you want to logout Facebook" withTitle:@"Confirm" confirmButton:@"OK" cancelButton:@"Cancel"];
    } else {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] doLogin];
    }
}

- (void)twitterTapped:(id)sender {
    interacting_button=@"twitter";
    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
        [self showConfirmMessage:@"Are you sure you want to logout Twitter" withTitle:@"Confirm" confirmButton:@"OK" cancelButton:@"Cancel"];
    } else {
        [self loginOAuth];
    }
}

- (void)loginOAuth {
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        NSString *twButtonTitle=[NSString stringWithFormat:@"Logged in as %@",twScreenName];
        [twButtonRef setTitle:twButtonTitle forState:UIControlStateNormal];
        
        //-get profile info here
        id returnJson=[[FHSTwitterEngine sharedEngine] getUserInfo:twScreenName];
        if ([returnJson isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict=(NSDictionary*)returnJson;
            ARTwitterUser *twUser=[[ARTwitterUser alloc] init];
            twUser.userId=[dataDict objectForKey:@"id_str"];
            twUser.username=[dataDict objectForKey:@"name"];
            twUser.screenName=[dataDict objectForKey:@"screen_name"];
            twUser.accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
//            twUser.profilePicture=[dataDict objectForKey:@"profile_image_url"];
            twUser.profilePicture  = [[FHSTwitterEngine sharedEngine] getProfileImageURLStringForUsername:twUser.username andSize:FHSTwitterEngineImageSizeBigger];
            twUser.coverPhoto=[dataDict objectForKey:@"profile_banner_url"];
            twUser.numberFollowers=[[dataDict objectForKey:@"followers_count"] integerValue];
            twUser.numberFollowing=[[dataDict objectForKey:@"friends_count"] integerValue];
            twUser.description=[dataDict objectForKey:@"description"];
            twUser.location=[dataDict objectForKey:@"location"];
            twUser.tweetsCount = [[dataDict objectForKey:@"statuses_count"] integerValue];
            
            [ARTwitterUser wirteDataToFile:twUser];
        }
    }];
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)instagramTapped:(id)sender {
    interacting_button=@"instagram";

    if ([appDelegate.instagram isSessionValid]) {
        [self showConfirmMessage:@"Are you sure that you want to logout Instagram" withTitle:@"Confirm" confirmButton:@"OK" cancelButton:@"Cancel"];
    } else {
        [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }
}

#pragma mark - FacebookHelperDelegate
- (void)userDidLogin:(NSDictionary *)dic {
    [FacebookHelper sharedInstance].fbDelegate=self;
    [[FacebookHelper sharedInstance] getProfileMe];
    continueButtonRef.hidden=NO;
}

- (void)userDidLogout:(NSDictionary *)dic {
    NSLog(@"did log out");
}
- (void)userDidCancelLogin:(NSDictionary *)dic {
    NSLog(@"did cancel login");
}

- (void) meProfileComplete:(NSDictionary *)dic {
    NSString *fbButtonTitle=[NSString stringWithFormat:@"Logged in as %@",[[ARFacebookUser sharedInstance] username]];
    [fbButtonRef setTitle:fbButtonTitle forState:UIControlStateNormal];
}

#pragma mark - Twitter Oauth delegate
- (void)storeAccessToken:(NSString *)accessToken {
    twScreenName=[[[[accessToken componentsSeparatedByString:@"&"] lastObject]componentsSeparatedByString:@"="]lastObject];
    continueButtonRef.hidden=NO;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"SavedAccessHTTPBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSString *)loadAccessToken {
    NSLog(@"access token: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"]);
    twScreenName=[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
    twScreenName=[[[[twScreenName componentsSeparatedByString:@"&"] lastObject] componentsSeparatedByString:@"="] lastObject];
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark - Instagram delegate
-(void)igDidLogin {
    continueButtonRef.hidden=NO;
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"IGAccessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    //-Get profile here
    NSString *methodName=[NSString stringWithFormat:@"users/self?access_token=%@",appDelegate.instagram.accessToken];
    [appDelegate.instagram requestWithMethodName:methodName params:nil httpMethod:@"GET" delegate:self];
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
    
}

-(void)igDidLogout {
    NSLog(@"did logout");
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"IGAccessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"invalidated");
}

#pragma mark - IGRequestDelegate
- (void)request:(IGRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDict=[result objectForKey:@"data"];
        ARInstagramUser *itUser=[[ARInstagramUser alloc] init];
        itUser.userId=[dataDict objectForKey:@"id"];
        itUser.username=[dataDict objectForKey:@"username"];
        itUser.fullName=[dataDict objectForKey:@"full_name"];
        itUser.accessToken=appDelegate.instagram.accessToken;
        itUser.profilePicture=[dataDict objectForKey:@"profile_picture"];
        itUser.numberFollowers=[[[dataDict objectForKey:@"counts"] objectForKey:@"followed_by"] integerValue];
        itUser.numberFollowing=[[[dataDict objectForKey:@"counts"] objectForKey:@"follows"] integerValue];
        [ARInstagramUser wirteDataToFile:itUser];
        
        NSString *itBtTitle=[NSString stringWithFormat:@"Logged in as %@",itUser.username];
        [itButtonRef setTitle:itBtTitle forState:UIControlStateNormal];
    }
}

#pragma mark - Override method
- (void)confirmButtonTappedAtIndex:(NSInteger)index {
    if (index==1) {
        if ([interacting_button isEqualToString:@"facebook"]) {
            [FacebookHelper sharedInstance].fbDelegate=self;
            [[FacebookHelper sharedInstance] doLogout];
            [fbButtonRef setTitle:@"Add a Facebook account" forState:UIControlStateNormal];
        } else if([interacting_button isEqualToString:@"twitter"]) {
            [[FHSTwitterEngine sharedEngine] clearAccessToken];
            [twButtonRef setTitle:@"Add a Twitter account" forState:UIControlStateNormal];
        } else if ([interacting_button isEqualToString:@"instagram"]) {
            [appDelegate.instagram logout];
            [itButtonRef setTitle:@"Add an Instagram account" forState:UIControlStateNormal];
        }
    }
}

@end
