//
//  ARAccountManagerVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARAccountManagerVC.h"
#import "FacebookHelper.h"
#import "ARAppDelegate.h"
#import "FHSTwitterEngine.h"
#import "AROneProfileVC.h"
#import "ARInstagramUser.h"
#import "ARTwitterUser.h"

#define kCellTitle          @"CELL_TITLE_KEY"
#define kCellIcon           @"CELL_ICON_KEY"

@interface ARAccountManagerVC ()<UITableViewDelegate,UITableViewDataSource,FacebookHelperDelegate,IGSessionDelegate,IGRequestDelegate,FHSTwitterEngineAccessTokenDelegate>
{
    NSMutableArray *tableData;
    NSInteger accountMode;
    NSString *twScreenName;
}
@end

@implementation ARAccountManagerVC

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
    
    [self renderNavigationBarWithTitle:@"MANAGE ACCOUNTS"];
    
    //-data
    accountMode=1;
}

- (void)viewDidAppear:(BOOL)animated {
    [self refreshTableViewData];
    [self.accManageTbView reloadData];
}

- (void)refreshTableViewData {
    ARAppDelegate *appDelegate=(ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!tableData) {
        tableData=[[NSMutableArray alloc] init];
    } else {
        [tableData removeAllObjects];
    }
    NSMutableDictionary *facebookDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[FacebookHelper sharedInstance] isUserAuthenticated]?@"facebook_enable.png":@"facebook_disable.png",kCellIcon,@"Facebook",kCellTitle, nil];
    [[FHSTwitterEngine sharedEngine] permanentlySetConsumerKey:@"F2UuKjSPrf0KAXH66naiww" andSecret:@"5D78724kzHm83WuQo2ynfiBI2aW4MlO6QMrnlzON5c"];
    [[FHSTwitterEngine sharedEngine] setDelegate:self];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    NSMutableDictionary *twitterDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:FHSTwitterEngine.sharedEngine.isAuthorized?@"twitter_enable.png":@"twitter_disable.png",kCellIcon,@"Twitter",kCellTitle, nil];
    NSMutableDictionary *instaDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:appDelegate.instagram.isSessionValid?@"insta_enable.png":@"insta_disable.png",kCellIcon,@"Instagram",kCellTitle, nil];
    
    [tableData addObject:facebookDict];
    [tableData addObject:twitterDict];
    [tableData addObject:instaDict];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *naVC=(UINavigationController*)(segue.destinationViewController);
    AROneProfileVC *oneProfileVC=[[naVC viewControllers] firstObject];
    oneProfileVC.accountMode=accountMode;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AccountManagerCell"];
    NSDictionary *cellDict=[tableData objectAtIndex:indexPath.row];
    cell.textLabel.text=[cellDict objectForKey:kCellTitle];
    cell.imageView.image=[UIImage imageNamed:[cellDict objectForKey:kCellIcon]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ARAppDelegate *appDelegate=(ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (indexPath.row) {
        case 0:
            //-Facebook case
            accountMode=1;
            if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
                [self performSegueWithIdentifier:@"ShowOneProfile" sender:self];
            } else {
                [FacebookHelper sharedInstance].fbDelegate=self;
                [[FacebookHelper sharedInstance] doLogin];
            }
            
            break;
        case 1:
            //-Twitter case
            accountMode=2;
            if (FHSTwitterEngine.sharedEngine.isAuthorized) {
                [self performSegueWithIdentifier:@"ShowOneProfile" sender:self];
            } else {
                UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.accManageTbView reloadData];
                    //-get profile info here
                    id returnJson=[[FHSTwitterEngine sharedEngine] getUserInfo:twScreenName];
                    if ([returnJson isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dataDict=(NSDictionary*)returnJson;
                        ARTwitterUser *twUser=[[ARTwitterUser alloc] init];
                        twUser.userId=[dataDict objectForKey:@"id_str"];
                        twUser.username=[dataDict objectForKey:@"name"];
                        twUser.screenName=[dataDict objectForKey:@"screen_name"];
                        twUser.accessToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"SavedAccessHTTPBody"];
//                        twUser.profilePicture=[dataDict objectForKey:@"profile_image_url"];
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
            
            break;
        case 2:
            //-Instagram case
            accountMode=3;
            if (appDelegate.instagram.isSessionValid) {
                [self performSegueWithIdentifier:@"ShowOneProfile" sender:self];
            } else {
                [appDelegate.instagram setSessionDelegate:self];
                [appDelegate.instagram authorize:[NSArray arrayWithObjects:@"comments", @"likes", nil]];
            }
            
            break;
        default:
            accountMode=1;
            [self performSegueWithIdentifier:@"ShowOneProfile" sender:self];
            break;
    }
}

#pragma mark - FacebookHelperDelegate
- (void)userDidLogin:(NSDictionary *)dic {
    [self refreshTableViewData];
    [self.accManageTbView reloadData];
    
    [FacebookHelper sharedInstance].fbDelegate=self;
    [[FacebookHelper sharedInstance] getProfileMe];
}

- (void)userDidLogout:(NSDictionary *)dic {
    [self.accManageTbView reloadData];
}

#pragma mark - Instagram
-(void)igDidLogin {
    ARAppDelegate *appDelegate=(ARAppDelegate *)[[UIApplication sharedApplication] delegate];
    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"IGAccessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [self refreshTableViewData];
    [self.accManageTbView reloadData];
    
    //-Get profile here
    NSString *methodName=[NSString stringWithFormat:@"users/self?access_token=%@",appDelegate.instagram.accessToken];
    [appDelegate.instagram requestWithMethodName:methodName params:nil httpMethod:@"GET" delegate:self];
}

-(void)igDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
    
}

-(void)igDidLogout {
    // remove the accessToken
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"IGAccessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)igSessionInvalidated {
    NSLog(@"invalidated");
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

#pragma mark - IGRequestDelegate
- (void)request:(IGRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDict=[result objectForKey:@"data"];
        ARInstagramUser *itUser=[[ARInstagramUser alloc] init];
        itUser.userId=[dataDict objectForKey:@"id"];
        itUser.username=[dataDict objectForKey:@"username"];
        itUser.fullName=[dataDict objectForKey:@"full_name"];
        ARAppDelegate *appDelegate=(ARAppDelegate *)[[UIApplication sharedApplication] delegate];
        itUser.accessToken=appDelegate.instagram.accessToken;
        itUser.profilePicture=[dataDict objectForKeyedSubscript:@"profile_picture"];
        itUser.numberFollowers=[[[dataDict objectForKey:@"counts"] objectForKey:@"followed_by"] integerValue];
        itUser.numberFollowing=[[[dataDict objectForKey:@"counts"] objectForKey:@"follows"] integerValue];
        [ARInstagramUser wirteDataToFile:itUser];
    }
}

@end
