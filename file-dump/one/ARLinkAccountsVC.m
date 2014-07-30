//
//  ARLinkAccountsVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARLinkAccountsVC.h"
#import "FacebookHelper.h"
#import "ARAppDelegate.h"
#import "FHSTwitterEngine.h"
#import "SHConstant.h"
#import "ARTwitterUser.h"
#import "ARInstagramUser.h"

extern bool fAccountsHasChanged;

@interface ARLinkAccountsVC ()<FacebookHelperDelegate,FHSTwitterEngineAccessTokenDelegate,IGSessionDelegate,IGRequestDelegate> {
    UIButton *twitterBtnRef;
    NSString *twScreenName;
}

@end

@implementation ARLinkAccountsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"Link";
    // Do any additional setup after loading the view.
    
    
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"IGAccessToken"];
    appDelegate.instagram.sessionDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    //-adjust UI here
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        //-change image
        [self.fbBtn setImage:[UIImage imageNamed:@"connect-with-facebook-label"] forState:UIControlStateNormal];
    } else {
        [self.fbBtn setImage:[UIImage imageNamed:@"connected-with-facebook-label"] forState:UIControlStateNormal];
    }
    
    if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
        [self.twitterBtn setImage:[UIImage imageNamed:@"connect-with-twitter-label"] forState:UIControlStateNormal];
    } else {
        [self.twitterBtn setImage:[UIImage imageNamed:@"connected-with-twitter-label"] forState:UIControlStateNormal];
    }
    
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.instagram isSessionValid]) {
        [self.instagramBtn setImage:[UIImage imageNamed:@"connect-with-instagram-label"] forState:UIControlStateNormal];
    } else {
        [self.instagramBtn setImage:[UIImage imageNamed:@"connected-with-instagram-label"] forState:UIControlStateNormal];
    }
    
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]||[appDelegate.instagram isSessionValid]||[[FHSTwitterEngine sharedEngine] isAuthorized]) {
        self.navigationItem.rightBarButtonItem.enabled=YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled=NO;
    }
    
    //-for instagram handling
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

- (IBAction)facebookTapped:(id)sender {
    if (![[FacebookHelper sharedInstance] isUserAuthenticated]) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] doLogin];
    }
}

- (IBAction)twitterTapped:(id)sender {
    //-for twitter handling
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:@"F2UuKjSPrf0KAXH66naiww" andSecret:@"5D78724kzHm83WuQo2ynfiBI2aW4MlO6QMrnlzON5c"];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    
    if (![[FHSTwitterEngine sharedEngine] isAuthorized]) {
        [self loginOAuth];
    }
}

- (IBAction)instagramTapped:(id)sender {
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.instagram.sessionDelegate=self;
    if (![appDelegate.instagram isSessionValid]) {
        [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
    }
}
- (IBAction)rightBarBtnTapped:(id)sender {
    //-enter feed screen here
    [self enterApp];
}

- (IBAction)leftBarBtnTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loginOAuth {
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        fAccountsHasChanged=YES;
        NSLog(success?@"Login Success":@"Oh no! Authentication Failure.");
        [self.twitterBtn setImage:[UIImage imageNamed:@"connected-with-twitter-label"] forState:UIControlStateNormal];
        
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
            twUser.coverPhoto=[dataDict objectForKey:@"profile_banner_url"];
            twUser.numberFollowers=[[dataDict objectForKey:@"followers_count"] integerValue];
            twUser.numberFollowing=[[dataDict objectForKey:@"friends_count"] integerValue];
            twUser.description=[dataDict objectForKey:@"description"];
            twUser.location=[dataDict objectForKey:@"location"];
            twUser.tweetsCount = [[dataDict objectForKey:@"statuses_count"] integerValue];
            
            twUser.profilePicture  = [[FHSTwitterEngine sharedEngine] getProfileImageURLStringForUsername:twUser.username andSize:FHSTwitterEngineImageSizeBigger];
            
            [ARTwitterUser wirteDataToFile:twUser];
            
            self.navigationItem.rightBarButtonItem.enabled=YES;
        }
    }];
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)enterApp {
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    UITabBarController *tabbarVC=[self.storyboard instantiateViewControllerWithIdentifier:@"tabbarVC"];
    appDelegate.window.rootViewController=tabbarVC;

//    [UIView transitionWithView:self.view
//                      duration:1.0f
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^(void) {
//                        appDelegate.window.rootViewController=tabbarVC;
//                    } completion:NULL];

}

#pragma mark - FacebookHelperDelegate
- (void)userDidLogin:(NSDictionary *)dic {
    fAccountsHasChanged=YES;
    [self.fbBtn setImage:[UIImage imageNamed:@"connected-with-facebook-label"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem.enabled=YES;
    [[FacebookHelper sharedInstance] getProfileMe];
}

- (void)userDidLogout:(NSDictionary *)dic {

}

- (void)userDidCancelLogin:(NSDictionary *)dic {

}

#pragma mark - Twitter Oauth delegate
- (void)storeAccessToken:(NSString *)accessToken {
    twScreenName=[[[[accessToken componentsSeparatedByString:@"&"] lastObject]componentsSeparatedByString:@"="]lastObject];
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
    fAccountsHasChanged=YES;
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"IGAccessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [self.instagramBtn setImage:[UIImage imageNamed:@"connected-with-instagram-label"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem.enabled=YES;
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
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
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
        itUser.bio=[dataDict objectForKey:@"bio"];
        itUser.postsCount=[[[dataDict objectForKey:@"counts"] objectForKey:@"media"] integerValue];
        [ARInstagramUser wirteDataToFile:itUser];
    }
}

@end