//
//  SHComposerVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHComposerVC.h"
#import "FacebookHelper.h"
#import "FHSTwitterEngine.h"
#import "ARTwitterUser.h"
#import "ARFacebookUser.h"

@interface SHComposerVC ()<UITextViewDelegate,FHSTwitterEngineAccessTokenDelegate,FacebookHelperDelegate> {
    NSString *inputText;
    BOOL fFacebookSelected;
    BOOL fTwitterSelected;
    BOOL fInstagramSelected;
    NSString *twScreenName;
    UIButton *buttonREF;
}

@end

@implementation SHComposerVC

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
    self.title=@"Composer";
    self.view.backgroundColor=[UIColor clearColor];
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    UIImageView *bgView=[[UIImageView alloc] initWithImage:self.backgroundImage];
    bgView.frame=self.view.bounds;
    [self.view addSubview:bgView];
    [self.view sendSubviewToBack:bgView];
    fFacebookSelected=NO;
    fTwitterSelected=NO;
    fInstagramSelected=NO;
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

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postTapped:(id)sender {
    if (fFacebookSelected || fTwitterSelected || fInstagramSelected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPostWithTextContent:facebook:twitter:instagram:)]) {
            [self.delegate didPostWithTextContent:inputText facebook:fFacebookSelected twitter:fTwitterSelected instagram:fInstagramSelected];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self showAlertMessage:@"Please select at least a social network"];
    }
}
- (IBAction)btnFacebookTapped:(id)sender {
    UIButton *actionAuthor=(UIButton*)sender;
    buttonREF=actionAuthor;
    if (fFacebookSelected) {
        fFacebookSelected=NO;
        [actionAuthor setImage:[UIImage imageNamed:@"facebook_disable.png"] forState:UIControlStateNormal];
    } else {
        if (![[FacebookHelper sharedInstance] isUserAuthenticated]) {
            [FacebookHelper sharedInstance].fbDelegate=self;
            [[FacebookHelper sharedInstance] doLogin];
        } else {
            fFacebookSelected=YES;
            [actionAuthor setImage:[UIImage imageNamed:@"facebook_enable.png"] forState:UIControlStateNormal];
        }
    }
}
- (IBAction)btnTwitterTapped:(id)sender {
    UIButton *actionAuthor=(UIButton*)sender;
    if (fTwitterSelected) {
        fTwitterSelected=NO;
        [actionAuthor setImage:[UIImage imageNamed:@"twitter_disable.png"] forState:UIControlStateNormal];
    } else {
        if (![[FHSTwitterEngine sharedEngine] isAuthorized]) {
            UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
                [self dismissViewControllerAnimated:YES completion:nil];
                fTwitterSelected=YES;
                [actionAuthor setImage:[UIImage imageNamed:@"twitter_enable.png"] forState:UIControlStateNormal];
                //-get profile info here
                id returnJson=[[FHSTwitterEngine sharedEngine] getUserInfo:twScreenName];
                if ([returnJson isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDict=(NSDictionary*)returnJson;
                    ARTwitterUser *twUser=[[ARTwitterUser alloc] init];
                    twUser.userId=[dataDict objectForKey:@"id_str"];
                    twUser.username=[dataDict objectForKey:@"name"];
                    twUser.screenName=[dataDict objectForKey:@"screen_name"];
                    twUser.accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
//                    twUser.profilePicture=[dataDict objectForKey:@"profile_image_url"];
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
        } else {
            fTwitterSelected=YES;
            [actionAuthor setImage:[UIImage imageNamed:@"twitter_enable.png"] forState:UIControlStateNormal];
        }
    }
}
- (IBAction)btnInstagramTapped:(id)sender {
//    UIButton *actionAuthor=(UIButton*)sender;
//    if (fInstagramSelected) {
        fInstagramSelected=NO;
//        [actionAuthor setImage:[UIImage imageNamed:@"insta_disable.png"] forState:UIControlStateNormal];
//    } else {
//        fInstagramSelected=YES;
//        [actionAuthor setImage:[UIImage imageNamed:@"insta_enable.png"] forState:UIControlStateNormal];
//    }
}

- (void)textViewDidChange:(UITextView *)textView {
    inputText=textView.text;
}

#pragma mark - Twitter Oauth delegate
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"SavedAccessHTTPBody"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    twScreenName=[[[[accessToken componentsSeparatedByString:@"&"] lastObject]componentsSeparatedByString:@"="]lastObject];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark - FacebookHelperDelegate
- (void)userDidLogin:(NSDictionary *)dic {
    fFacebookSelected=YES;
    [buttonREF setImage:[UIImage imageNamed:@"facebook_enable.png"] forState:UIControlStateNormal];
    [FacebookHelper sharedInstance].fbDelegate=self;
    [[FacebookHelper sharedInstance] getProfileMe];
}

- (void)userDidLogout:(NSDictionary *)dic {
    fFacebookSelected=NO;
}


@end
