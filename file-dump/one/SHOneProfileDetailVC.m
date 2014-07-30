//
//  SHOneProfileDetailVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHOneProfileDetailVC.h"
#import "BBPost.h"
#import "FacebookHelper.h"
#import "UIImageView+WebCache.h"
#import "ARInstagramUser.h"
#import "ARTwitterUser.h"
#import "ARFacebookUser.h"
#import "FHSTwitterEngine.h"
#import "ARAppDelegate.h"
#import "WFConfigs.h"
#import "UIImageView+AFNetworking.h"
#import "SHConstant.h"
#import "SHFBNormalFeedCell.h"
#import "SHFBImageFeedCell.h"
#import "SHExpandTWFeedCell.h"
#import "SHExpandImgeTWFeedCell.h"
#import "SHITImageFeedCell.h"

#define kInstagramFeedLimitConst                    @"10"
#define kFBProfilePicURL @"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1"
#define kStandardCellTextWidth                      246
#define kStandardImageCellImageViewHeight           154
#define kInstagramImageCellImageViewHeight          246

@interface SHOneProfileDetailVC ()<IGRequestDelegate, FacebookHelperDelegate, SHFBNormalFeedCellDelegate, SHFBImageFeedCellDelegate, SHExpandTWFeedCellDelegate, SHExpandImageTWFeedCellDelegate, SHITImageFeedCellDelegate> {
    UIImageView *coverPhoto;
    UIImageView *profilePhoto;
    UILabel *userName;
    UILabel *following;
    UILabel *follower;
    NSMutableArray *facebookDataArray;
    NSMutableArray *twitterDataArray;
    NSMutableArray *instagramDataArray;
    NSInteger selectedIndex;
    NSInteger pageNo;
    NSString *lastTwitterPostId;
    NSString *lastInstagramPostId;
}

@end

