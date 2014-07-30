//
//  ARProfileVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARProfileVC.h"
#import "FacebookHelper.h"
#import "UIImageView+WebCache.h"
#import "ARInstagramUser.h"
#import "ARTwitterUser.h"
#import "BBPost.h"
#import "SHFBNormalFeedCell.h"
#import "SHFBImageFeedCell.h"
#import "FHSTwitterEngine.h"
#import "SHExpandTWFeedCell.h"
#import "SHExpandImgeTWFeedCell.h"
#import "ARAppDelegate.h"
#import "SHITImageFeedCell.h"
#import "UIImageView+AFNetworking.h"
#import "SHConstant.h"

#define kStandardCellHeight                         130
#define kStandardImageCellHeight                    360
#define kExpandHeight                               30
#define kStandardCellPadding                        (30+60)
#define kStandardCellTextWidth                      246
#define kStandardImageCellImageViewHeight           154
#define kInstagramImageCellImageViewHeight          246
#define kInstagramFeedLimitConst                    @"10"
#define kFBProfilePicURL @"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1"

@interface ARProfileVC ()<UITableViewDataSource,FacebookHelperDelegate,IGRequestDelegate, SHFBNormalFeedCellDelegate, SHFBImageFeedCellDelegate, SHExpandTWFeedCellDelegate, SHExpandImageTWFeedCellDelegate, SHITImageFeedCellDelegate> {
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

@implementation ARProfileVC

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
    [self updateView];
    
    self.navigationController.navigationBarHidden = TRUE;
	// Do any additional setup after loading the view.
    facebookDataArray=[[NSMutableArray alloc] init];
    twitterDataArray=[[NSMutableArray alloc] init];
    instagramDataArray=[[NSMutableArray alloc] init];
    selectedIndex=-1;
//    UIViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileTopHeaderVC"];
//    UIView *view=vc.view;
//    view.frame=CGRectMake(0, 0, 320, 265);
    self.profileTbView.tableHeaderView=self.containerView;

    //Fill data if needed
//    coverPhoto=(UIImageView*)[view viewWithTag:1];
//    coverPhoto.clipsToBounds=YES;
//    profilePhoto=(UIImageView*)[view viewWithTag:2];
    self.profileImageView.layer.cornerRadius=41;
    self.profileImageView.layer.borderWidth=2;
    self.profileImageView.layer.borderColor=[UIColor whiteColor].CGColor;
    self.profileImageView.clipsToBounds=YES;
    
    //-get reference to subviews
//    UILabel *description=(UILabel*)[view viewWithTag:4];
//    UIButton *followBtn=(UIButton*)[view viewWithTag:5];
//    UIView *separator=(UIView*)[view viewWithTag:6];
//    following=(UILabel*)[view viewWithTag:7];
//    following.textAlignment=NSTextAlignmentCenter;
//    following.textColor=[UIColor whiteColor];
//    follower=(UILabel*)[view viewWithTag:8];
//    follower.textColor=[UIColor whiteColor];
//    follower.textAlignment=NSTextAlignmentCenter;
    
    //-temporarily hide myself description
//    description.hidden=YES;
    
//    if (self.socialAccountMode==1) {
//        follower.hidden=YES;
//        following.hidden=YES;
//        separator.hidden=YES;
//        followBtn.hidden=YES;
//    } else if (self.socialAccountMode==2) {
//        //-twitter case
//        followBtn.hidden=YES;
//        follower.hidden=NO;
//        following.hidden=NO;
//        separator.hidden=NO;
//    } else {
//        //-instagram case
//        followBtn.hidden=YES;
//        follower.hidden=NO;
//        following.hidden=NO;
//        separator.hidden=NO;
//    }
    
    [self LoadProfile];
    [self refreshTableViewData];
    