@implementation SHOneProfileDetailVC

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
    
    facebookDataArray=[[NSMutableArray alloc] init];
    twitterDataArray=[[NSMutableArray alloc] init];
    instagramDataArray=[[NSMutableArray alloc] init];
    
    selectedIndex = -1;
    
    self.profileTbView.tableHeaderView=self.containerView;
    
    [self updateView];
    [self LoadProfile];
    [self refreshTableViewData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.socialType == 1) {
        return facebookDataArray.count;
    } else if (self.socialType == 2) {
        return twitterDataArray.count;
    } else {
        return instagramDataArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FBNormalCell=@"FBNormalCell";
    static NSString *FBImageCell=@"FBImageCell";
    static NSString *TWExpandCell=@"SHExpandTWFeedCell";
    static NSString *TWExpandImageCell=@"SHExpandImgeTWFeedCell";
    static NSString *ITImageExpandCell=@"SHITImageFeedCell";
    
    //-currently, only facebook posts are taken into account
    BBPost *aPost;
    if (self.socialType == 1) {
        aPost=[facebookDataArray objectAtIndex:indexPath.row];
    } else if (self.socialType == 2) {
        aPost=[twitterDataArray objectAtIndex:indexPath.row];
    } else {
        aPost=[instagramDataArray objectAtIndex:indexPath.row];
    }
    
    if (aPost.socialType==FACEBOOK_POST) {
        //-Facebook mode
        //        BBPost *aPost=[[SHAppDelegate application].facebookDataArray objectAtIndex:indexPath.row];
        if (aPost.postType==FBPlainStatus) {
            SHFBNormalFeedCell *cell1=[tableView dequeueReusableCellWithIdentifier:FBNormalCell];
            if (cell1==nil) {
                if(selectedIndex == indexPath.row) {
                    cell1 = [[SHFBNormalFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBExpandedFeedCell"];
                    cell1.contentView.backgroundColor = [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
                } else {
                    cell1=[[SHFBNormalFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBNormalFeedCell"];
                }
                cell1.fbDelegate=self;
            }
            [cell1 fillData:aPost];
            [cell1 setSelectedState:NO];
            
            return cell1;
        } else {
            SHFBImageFeedCell *cell2=[tableView dequeueReusableCellWithIdentifier:FBImageCell];
            if (cell2==nil) {
                cell2=[[SHFBImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBImageCell];
                if(selectedIndex == indexPath.row) {
                    cell2 = [[SHFBImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBImageExpandedFeedCell"];
                    cell2.contentView.backgroundColor = [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
                } else {
                    cell2=[[SHFBImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBImageFeedCell"];
                }
                cell2.fbDelegate=self;
            }
            [cell2 fillData:aPost];
            [cell2 setSelectedState:NO];
            
            return cell2;
        }
    } else if (aPost.socialType==TWITTER_POST) {
        //-Twitter mode
        if (aPost.pictureLink.length>2) {
            SHExpandImgeTWFeedCell *cell3=[tableView dequeueReusableCellWithIdentifier:TWExpandImageCell];
            if (cell3==nil) {
                if(selectedIndex == indexPath.row) {
                    cell3=[[SHExpandImgeTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHImageExpandedTWFeedCell"];
                    cell3.contentView.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
                } else {
                    cell3=[[SHExpandImgeTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandImgeTWFeedCell"];
                }
                cell3.twDelegate=self;
            }
            [cell3 fillData:aPost];
            [cell3 setSelectedState:NO];
            
            return cell3;
        } else {
            SHExpandTWFeedCell *cell4=[tableView dequeueReusableCellWithIdentifier:TWExpandCell];
            if (cell4==nil) {
                //                cell4 = [[[NSBundle mainBundle] loadNibNamed:@"SHExpandTWFeedCell" owner:self options:nil] objectAtIndex:0];
                if(selectedIndex == indexPath.row) {
                    cell4=[[SHExpandTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandedTWFeedCell"];
                    cell4.contentView.backgroundColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
                } else {
                    cell4=[[SHExpandTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandTWFeedCell"];
                }
                cell4.twDelegate=self;
            }
            [cell4 fillData:aPost];
            [cell4 setSelectedState:NO];
            
            return cell4;
        }
    } else {
        //-Instagram image cell
        SHITImageFeedCell *cell5=[tableView dequeueReusableCellWithIdentifier:ITImageExpandCell];
        if (cell5==nil) {
            if(selectedIndex == indexPath.row) {
                cell5=[[SHITImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHITImageExpandedFeedCell"];
                cell5.contentView.backgroundColor = [UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f];
            } else {
                cell5=[[SHITImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHITImageFeedCell"];
            }
            cell5.itDelegate=self;
        }
        [cell5 fillData:aPost];
        [cell5 setSelectedState:NO];
        
        return cell5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBPost *aPost;
    if (self.socialType == 1) {
        aPost=[facebookDataArray objectAtIndex:indexPath.row];
    } else if (self.socialType == 2) {
        aPost=[twitterDataArray objectAtIndex:indexPath.row];
    } else {
        aPost=[instagramDataArray objectAtIndex:indexPath.row];
    }
    
    CGSize size = [aPost.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(kStandardCellTextWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat textHeight=size.height;
    if (aPost.socialType==FACEBOOK_POST) {
        //-Facebook
        if (aPost.postType==FBPlainStatus) {
            if (indexPath.row!=selectedIndex) {
                return (textHeight+83); // 63
            } else {
                return (textHeight+83+51);
            }
        } else {
            if (indexPath.row!=selectedIndex) {
                return textHeight+kStandardImageCellImageViewHeight+93; // 173
            } else {
                return textHeight+kStandardImageCellImageViewHeight+83+51;
            }
        }
    } else if (aPost.socialType==TWITTER_POST) {
        //-Twitter
        if (aPost.pictureLink.length>2) {
            if (indexPath.row!=selectedIndex) {
                return textHeight+kStandardImageCellImageViewHeight+90;// Twitter image case
            } else {
                return textHeight+kStandardImageCellImageViewHeight+80+51;
            }
        } else {
            if (indexPath.row!=selectedIndex) {
                return textHeight+74;
            } else {
                return textHeight+74+51;
            }
        }
    } else {
        // Instagram
        if (indexPath.row!=selectedIndex) {
            return textHeight+kInstagramImageCellImageViewHeight+90;// Twitter image case
        } else {
            return textHeight+kInstagramImageCellImageViewHeight+80+51;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex = -1;
}

#pragma mark - utilities method
- (void)LoadProfile{
    if (self.socialType==1) {
        //-Facebook case
//        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover,picture,name,location,link&access_token=%@",self.userBBPost.userId,FBSession.activeSession.accessTokenData.accessToken];
//        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//         {
//             NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//             //-cover image
//             [coverPhoto setImageWithURL:[NSURL URLWithString:[[JSON objectForKey:@"cover"] objectForKey:@"source"]] placeholderImage:[UIImage imageNamed:@"shadow.png"]];
//             //-profile image
//             NSString *smallProfilePicLink = [[[JSON objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
//             smallProfilePicLink = [smallProfilePicLink stringByReplacingOccurrencesOfString:@"_q" withString:@"_n"];
//             NSURL *profileURL = [NSURL URLWithString:smallProfilePicLink];
//             [profilePhoto setImageWithURL:profileURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
//             //-full name
//             userName.text=[JSON objectForKey:@"name"];
//         }];
        
//        [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover,name,location,link,picture&type=large&access_token=%@",[[FacebookHelper sharedInstance] getMeInfo].userId,FBSession.activeSession.accessTokenData.accessToken];
        
        // https://graph.facebook.com/%@picture?type=large
        
//        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FBAccessTokenKey];
//        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"https://graph.facebook.com/v1.0/%@/comments?&access_token=%@", postId, accessToken] parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error ) {
//            NSLog(@"%@", result);
//        }];
        
//        [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@", self.userBBPost.userId] parameters:nil HTTPMethod:@"GET" completionHandler:^(
//                FBRequestConnection *connection, id result, NSError *error ) {
//                                  /* handle the result */
//            NSLog(@"%@", result);
//            self.nameLabel.text = [result valueForKey:@"name"];
//        }];
        
        ///-------------------------------------
        
         NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESSTOKEN]; // FBSession.activeSession.accessTokenData.accessToken
        
        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover,name,location,link,picture&type=large&access_token=%@",self.userBBPost.userId,fbAccessToken];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 NSString *facebookPictureUrl = [NSString stringWithFormat:kFBProfilePicURL, self.userBBPost.userId];
                 
                 [self.profileImageView setImageWithURL:[NSURL URLWithString:facebookPictureUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                 //-full name
                 self.nameLabel.text=[JSON objectForKey:@"name"];
//                 self.designationLabel.text = [[WFFacebookUser sharedInstance] worksAt];
//                 self.aboutMeLabel.text = [[WFFacebookUser sharedInstance] studiedAt];
//                 self.fbFriendsCountLabel.text = [NSString stringWithFormat:@"%d Friends", [[WFFacebookUser sharedInstance] friendsCount]];
             });
         }];
        
        ////---------------------------------------------
        
    } else if (self.socialType==2) {
        //-twitter case
        //-get profile info here
        
        id returnJson;
        if(self.userBBPost != nil) {
            returnJson=[[FHSTwitterEngine sharedEngine] getUserInfoById:self.userBBPost.userId];
        } else {
            returnJson=[[FHSTwitterEngine sharedEngine] getUserInfo:self.screenName];
        }
        
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
            
            [self.profileImageView setImageWithURL:[NSURL URLWithString:twUser.profilePicture] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            [coverPhoto setImageWithURL:[NSURL URLWithString:twUser.coverPhoto] placeholderImage:[UIImage imageNamed:@"shadow.png"]];
            
            self.nameLabel.text=twUser.screenName;
            self.designationLabel.text = twUser.description;
            self.aboutMeLabel.text = twUser.username;
            
            double followers = twUser.numberFollowers;
            float followersCount;
            if(followers >= 1000000) {
                followersCount = followers/1000000;
                self.followersCountLabel.text=[NSString stringWithFormat:@"%.1f m",followersCount];
            } else if(followers >= 1000) {
                followersCount = followers/1000;
                self.followersCountLabel.text=[NSString stringWithFormat:@"%.1f k",followersCount];
            } else {
                self.followersCountLabel.text=[NSString stringWithFormat:@"%d",twUser.numberFollowers];
            }
            
            double follo = twUser.numberFollowing;
            float followingCount;
            if(follo >= 1000000) {
                followingCount = follo/1000000;
                self.followingCountLabel.text=[NSString stringWithFormat:@"%.1f m",followingCount];
            } else if(follo >= 1000) {
                followingCount = follo/1000;
                self.followingCountLabel.text=[NSString stringWithFormat:@"%.1f k",followingCount];
            } else {
                self.followingCountLabel.text=[NSString stringWithFormat:@"%d",twUser.numberFollowing];
            }
            
            self.postsOrTweetsCountLabel.text = [NSString stringWithFormat:@"%d",twUser.tweetsCount];
            self.postsOrTweetsLabel.text = @"Tweets";
        }
    } else if (self.socialType==3) {
        //-instagram case
        //-Get profile here
        ARAppDelegate *appDelegate=(ARAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *methodName=[NSString stringWithFormat:@"users/%@?access_token=%@",self.userBBPost.userId,appDelegate.instagram.accessToken];
        
//        NSString *methodName=[NSString stringWithFormat:@"users/%@/media/recent?access_token=%@",self.userBBPost.userId,appDelegate.instagram.accessToken];
        [appDelegate.instagram requestWithMethodName:methodName params:nil httpMethod:@"GET" delegate:self];
        
//        NSString *methodName=[NSString stringWithFormat:@"users/self/feed?access_token=%@",[[SHAppDelegate application].instagram accessToken]];
//        NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:kInstagramFeedLimitConst,@"count", nil];
//        [[SHAppDelegate application].instagram requestWithMethodName:methodName params:params httpMethod:@"GET" delegate:self];
    }
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

#pragma mark - IGRequestDelegate
- (void)request:(IGRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSDictionary class]]) {
        ARAppDelegate *appDelegate=(ARAppDelegate *)[[UIApplication sharedApplication] delegate];
        if([[result objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dataDict=[result objectForKey:@"data"];
            ARInstagramUser *itUser=[[ARInstagramUser alloc] init];
            itUser.userId=[dataDict objectForKey:@"id"];
            itUser.username=[dataDict objectForKey:@"username"];
            itUser.fullName=[dataDict objectForKey:@"full_name"];
            itUser.accessToken=appDelegate.instagram.accessToken;
            itUser.profilePicture=[dataDict objectForKey:@"profile_picture"];
            itUser.numberFollowers=[[[dataDict objectForKey:@"counts"] objectForKey:@"followed_by"] integerValue];
            itUser.numberFollowing=[[[dataDict objectForKey:@"counts"] objectForKey:@"follows"] integerValue];
            itUser.bio = [dataDict objectForKey:@"bio"];
            itUser.postsCount = [[[dataDict objectForKey:@"counts"] objectForKey:@"media"] integerValue];
            
            [self.profileImageView setImageWithURL:[NSURL URLWithString:itUser.profilePicture] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            self.nameLabel.text=itUser.fullName;
            self.designationLabel.text = itUser.bio;
            self.aboutMeLabel.text = itUser.username;
            self.followersCountLabel.text=[NSString stringWithFormat:@"%d",itUser.numberFollowers];
            self.followingCountLabel.text=[NSString stringWithFormat:@"%d",itUser.numberFollowing];
            self.postsOrTweetsCountLabel.text = [NSString stringWithFormat:@"%d",itUser.postsCount];
            self.postsOrTweetsLabel.text = @"Posts";
        } else {
            NSArray *dataArray=[result objectForKey:@"data"];
            for (NSDictionary *aDict in dataArray) {
                BBPost *aPost=[[BBPost alloc] initWithInstagramDic:aDict];
                if (aPost!=nil) {
                    [instagramDataArray addObject:aPost];
                    lastInstagramPostId = aPost.postId;
                }
            }
        }
    }
    self.profileTbView.pullTableIsRefreshing = NO;
    self.profileTbView.pullTableIsLoadingMore = NO;
    [self.profileTbView reloadData];
}

- (IBAction)tappedCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateView {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.profileImageView.layer.cornerRadius=41;
    self.profileImageView.layer.borderWidth=2;
    self.profileImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.profileImageView.clipsToBounds=YES;
    
    if (self.socialType == 1) {
        [self.fbFriendsCountLabel setHidden:FALSE];
        [self.butttonsContainerView setHidden:TRUE];
        [self.containerView setBackgroundColor:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f]];
        
    } else if (self.socialType == 2) {
        [self.fbFriendsCountLabel setHidden:TRUE];
        [self.butttonsContainerView setHidden:FALSE];
        self.postsOrTweetsLabel.text = @"Tweets";
        [self.containerView setBackgroundColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f]];
        [self.butttonsContainerView setBackgroundColor:[UIColor colorWithRed:79/255.0f green:160/255.0f blue:221/255.0f alpha:1.0f]];
    } else {
        [self.fbFriendsCountLabel setHidden:TRUE];
        [self.butttonsContainerView setHidden:FALSE];
        self.postsOrTweetsLabel.text = @"Posts";
        [self.containerView setBackgroundColor:[UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f]];
        [self.butttonsContainerView setBackgroundColor:[UIColor colorWithRed:51/255.0f green:104/255.0f blue:148/255.0f alpha:1.0f]];
    }
}

- (void)refreshTableViewData {
    [facebookDataArray removeAllObjects];
    [twitterDataArray removeAllObjects];
    [instagramDataArray removeAllObjects];
    
    if (self.socialType==1) {
        //-facebook posts
        pageNo = 0;
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getUserNewsFeed:self.userBBPost.userId limit:kFeedsLimit offset:kFeedsLimit*pageNo];
    } else if (self.socialType==2) {
        //-twitter posts
        lastTwitterPostId = @"";
        [self getTwitterTimeline];
    } else {
        //-instagram posts
        lastInstagramPostId = @"";
        [self getInstagramFeed];
    }
}

- (void)getInstagramFeed {
    if ([[ARAppDelegate application].instagram isSessionValid]) {
        NSString *methodName=[NSString stringWithFormat:@"users/%@/media/recent?access_token=%@", self.userBBPost.userId, [[ARAppDelegate application].instagram accessToken]];
        NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:kInstagramFeedLimitConst,@"count",lastInstagramPostId,@"max_id", nil];
        [[ARAppDelegate application].instagram requestWithMethodName:methodName params:params httpMethod:@"GET" delegate:self];
    }
}

- (void)getTwitterTimeline {
    //-Load newsfeed for twitter
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //-Fetch home timeline
//            id result=[[FHSTwitterEngine sharedEngine] getHomeTimelineSinceID:@"" count:10];
//            id result=[[FHSTwitterEngine sharedEngine] getTimelineForUser:self.userBBPost.userId isID:TRUE count:10];
            
            id result;
            if(self.userBBPost != nil) {
                result=[[FHSTwitterEngine sharedEngine] getTimelineForUser:self.userBBPost.userId isID:TRUE count:kFeedsLimit sinceID:@"" maxID:lastTwitterPostId];
            } else {
                result=[[FHSTwitterEngine sharedEngine] getTimelineForUser:self.screenName isID:FALSE count:kFeedsLimit sinceID:@"" maxID:lastTwitterPostId];
            }
            
            if ([result isKindOfClass:[NSArray class]]) {
                for (NSDictionary *postDict in (NSArray*)result) {
                    BBPost *aPost=[[BBPost alloc] initWithTwitterDic:postDict];
                    [twitterDataArray addObject:aPost];
                    lastTwitterPostId = aPost.postId;
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.profileTbView.pullTableIsRefreshing = NO;
                    self.profileTbView.pullTableIsLoadingMore = NO;
                    [self.profileTbView reloadData];
                });
            } else if ([result isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Dictionary class");
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                //                [self stopIndicator];
            });
        }
    });
}

#pragma mark - FacebookDelegate

- (void) getNewsFeedDidSuccess:(NSDictionary*)dict {
    //    [self stopIndicator];
    self.profileTbView.pullTableIsRefreshing = NO;
    self.profileTbView.pullTableIsLoadingMore = NO;
    NSArray *dataArray = (NSArray*)[dict objectForKey:@"data"];
    if (dataArray.count>0) {
        pageNo ++;
        for(id dict in dataArray){
            if ([dict isKindOfClass:[NSDictionary class]]) {
                BBPost *bbPost = [[BBPost alloc] initWithJSONDic:dict];
                if ((bbPost.postType != MISC) && bbPost) {
                    [facebookDataArray addObject:bbPost];
                }
            }
        }
        [self.profileTbView reloadData];
    }
}

- (void) getNewsFeedDidFail:(NSError*)error {
    //    [self stopIndicator];
}

#pragma mark - IGRequestDelegate

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(IGRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"did respond");
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"error request: %@",error.description);
    //    [self stopIndicator];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
//- (void)request:(IGRequest *)request didLoad:(id)result {
//    //    [self stopIndicator];
//    NSArray *dataArray=[result objectForKey:@"data"];
//    for (NSDictionary *aDict in dataArray) {
//        BBPost *aPost=[[BBPost alloc] initWithInstagramDic:aDict];
//        if (aPost!=nil) {
//            [instagramDataArray addObject:aPost];
//        }
//    }
//    [self.profileTbView reloadData];
//}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:0.0f];
}

- (void)refreshTable {
    if([ARAppDelegate isNetworkAvailable]) {
        [self LoadProfile];
        [self refreshTableViewData];
    } else {
        self.profileTbView.pullTableIsRefreshing = NO;
    }
}

- (void)loadMoreDataToTable {
    if (self.socialType==1) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getUserNewsFeed:self.userBBPost.userId limit:kFeedsLimit offset:kFeedsLimit*pageNo];
    } else if(self.socialType == 2) {
        [self getTwitterTimeline];
    } else {
        [self getInstagramFeed];
    }
}

@end