    [self.profileTbView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
}

//-Override
- (void)rightBarButtonTapped:(id)sender {
    NSLog(@"status button tapped");
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.socialAccountMode == 1) {
        return facebookDataArray.count;
    } else if (self.socialAccountMode == 2) {
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
    if (self.socialAccountMode == 1) {
        aPost=[facebookDataArray objectAtIndex:indexPath.row];
    } else if (self.socialAccountMode == 2) {
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

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    BBPost *aPost=[feedDataArray objectAtIndex:indexPath.row];
    if (aPost.socialType==FACEBOOK_POST) {
        //-Facebook
        if (aPost.postType==FBPlainStatus) {
            if (indexPath.row!=selectedIndex) {
                return kStandardCellHeight;
            } else {
                return (kStandardCellHeight+kExpandHeight);
            }
        } else {
            if (indexPath.row!=selectedIndex) {
                return kStandardImageCellHeight;
            } else {
                return (kStandardImageCellHeight+kExpandHeight);
            }
        }
    } else {
        //-Twitter & Instagram
        if (aPost.pictureLink.length>2) {
            if (indexPath.row!=selectedIndex) {
                return kStandardImageCellHeight;
            } else {
                return (kStandardImageCellHeight+kExpandHeight);
            }
        } else {
            if (indexPath.row!=selectedIndex) {
                return kStandardCellHeight;
            } else {
                return (kStandardCellHeight+kExpandHeight);
            }
        }
    }
}

*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BBPost *aPost;
    if (self.socialAccountMode == 1) {
        aPost=[facebookDataArray objectAtIndex:indexPath.row];
    } else if (self.socialAccountMode == 2) {
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
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BBPost *aPost;
    if (self.socialAccountMode == 1) {
        aPost=[facebookDataArray objectAtIndex:indexPath.row];
    } else if (self.socialAccountMode == 2) {
        aPost=[twitterDataArray objectAtIndex:indexPath.row];
    } else {
        aPost=[instagramDataArray objectAtIndex:indexPath.row];
    }
    if (aPost.socialType==TWITTER_POST) {
        if (selectedIndex==indexPath.row) {
            selectedIndex=-1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (aPost.pictureLink.length>2) {
                SHExpandImgeTWFeedCell *aCell=(SHExpandImgeTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            } else {
                SHExpandTWFeedCell *aCell=(SHExpandTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            }
        } else {
            selectedIndex=indexPath.row;
            selectedIndex=indexPath.row;
            if (aPost.pictureLink.length>2) {
                SHExpandImgeTWFeedCell *aCell=(SHExpandImgeTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            } else {
                SHExpandTWFeedCell *aCell=(SHExpandTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            }
            [tableView reloadData];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (aPost.socialType==FACEBOOK_POST) {
        if (selectedIndex==indexPath.row) {
            selectedIndex=-1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (aPost.pictureLink.length>2) {
                SHFBImageFeedCell *aCell=(SHFBImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            } else {
                SHFBNormalFeedCell *aCell=(SHFBNormalFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            }
        } else {
            selectedIndex=indexPath.row;
            if (aPost.pictureLink.length>2) {
                SHFBImageFeedCell *aCell=(SHFBImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            } else {
                SHFBNormalFeedCell *aCell=(SHFBNormalFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            }
            [tableView reloadData];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (aPost.socialType==INSTAGRAM_POST) {
        if (selectedIndex==indexPath.row) {
            selectedIndex=-1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (aPost.pictureLink.length>2) {
                SHITImageFeedCell *aCell=(SHITImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            }
        } else {
            selectedIndex=indexPath.row;
            if (aPost.pictureLink.length>2) {
                SHITImageFeedCell *aCell=(SHITImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            }
            [tableView reloadData];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - utilities method
- (void)LoadProfile{
    if (self.socialAccountMode==1) {
        //-Facebook case
         NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESSTOKEN]; // FBSession.activeSession.accessTokenData.accessToken
        NSString *fbUserId = [[NSUserDefaults standardUserDefaults] objectForKey:FB_USERID]; // [[FacebookHelper sharedInstance] getMeInfo].userId
        
        NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@?fields=cover,name,location,link,picture&type=large&access_token=%@",fbUserId,fbAccessToken];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 //-cover image
//                 [coverPhoto setImageWithURL:[NSURL URLWithString:[[JSON objectForKey:@"cover"] objectForKey:@"source"]] placeholderImage:[UIImage imageNamed:@"shadow.png"]];
//                 //-profile image
//                 NSString *smallProfilePicLink = [[[JSON objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
//                 smallProfilePicLink = [smallProfilePicLink stringByReplacingOccurrencesOfString:@"_q" withString:@"_n"];
////                 NSString *profilePicURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [[FacebookHelper sharedInstance] getMeInfo].userId];
//                 NSURL *profileURL = [NSURL URLWithString:smallProfilePicLink];
//                 [self.profileImageView setImageWithURL:profileURL placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//                     //-load successfully
//                     NSLog(@"Load successfully");
//                     if(image != nil) {
//                         self.profileImageView.image = image;
//                         [self.profileImageView setNeedsDisplay];
//                     }
//                 }];
                 
                 
                 NSString *facebookPictureUrl = [NSString stringWithFormat:kFBProfilePicURL, [[NSUserDefaults standardUserDefaults] objectForKey:FB_USERID]];
                 NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:facebookPictureUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0];
                 UIImageView *im = [[UIImageView alloc] init];
                 [im setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                     self.profileImageView.image = image;
                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                 }];
                 
                 //-full name
                 self.nameLabel.text=[JSON objectForKey:@"name"];
                 self.designationLabel.text = [[ARFacebookUser sharedInstance] worksAt];
                 self.aboutMeLabel.text = [[ARFacebookUser sharedInstance] studiedAt];
                 self.fbFriendsCountLabel.text = [NSString stringWithFormat:@"%d Friends", [[ARFacebookUser sharedInstance] friendsCount]];
             });
         }];
    } else if (self.socialAccountMode==2) {
        //-twitter case
        [self.profileImageView setImageWithURL:[NSURL URLWithString:[[ARTwitterUser sharedInstance] profilePicture]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        self.nameLabel.text=[[ARTwitterUser sharedInstance] screenName];
        self.designationLabel.text = [[ARTwitterUser sharedInstance] description];
        self.aboutMeLabel.text = [[ARTwitterUser sharedInstance] location];
        self.postsOrTweetsLabel.text = @"Tweets";
        self.postsOrTweetsCountLabel.text = [NSString stringWithFormat: @"%d", [[ARTwitterUser sharedInstance] tweetsCount]];
        [coverPhoto setImageWithURL:[NSURL URLWithString:[[ARTwitterUser sharedInstance] coverPhoto]] placeholderImage:[UIImage imageNamed:@"shadow.png"]];
        
        double followers = [[ARTwitterUser sharedInstance] numberFollowers];
        float followersCount;
        if(followers >= 1000000) {
            followersCount = followers/1000000;
            self.followersCountLabel.text=[NSString stringWithFormat:@"%.1f m\n followers",followersCount];
        } else if(followers >= 1000) {
            followersCount = followers/1000;
            self.followersCountLabel.text=[NSString stringWithFormat:@"%.1f k\n followers",followersCount];
        } else {
            self.followersCountLabel.text=[NSString stringWithFormat:@"%d\n followers",[[ARTwitterUser sharedInstance] numberFollowers]];
        }
        
        double follo = [[ARTwitterUser sharedInstance] numberFollowing];
        float followingCount;
        if(follo >= 1000000) {
            followingCount = follo/1000000;
            self.followingCountLabel.text=[NSString stringWithFormat:@"%.1f m\n following",followingCount];
        } else if(follo >= 1000) {
            followingCount = follo/1000;
            self.followingCountLabel.text=[NSString stringWithFormat:@"%.1f k\n following",followingCount];
        } else {
            self.followingCountLabel.text=[NSString stringWithFormat:@"%d\n following",[[ARTwitterUser sharedInstance] numberFollowing]];
        }
    } else if (self.socialAccountMode==3) {
        //-instagram case
        [self.profileImageView setImageWithURL:[NSURL URLWithString:[[ARInstagramUser sharedInstance] profilePicture]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        self.nameLabel.text=[[ARInstagramUser sharedInstance] fullName];
        self.designationLabel.text = [[ARInstagramUser sharedInstance] bio];
        self.aboutMeLabel.text = [[ARInstagramUser sharedInstance] username];
        self.postsOrTweetsLabel.text = @"Posts";
        self.postsOrTweetsCountLabel.text = [NSString stringWithFormat: @"%d", [[ARInstagramUser sharedInstance] postsCount]];
        self.followersCountLabel.text=[NSString stringWithFormat:@"%d\n followers",[[ARInstagramUser sharedInstance] numberFollowers]];
        self.followingCountLabel.text=[NSString stringWithFormat:@"%d\n following",[[ARInstagramUser sharedInstance] numberFollowing]];
    }
}

- (void)refreshTableViewData {
    if (self.socialAccountMode==1) {
        //-facebook posts
        [facebookDataArray removeAllObjects];
        pageNo = 0;
        [FacebookHelper sharedInstance].fbDelegate=self;
//        [[FacebookHelper sharedInstance] getMeNewsFeed];
        [[FacebookHelper sharedInstance] getMeNewsFeedLimit:kFeedsLimit offset:kFeedsLimit*pageNo];
//        [[FacebookHelper sharedInstance] getUserNewsFeed:[[NSUserDefaults standardUserDefaults] objectForKey:FB_USERID]];
    } else if (self.socialAccountMode==2) {
        //-twitter posts
        [twitterDataArray removeAllObjects];
        lastTwitterPostId = @"";
        [self getTwitterTimeline];
    } else {
        //-instagram posts
        [instagramDataArray removeAllObjects];
        if ([[ARAppDelegate application].instagram isSessionValid]) {
            lastInstagramPostId = @"";
            [self getInstagramFeed];
        }
    }
}

- (void)getInstagramFeed {
    NSString *methodName=[NSString stringWithFormat:@"users/self/feed?access_token=%@",[[ARAppDelegate application].instagram accessToken]];
    NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:kInstagramFeedLimitConst,@"count",lastInstagramPostId,@"max_id", nil];;
    [[ARAppDelegate application].instagram requestWithMethodName:methodName params:params httpMethod:@"GET" delegate:self];
}

- (void)getTwitterTimeline {
    //-Load newsfeed for twitter
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //-Fetch home timeline
//            id result=[[FHSTwitterEngine sharedEngine] getHomeTimelineSinceID:@"" count:10];
            id result = [[FHSTwitterEngine sharedEngine] getHomeTimelineMaxID:lastTwitterPostId count:kFeedsLimit];
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
- (void)request:(IGRequest *)request didLoad:(id)result {
//    [self stopIndicator];
    self.profileTbView.pullTableIsRefreshing = NO;
    self.profileTbView.pullTableIsLoadingMore = NO;
    NSArray *dataArray=[result objectForKey:@"data"];
    for (NSDictionary *aDict in dataArray) {
        BBPost *aPost=[[BBPost alloc] initWithInstagramDic:aDict];
        if (aPost!=nil) {
            [instagramDataArray addObject:aPost];
            lastInstagramPostId = aPost.postId;
        }
    }
    [self.profileTbView reloadData];
}

- (void)updateView {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.customPageControl.numberOfPages = 3;
    self.customPageControl.defersCurrentPageDisplay = YES;
    self.customPageControl.selectedDotShape = FXPageControlDotShapeCircle;
    self.customPageControl.selectedDotSize = 5.0;
    self.customPageControl.dotSize = 5.0;
    self.customPageControl.dotSpacing = 4.0;
    self.customPageControl.wrapEnabled = YES;
    
    NSLog(@"%d", self.socialAccountMode);
    if (self.socialAccountMode == 1) {
        [self.fbFriendsCountLabel setHidden:FALSE];
        [self.butttonsContainerView setHidden:TRUE];
        [self.containerView setBackgroundColor:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f]];
        
        self.customPageControl.currentPage = 0;
        self.customPageControl.selectedDotColor = [UIColor colorWithRed:216/255.0f green:222/255.0f blue:234/255.0f alpha:1.0f];
        self.customPageControl.dotColor = [UIColor colorWithRed:134/255.0f green:153/255.0f blue:191/255.0f alpha:1.0f];
        
    } else if (self.socialAccountMode == 2) {
        [self.fbFriendsCountLabel setHidden:TRUE];
        [self.butttonsContainerView setHidden:FALSE];
        self.postsOrTweetsLabel.text = @"Tweets";
        [self.containerView setBackgroundColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f]];
        
        self.customPageControl.currentPage = 1;
        self.customPageControl.selectedDotColor = [UIColor colorWithRed:221/255.0f green:238/255.0f blue:252/255.0f alpha:1.0f];
        self.customPageControl.dotColor = [UIColor colorWithRed:174/255.0f green:215/255.0f blue:247/255.0f alpha:1.0f];
        [self.butttonsContainerView setBackgroundColor:[UIColor colorWithRed:79/255.0f green:160/255.0f blue:221/255.0f alpha:1.0f]];
    } else {
        [self.fbFriendsCountLabel setHidden:TRUE];
        [self.butttonsContainerView setHidden:FALSE];
        self.postsOrTweetsLabel.text = @"Posts";
        [self.containerView setBackgroundColor:[UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f]];
        
        self.customPageControl.currentPage = 2;
        self.customPageControl.selectedDotColor = [UIColor colorWithRed:213/255.0f green:223/255.0f blue:231/255.0f alpha:1.0f];
        self.customPageControl.dotColor = [UIColor colorWithRed:150/255.0f green:174/255.0f blue:194/255.0f alpha:1.0f];
        [self.butttonsContainerView setBackgroundColor:[UIColor colorWithRed:51/255.0f green:104/255.0f blue:148/255.0f alpha:1.0f]];
    }
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:0.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:0.0f];
}

#pragma mark - Refresh and load more methods for table view

- (void) refreshTable {
    if([ARAppDelegate isNetworkAvailable]) {
        [self refreshTableViewData];
    } else {
        self.profileTbView.pullTableIsRefreshing = NO;
    }
}

- (void) loadMoreDataToTable {
    // load more
    if (self.socialAccountMode==1) {
        //-facebook posts
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getMeNewsFeedLimit:kFeedsLimit offset:kFeedsLimit*pageNo];
    } else if(self.socialAccountMode == 2) {
        [self getTwitterTimeline];
    } else if(self.socialAccountMode == 3) {
        [self getInstagramFeed];
    }
}

@end
