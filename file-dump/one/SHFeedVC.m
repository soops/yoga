//
//  SHFeedVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHFeedVC.h"
#import "FacebookHelper.h"
#import "BBPost.h"
#import "UIImageView+WebCache.h"
#import "SHFBNormalFeedCell.h"
#import "SHFBImageFeedCell.h"
#import "FHSTwitterEngine.h"
#import "SHExpandTWFeedCell.h"
#import "SHExpandImgeTWFeedCell.h"
#import "ARAppDelegate.h"
#import "SHITImageFeedCell.h"
#import "SHOneProfileDetailVC.h"
//#import "YSViewer.h"
//#import "SHYSViewerExtension.h"
#import "SHComposerVC.h"
#import "SHComposer2VC.h"
#import "UIView+Blur.h"
#import "UIImage+ImageEffects.h"
#import "BlurSettingVC.h"
#import "SHBlurSettingView.h"
#import "ASDepthModalViewController.h"
#import "WKCommonHelper.h"
#import "ARIDGesture.h"
#import "MKInfoPanel.h"
#import "AROneUser.h"
#import "AROneHelper.h"
#import "ARTwitterUser.h"
#import "ARInstagramUser.h"
#import "SHComposeContainerVC.h"
#import "SHConstant.h"
#import "SHFeedDetailVC.h"
#import "OBGradientView.h"
#import "VSWordDetector.h"
#import "SHWebViewController.h"

#define kFBProfilePicURL @"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1"
#define kStandardCellHeight                         120
#define kStandardImageCellHeight                    330
#define kExpandHeight                               30
#define kStandardCellPadding                        (30+52+12)
#define kStandardCellTextWidth                      246
#define kStandardImageHeight                        208
#define kLoadingMoreThreshold                       5
#define kStandardImageCellImageViewHeight           320
#define kInstagramImageCellImageViewHeight          320

typedef enum {
    FB_LIKE=0,
    FB_COMMENT,
    TW_REPLY,
    TW_FAVORITE,
    TW_RETWEET
}ACTION;

//#define FB_API_PREFIX                           @"https://graph.facebook.com"
//#define FB_API_PREFIX_NO_SECURE                 @"http://graph.facebook.com"

extern int feedMode;
extern bool fAccountsHasChanged;

@interface SHFeedVC ()<UITableViewDataSource,FacebookHelperDelegate,SHFBNormalFeedCellDelegate,SHFBImageFeedCellDelegate,SHExpandTWFeedCellDelegate,IGRequestDelegate,SHExpandImageTWFeedCellDelegate,SHITImageFeedCellDelegate,SHComposer2VCDelegate, VSWordDetectorDelegate> {
    NSInteger currentIndex;
    NSInteger selectedIndex;
    NSInteger slidingIndex;
    NSInteger socialMode;
    NSInteger actionMode;
    ARIDGesture *doubleTapGesture;
    SHGetFeedData *getFeedData;
    BOOL isCellSlided;
    SHFeedDetailVC *feedDetailView;
    BBPost *selectedPost;
    BOOL shownDetailView;
    DTAlertView *progressAlertView;
    SHWebViewController *webView;
}
//@property (strong, nonatomic) SHYSViewerExtension *viewer;
@property (strong, nonatomic) VSWordDetector *wordDetector;

@end

@implementation SHFeedVC

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
    [self initialSetUp];
    
    // Add imageView overlay with fade out and zoom in animation
//    SHAppDelegate *appDelegate1=(SHAppDelegate*)[[UIApplication sharedApplication] delegate];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:appDelegate1.window.frame];
//    imageView.image = [WKCommonHelper isIphone4Inch]?[UIImage imageNamed:@"splashR4.png"]:[UIImage imageNamed:@"splash.png"]; // assuming your splash image is "Default.png" or "Default@2x.png"
//    [appDelegate1.window addSubview:imageView];
//    [appDelegate1.window bringSubviewToFront:imageView];
//    [UIView transitionWithView:appDelegate1.window
//                      duration:1.0f
//                       options:UIViewAnimationOptionTransitionNone
//                    animations:^(void){
//                        imageView.alpha = 0.0f;
//                        imageView.frame = CGRectInset(imageView.frame, -100.0f, -100.0f);
//                    }
//                    completion:^(BOOL finished){
//                        [imageView removeFromSuperview];
//                    }];
    
}

- (void)initialSetUp {
    //-Navigation customization
    if(self.index == 0) {
        // Timeline
        [self renderNavigationBarWithTitle:@"Timeline" andLeftIcon:@"placeholder" andRightIcon:@"edit_selected"];
    } else if(self.index == 1) {
        // Facebook
        NSString *facebookPictureUrl = [NSString stringWithFormat:kFBProfilePicURL, [[NSUserDefaults standardUserDefaults] objectForKey:FB_USERID]];
        [self renderNavigationBarWithTitle:@"Facebook" andLeftIcon:facebookPictureUrl andRightIcon:@"edit_normal"];
    } else if(self.index == 2) {
        // Twitter
        [self renderNavigationBarWithTitle:@"Twitter" andLeftIcon:[[ARTwitterUser sharedInstance] profilePicture] andRightIcon:@"edit_normal"];
    } else {
        // Instagram
        NSLog(@"%@", [[ARInstagramUser sharedInstance] profilePicture]);
        [self renderNavigationBarWithTitle:@"Instagram" andLeftIcon:[[ARInstagramUser sharedInstance] profilePicture] andRightIcon:nil];
    }
    
    currentIndex=-1;
    selectedIndex=-1;
    slidingIndex=-1;
    
    doubleTapGesture=[[ARIDGesture alloc] initWithTarget:self action:@selector(imageDoubleTapped:)];
    doubleTapGesture.numberOfTapsRequired=2;
    
    self.wordDetector = [[VSWordDetector alloc] initWithDelegate:self];

//    if (!fAccountsHasChanged) {
//        [SHAppDelegate application].pagingNumber=0;
//        [SHAppDelegate application].lastTwitterPostId=@"";
//        [SHAppDelegate application].lastITPostId=@"";
//    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(populateFeedTable) name:LOAD_FEED_TABLE_NOTIFICATION object:nil];
}

- (void)setInitialTransformations
{
    //Set the Intial angle
    CGFloat rotationAngleDegrees = 60;
    // Caculate the radian from the intial
    CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
    //Set the Intial (x,y) position to start the animation from
    CGPoint offsetPositioning = CGPointMake(0, self.view.frame.size.height);
    
    //Define the Identity Matrix
    CATransform3D transform = CATransform3DIdentity;
    //Rotate the cell in the anti-clockwise directon to see the animation along the x- axis
    transform = CATransform3DRotate(transform, rotationAngleRadians, 1.0, 0.0, 0.0);
    //Add the translation effect to give shifting cell animation
    transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
    _initialTransformation = transform;
    
    //Override the default header to set the custom header height value
    self.feedTbView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.feedTbView.bounds.size.width, 0.01f)];
    
}

- (void)viewWillAppear:(BOOL)animated {
    shownDetailView = FALSE;
    [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_STATE_NOTIFICATION object:nil userInfo:@{@"key":@"0"}];
    
    [self.tabBarController.tabBar setHidden:FALSE];
    if(self.index == 0) {
        // Timeline
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
        if(!isCellSlided) {
            [self setInitialTransformations];
            
            // code for the tableview animation in Timeline
            UIView *card = (UITableView * )self.feedTbView;
            card.layer.transform = self.initialTransformation;
            //Set the cell to light Transparent
            card.layer.opacity = 0.8;
            
            [UIView animateWithDuration:0.5 animations:^{
                card.layer.transform = CATransform3DIdentity;
                //Make it to original color
                card.layer.opacity = 1;
            }];
        }
    } else if(self.index == 1) {
        // Facebook
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else if(self.index == 2) {
        // Twitter
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        // Instagram
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if (fAccountsHasChanged) {
        //-refresh data here
        fAccountsHasChanged=NO;
        [ARAppDelegate application].pagingNumber=0;
        [ARAppDelegate application].lastTwitterPostId=@"";
        [ARAppDelegate application].lastITPostId=@"";
//        [feedDataArray removeAllObjects];
//        [self loadSocialData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        //-set value here
//        SHOneProfileDetailVC *desVC=(SHOneProfileDetailVC*)segue.destinationViewController;
//        BBPost *selectedBBPost=[feedDataArray objectAtIndex:slidingIndex];
//        desVC.socialType=socialMode;
//        desVC.userBBPost=selectedBBPost;
    } else if ([segue.identifier isEqualToString:@"ShowComposer"]) {
        UINavigationController *navVC=segue.destinationViewController;
        SHComposer2VC *composer=[[navVC viewControllers] firstObject];
        composer.modalPresentationStyle = UIModalPresentationCurrentContext;
        composer.delegate=self;
        composer.selectedIndex = self.index;
        
        //-create blur background image
        UIImage* imageOfUnderlyingView = [self.view convertViewToImage];
        imageOfUnderlyingView = [imageOfUnderlyingView applyBlurWithRadius:10
                                                                 tintColor:[UIColor colorWithWhite:1.0 alpha:0.0]
                                                     saturationDeltaFactor:1.3
                                                                 maskImage:nil];
        composer.bgImage=imageOfUnderlyingView;
    } else if ([segue.identifier isEqualToString:@"ShowBlurSetting"]) {
        BlurSettingVC *settingVC=(BlurSettingVC*)segue.destinationViewController;
        //-create blur background image
        UIImage* imageOfUnderlyingView = [self.view convertViewToImage];
        imageOfUnderlyingView = [imageOfUnderlyingView applyBlurWithRadius:10
                                                                 tintColor:[UIColor colorWithWhite:1.0 alpha:0.8]
                                                     saturationDeltaFactor:1.3
                                                                 maskImage:nil];
        settingVC.blurBgImage=imageOfUnderlyingView;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utilities internal method
- (void)showPeopleProfile:(id)object {
    //-show profile screen here
    if ([object isKindOfClass:[BBPost class]]) {
        BBPost *bbRef=(BBPost*)object;
        socialMode=bbRef.socialType;
        [self performSegueWithIdentifier:@"ShowProfile" sender:self];
    }
}


- (void)imageDoubleTapped:(id)sender {
//    SHIDGesture *gesture=(SHIDGesture*)sender;
//    //-update like status
//    for (BBPost *aPost in feedDataArray) {
//        if (aPost.postId==gesture.postId) {
//            gesture.likeStatus=aPost.likedByUser;
//            break;
//        }
//    }
//    [self.viewer showTopLikeIconDuration:1 likeStatus:gesture.likeStatus];
//    if ((gesture.type==FACEBOOK_POST)||(gesture.type==INSTAGRAM_POST)) {
//        [self likeButtonDidClick:gesture.postId];
//    } else {
//        [self favoriteDidSelect:gesture.postId];
//    }
}

#pragma mark - Override method
- (void)rightBarButtonTapped:(id)sender {
    NSLog(@"status button tapped");
    if(self.index != 0) {
//        [self performSegueWithIdentifier:@"ShowComposer" sender:self];
        SHComposeContainerVC *composeContainer = [[SHComposeContainerVC alloc] initWithNibName:NSStringFromClass([SHComposeContainerVC class]) bundle:nil];
        composeContainer.selectedIndex = self.index;
        composeContainer.delegate = self;
        
        //-create blur background image
//        UIImage* imageOfUnderlyingView = [self.view convertViewToImage];
//        imageOfUnderlyingView = [imageOfUnderlyingView applyBlurWithRadius:10
//                                                                 tintColor:[UIColor colorWithWhite:1.0 alpha:0.0]
//                                                     saturationDeltaFactor:1.3
//                                                                 maskImage:nil];
//        composeContainer.bgImage=imageOfUnderlyingView;
        [self presentViewController:composeContainer animated:YES completion:nil];
    }
}

- (void)leftBarButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowBlurSetting" sender:self];
//    SHBlurSettingView *blurSettingV=[[SHBlurSettingView alloc] initWithFrame:self.view.frame];
//    [ASDepthModalViewController presentView:blurSettingV];
}

//-Override
- (void)dialogDidAcceptWithMessage:(NSString *)inputMessage {
//    if ((currentIndex<feedDataArray.count)&&(currentIndex>=0)) {
//        BBPost *aPost=[feedDataArray objectAtIndex:currentIndex];
//        if (aPost.socialType==FACEBOOK_POST) {
//            [FacebookHelper sharedInstance].fbDelegate=self;
//            [[FacebookHelper sharedInstance] postCommentFacebook:aPost.postId withComment:inputMessage];
//        } else if (aPost.socialType==TWITTER_POST) {
//            if (actionMode==TW_REPLY) {
//                NSError *error=[[FHSTwitterEngine sharedEngine] postTweet:inputMessage inReplyTo:aPost.postId];
//                if (error) {
////                    [self showAlertMessage:error.description withTitle:@"Error"];
//                    [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Action failed" hideAfter:1.0f];
//                } else {
//                    [self showAlertMessage:@"Reply successfully"];
//                }
//                currentIndex=-1;
//            }
//        } else if (aPost.socialType==INSTAGRAM_POST) {
//            //-for instagram posting comment
//            SHAppDelegate *appDelegate=(SHAppDelegate*)[[UIApplication sharedApplication] delegate];
//            if ([appDelegate.instagram isSessionValid]) {
//                NSString *methodName=[NSString stringWithFormat:@"media/%@/comments?access_token=%@",aPost.postId,[appDelegate.instagram accessToken]];
//                NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:inputMessage,@"text", nil];
//                [appDelegate.instagram requestWithMethodName:methodName params:params httpMethod:@"POST" delegate:self];
//            }
//        }
//    }
    
    progressAlertView = [[DTAlertView alloc] init];
    progressAlertView.alertViewMode = DTAlertViewModeProgress;
    [progressAlertView setDismissAnimationWhenButtonClicked:DTAlertViewAnimationSlideLeft];
    [progressAlertView showWithAnimation:DTAlertViewAnimationDefault];
    
    if (selectedPost.socialType==FACEBOOK_POST) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        
        [[FacebookHelper sharedInstance] postCommentFacebook:selectedPost.postId withComment:inputMessage];
    } else if(selectedPost.socialType == TWITTER_POST) {
        if(actionMode == TW_REPLY) {
            NSError *error=[[FHSTwitterEngine sharedEngine] postTweet:[NSString stringWithFormat:@"@%@ %@", selectedPost.userName, inputMessage] inReplyTo:selectedPost.postId];
            [progressAlertView dismissWithAnimation:DTAlertViewAnimationSlideLeft];
            if (error) {
                [self showAlertMessage:error.description withTitle:@"Error"];
                [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Action failed" hideAfter:1.0f];
            } else {
//                [self showAlertMessage:@"Reply successfully"];
                DTAlertView *alertView;
                alertView = [DTAlertView alertViewWithTitle:@"Twitter" message:@"Reply posted successfully" delegate:nil cancelButtonTitle:nil positiveButtonTitle:@"Ok"];
                alertView.alertViewMode = DTAlertViewModeNormal;
                [alertView setDismissAnimationWhenButtonClicked:DTAlertViewAnimationSlideLeft];
                [alertView showWithAnimation:DTAlertViewAnimationSlideLeft];
            }
        }
    } else if (selectedPost.socialType==INSTAGRAM_POST) {
        //-for instagram posting comment
        ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.instagram isSessionValid]) {
            NSString *methodName=[NSString stringWithFormat:@"media/%@/comments?access_token=%@",selectedPost.postId,[appDelegate.instagram accessToken]];
            NSMutableDictionary *params=[NSMutableDictionary dictionaryWithObjectsAndKeys:inputMessage,@"text", nil];
            [appDelegate.instagram requestWithMethodName:methodName params:params httpMethod:@"POST" delegate:self];
        }
    }
}

- (void)confirmButtonTappedAtIndex:(NSInteger)index {
//    if (currentIndex<feedDataArray.count) {
//        if (index==0) {
//            currentIndex=-1;
//        } else {
//            //-confirm OK
//            BBPost *aPost=[feedDataArray objectAtIndex:currentIndex];
//            if (aPost.socialType==FACEBOOK_POST) {
//                //-Facebook
//            } else if (aPost.socialType==TWITTER_POST) {
//                //-Twitter
//                if (actionMode==TW_RETWEET) {
//                    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
//                        NSError *error=[[FHSTwitterEngine sharedEngine] retweet:aPost.postId];
//                        if (error) {
////                            [self showAlertMessage:error.description withTitle:@"Error"];
//                            [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Action failed" hideAfter:1.0f];
//                        } else {
////                            [self showAlertMessage:@"Retweet successfully"];
//                        }
//                    }
//                    currentIndex=-1;
//                } else if (actionMode==TW_FAVORITE) {
//                    //-no nothing
//                } else if (actionMode==TW_REPLY) {
//                    //-do nothing here
////                    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
////                        NSError *error=[[FHSTwitterEngine sharedEngine] retweet:aPost.postId];
////                        if (error) {
////                            [self showAlertMessage:error.description withTitle:@"Error"];
////                        } else {
////                            [self showAlertMessage:@"Retweet successfully"];
////                        }
////                    }
////                    currentIndex=-1;
//                }
//            }
//            currentIndex=-1;
//        }
//    }
    
    if(selectedPost.socialType == TWITTER_POST) {
        if(actionMode == TW_RETWEET) {
            if (FHSTwitterEngine.sharedEngine.isAuthorized) {
                NSError *error=[[FHSTwitterEngine sharedEngine] retweet:selectedPost.postId];
                if (error) {
                    [self showAlertMessage:error.description withTitle:@"Error"];
                    [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Action failed" hideAfter:1.0f];
                } else {
                    [self showAlertMessage:@"Retweet successfully"];
                }
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.index == 0) {
        return [[ARAppDelegate application].feedDataArray count];
    } else if(self.index == 1) {
        return [[ARAppDelegate application].facebookDataArray count];
    } else if(self.index == 2) {
        return [[ARAppDelegate application].twitterDataArray count];
    } else {
        return [[ARAppDelegate application].instagramDataArray count];
    }
//    return feedDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FBNormalCell=@"FBNormalCell";
    static NSString *FBImageCell=@"FBImageCell";
    static NSString *TWExpandCell=@"SHExpandTWFeedCell";
    static NSString *TWExpandImageCell=@"SHExpandImgeTWFeedCell";
    static NSString *ITImageExpandCell=@"SHITImageFeedCell";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedUsernameLabel:)];
    
    if(self.index == 0) {
        //-currently, only facebook posts are taken into account
        BBPost *aPost=[[ARAppDelegate application].feedDataArray objectAtIndex:indexPath.row];
        
        if (aPost.socialType==FACEBOOK_POST) {
            //-Facebook mode
            if (aPost.postType==FBPlainStatus) {
                SHFBNormalFeedCell *cell1=[tableView dequeueReusableCellWithIdentifier:FBNormalCell];
                if (cell1==nil) {
                    if(selectedIndex == indexPath.row) {
                        cell1 = [[SHFBNormalFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBExpandedFeedCell"];
                        NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f], [UIColor colorWithRed:81/255.0f green:122/255.0f blue:209/255.0f alpha:1.0f], nil];
                        cell1.gradientView.colors = colors;
                    } else {
                        cell1=[[SHFBNormalFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBNormalFeedCell"];
                        cell1.leftUtilityButtons = [self leftButtons];
                        cell1.rightUtilityButtons = [self rightButtons:cell1];
                        cell1.delegate = self;
                    }
                    cell1.userName.tag = indexPath.row;
                    cell1.userName.userInteractionEnabled = YES;
                    [cell1.userName addGestureRecognizer:tap];
                    cell1.fbDelegate=self;
                    
                    [self.wordDetector addOnView:cell1.message];
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
                        NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f], [UIColor colorWithRed:81/255.0f green:122/255.0f blue:209/255.0f alpha:1.0f], nil];
                        cell2.gradientView.colors = colors;
                    } else {
                        cell2=[[SHFBImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBImageFeedCell"];
                        cell2.leftUtilityButtons = [self leftButtons];
                        cell2.rightUtilityButtons = [self rightButtons:cell2];
                        cell2.delegate = self;
                    }
                    cell2.userName.tag = indexPath.row;
                    cell2.userName.userInteractionEnabled = YES;
                    [cell2.userName addGestureRecognizer:tap];
                    cell2.fbDelegate=self;
                    [self.wordDetector addOnView:cell2.message];
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
                        NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:29/255.0f green:143/255.0f blue:241/255.0f alpha:1.0f], [UIColor colorWithRed:89/255.0f green:180/255.0f blue:249/255.0f alpha:1.0f], nil];
                        cell3.gradientView.colors = colors;
                    } else {
                        cell3=[[SHExpandImgeTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandImgeTWFeedCell"];
                        cell3.leftUtilityButtons = [self leftButtons];
                        cell3.rightUtilityButtons = [self rightButtons:cell3];
                        cell3.delegate = self;
                    }
                    cell3.userName.tag = indexPath.row;
                    cell3.userName.userInteractionEnabled = YES;
                    [cell3.userName addGestureRecognizer:tap];
                    cell3.twDelegate=self;
                    [self.wordDetector addOnView:cell3.message];
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
                        NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:29/255.0f green:143/255.0f blue:241/255.0f alpha:1.0f], [UIColor colorWithRed:89/255.0f green:180/255.0f blue:249/255.0f alpha:1.0f], nil];
                        cell4.gradientView.colors = colors;
                    } else {
                        cell4=[[SHExpandTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandTWFeedCell"];
                        cell4.leftUtilityButtons = [self leftButtons];
                        cell4.rightUtilityButtons = [self rightButtons:cell4];
                        cell4.delegate = self;
                    }
                    cell4.userName.tag = indexPath.row;
                    cell4.userName.userInteractionEnabled = YES;
                    [cell4.userName addGestureRecognizer:tap];
                    cell4.twDelegate=self;
                    [self.wordDetector addOnView:cell4.message];
                }
                [cell4 fillData:aPost];
                [cell4 setSelectedState:NO];
                
                return cell4;
            }
        } else {
//            if (aPost.pictureLink.length>2) {
                //-Instagram image cell
                SHITImageFeedCell *cell5=[tableView dequeueReusableCellWithIdentifier:ITImageExpandCell];
                if (cell5==nil) {
                    if(selectedIndex == indexPath.row) {
                        cell5=[[SHITImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHITImageExpandedFeedCell"];
                        NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f], [UIColor colorWithRed:60/255.0f green:126/255.0f blue:179/255.0f alpha:1.0f], nil];
                        cell5.gradientView.colors = colors;
                    } else {
                        cell5=[[SHITImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHITImageFeedCell"];
                        cell5.leftUtilityButtons = [self leftButtons];
                        cell5.rightUtilityButtons = [self rightButtons:cell5];
                        cell5.delegate = self;
                    }
                    cell5.userName.tag = indexPath.row;
                    cell5.userName.userInteractionEnabled = YES;
                    [cell5.userName addGestureRecognizer:tap];
                    cell5.itDelegate=self;
                    [self.wordDetector addOnView:cell5.message];
                }
                [cell5 fillData:aPost];
                [cell5 setSelectedState:NO];
                
                
                return cell5;
//            }
        }
    } else if(self.index == 1) {
        //-Facebook mode
        BBPost *aPost=[[ARAppDelegate application].facebookDataArray objectAtIndex:indexPath.row];
        if (aPost.postType==FBPlainStatus) {
            SHFBNormalFeedCell *cell1=[tableView dequeueReusableCellWithIdentifier:FBNormalCell];
            if (cell1==nil) {
                if(selectedIndex == indexPath.row) {
                    cell1 = [[SHFBNormalFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBExpandedFeedCell"];
                    NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f], [UIColor colorWithRed:81/255.0f green:122/255.0f blue:209/255.0f alpha:1.0f], nil];
                    cell1.gradientView.colors = colors;
                } else {
                    cell1=[[SHFBNormalFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBNormalFeedCell"];
                    cell1.leftUtilityButtons = [self leftButtons];
                    cell1.rightUtilityButtons = [self rightButtons:cell1];
                    cell1.delegate = self;
                }
                cell1.userName.tag = indexPath.row;
                cell1.userName.userInteractionEnabled = YES;
                [cell1.userName addGestureRecognizer:tap];
                cell1.fbDelegate=self;
                [self.wordDetector addOnView:cell1.message];
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
                    NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f], [UIColor colorWithRed:81/255.0f green:122/255.0f blue:209/255.0f alpha:1.0f], nil];
                    cell2.gradientView.colors = colors;
                } else {
                    cell2=[[SHFBImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBImageFeedCell"];
                    cell2.leftUtilityButtons = [self leftButtons];
                    cell2.rightUtilityButtons = [self rightButtons:cell2];
                    cell2.delegate = self;
                }
                cell2.userName.tag = indexPath.row;
                cell2.userName.userInteractionEnabled = YES;
                [cell2.userName addGestureRecognizer:tap];
                cell2.fbDelegate=self;
                [self.wordDetector addOnView:cell2.message];
            }
            [cell2 fillData:aPost];
            [cell2 setSelectedState:NO];
            
            return cell2;
        }
    } else if(self.index == 2) {
        //-Twitter mode
        BBPost *aPost=[[ARAppDelegate application].twitterDataArray objectAtIndex:indexPath.row];
        if (aPost.pictureLink.length>2) {
            SHExpandImgeTWFeedCell *cell3=[tableView dequeueReusableCellWithIdentifier:TWExpandImageCell];
            if (cell3==nil) {
                if(selectedIndex == indexPath.row) {
                    cell3=[[SHExpandImgeTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHImageExpandedTWFeedCell"];
                    NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:29/255.0f green:143/255.0f blue:241/255.0f alpha:1.0f], [UIColor colorWithRed:89/255.0f green:180/255.0f blue:249/255.0f alpha:1.0f], nil];
                    cell3.gradientView.colors = colors;
                } else {
                    cell3=[[SHExpandImgeTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandImgeTWFeedCell"];
                    cell3.leftUtilityButtons = [self leftButtons];
                    cell3.rightUtilityButtons = [self rightButtons:cell3];
                    cell3.delegate = self;
                }
                cell3.userName.tag = indexPath.row;
                cell3.userName.userInteractionEnabled = YES;
                [cell3.userName addGestureRecognizer:tap];
                cell3.twDelegate=self;
                [self.wordDetector addOnView:cell3.message];
            }
            [cell3 fillData:aPost];
            [cell3 setSelectedState:NO];
            
            
            return cell3;
        } else {
            SHExpandTWFeedCell *cell4=[tableView dequeueReusableCellWithIdentifier:TWExpandCell];
            if (cell4==nil) {
                if(selectedIndex == indexPath.row) {
                    cell4=[[SHExpandTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandedTWFeedCell"];
                    NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:29/255.0f green:143/255.0f blue:241/255.0f alpha:1.0f], [UIColor colorWithRed:89/255.0f green:180/255.0f blue:249/255.0f alpha:1.0f], nil];
                    cell4.gradientView.colors = colors;
                } else {
                    cell4=[[SHExpandTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandTWFeedCell"];
                    cell4.leftUtilityButtons = [self leftButtons];
                    cell4.rightUtilityButtons = [self rightButtons:cell4];
                    cell4.delegate = self;
                }
                cell4.userName.tag = indexPath.row;
                cell4.userName.userInteractionEnabled = YES;
                [cell4.userName addGestureRecognizer:tap];
                cell4.twDelegate=self;
                [self.wordDetector addOnView:cell4.message];
            }
            [cell4 fillData:aPost];
            [cell4 setSelectedState:NO];
            
            return cell4;
        }
    } else {
        // Instagram
        BBPost *aPost=[[ARAppDelegate application].instagramDataArray objectAtIndex:indexPath.row];
//        if (aPost.pictureLink.length>2) {
            //-Instagram image cell
            SHITImageFeedCell *cell5=[tableView dequeueReusableCellWithIdentifier:ITImageExpandCell];
            if (cell5==nil) {
                if(selectedIndex == indexPath.row) {
                    cell5=[[SHITImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHITImageExpandedFeedCell"];
                    NSArray *colors = [NSArray arrayWithObjects:[UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f], [UIColor colorWithRed:60/255.0f green:126/255.0f blue:179/255.0f alpha:1.0f], nil];
                    cell5.gradientView.colors = colors;
                } else {
                    cell5=[[SHITImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHITImageFeedCell"];
                    cell5.leftUtilityButtons = [self leftButtons];
                    cell5.rightUtilityButtons = [self rightButtons:cell5];
                    cell5.delegate = self;
                }
                cell5.userName.tag = indexPath.row;
                cell5.userName.userInteractionEnabled = YES;
                [cell5.userName addGestureRecognizer:tap];
                cell5.itDelegate=self;
                [self.wordDetector addOnView:cell5.message];
            }
            [cell5 fillData:aPost];
            [cell5 setSelectedState:NO];
            
            
            return cell5;
//        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    BBPost *aPost;
    if(self.index == 0) {
        aPost=[[ARAppDelegate application].feedDataArray objectAtIndex:indexPath.row];
    } else if(self.index == 1) {
        aPost=[[ARAppDelegate application].facebookDataArray objectAtIndex:indexPath.row];
    } else if(self.index == 2) {
        aPost=[[ARAppDelegate application].twitterDataArray objectAtIndex:indexPath.row];
    } else {
        aPost=[[ARAppDelegate application].instagramDataArray objectAtIndex:indexPath.row];
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
                return textHeight+kStandardImageCellImageViewHeight+83; // 173
            } else {
                return textHeight+kStandardImageCellImageViewHeight+83+51;
            }
        }
    } else if (aPost.socialType==TWITTER_POST) {
        //-Twitter
        if (aPost.pictureLink.length>2) {
            if (indexPath.row!=selectedIndex) {
                return textHeight+kStandardImageCellImageViewHeight+80;// Twitter image case
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
            return textHeight+kInstagramImageCellImageViewHeight+80;// Twitter image case
        } else {
            return textHeight+kInstagramImageCellImageViewHeight+80+51;
        }
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(self.index == 0) {
        selectedPost=[[ARAppDelegate application].feedDataArray objectAtIndex:indexPath.row];
    } else if(self.index == 1) {
        selectedPost=[[ARAppDelegate application].facebookDataArray objectAtIndex:indexPath.row];
    } else if(self.index == 2) {
        selectedPost=[[ARAppDelegate application].twitterDataArray objectAtIndex:indexPath.row];
    } else {
        selectedPost=[[ARAppDelegate application].instagramDataArray objectAtIndex:indexPath.row];
    }

    if (selectedPost.socialType==TWITTER_POST) {
        if (selectedIndex==indexPath.row) {
            selectedIndex=-1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (selectedPost.pictureLink.length>2) {
                SHExpandImgeTWFeedCell *aCell=(SHExpandImgeTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            } else {
                SHExpandTWFeedCell *aCell=(SHExpandTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            }
        } else {
            selectedIndex=indexPath.row;
            selectedIndex=indexPath.row;
            if (selectedPost.pictureLink.length>2) {
                SHExpandImgeTWFeedCell *aCell=(SHExpandImgeTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            } else {
                SHExpandTWFeedCell *aCell=(SHExpandTWFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            }
            [tableView reloadData];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (selectedPost.socialType==FACEBOOK_POST) {
        if (selectedIndex==indexPath.row) {
            selectedIndex=-1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (selectedPost.pictureLink.length>2) {
                SHFBImageFeedCell *aCell=(SHFBImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            } else {
                SHFBNormalFeedCell *aCell=(SHFBNormalFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
            }
        } else {
            selectedIndex=indexPath.row;
            if (selectedPost.pictureLink.length>2) {
                SHFBImageFeedCell *aCell=(SHFBImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            } else {
                SHFBNormalFeedCell *aCell=(SHFBNormalFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
            }
            [tableView reloadData];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (selectedPost.socialType==INSTAGRAM_POST) {
        if (selectedIndex==indexPath.row) {
            selectedIndex=-1;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            if (selectedPost.pictureLink.length>2) {
                SHITImageFeedCell *aCell=(SHITImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:NO];
//            }
        } else {
            selectedIndex=indexPath.row;
//            if (selectedPost.pictureLink.length>2) {
                SHITImageFeedCell *aCell=(SHITImageFeedCell*)[tableView cellForRowAtIndexPath:indexPath];
                [aCell setSelectedState:YES];
//            }
            [tableView reloadData];
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    getFeedData = [[SHGetFeedData alloc] init];
//    getFeedData.delegate = self;
//    if(self.index == 0) {
//        if (indexPath.row==([SHAppDelegate application].feedDataArray.count-kLoadingMoreThreshold)) {
//            [getFeedData loadSocialData];
//        }
//    } else if(self.index == 1) {
//        if (indexPath.row==([SHAppDelegate application].feedDataArray.count-kLoadingMoreThreshold)) {
//            [getFeedData loadFacebookData];
//        }
//    } else if(self.index == 2) {
//        if (indexPath.row==([SHAppDelegate application].feedDataArray.count-kLoadingMoreThreshold)) {
//            [getFeedData loadTwitterData];
//        }
//    } else {
//        if (indexPath.row==([SHAppDelegate application].feedDataArray.count-kLoadingMoreThreshold)) {
//            [getFeedData loadInstagramData];
//        }
//    }
}

- (void)postSharingContentDidSuccess:(NSDictionary *)dic {
//    [self showAlertMessage:@"Successfully posted your status to facebook"];
//    [self stopIndicator];
}

- (void)postSharingContentDidFailed:(NSError *)error {
//    [self stopIndicator];
    [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Shared unsuccessful" hideAfter:1.0f];
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle==UITableViewCellEditingStyleDelete) {
//        //-delte the row here
//        [feedDataArray removeObjectAtIndex:indexPath.row];
//        [self.feedTbView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
//    }
//}

- (void) getNewsFeedDidFail:(NSError*)error {
//    [self stopIndicator];
}

- (void) likeCommentDidSuccess:(NSDictionary *)dic {
//    if (currentIndex<feedDataArray.count) {
//        BBPost *aPost=[feedDataArray objectAtIndex:currentIndex];
//        aPost.likedByUser=!aPost.likedByUser;
//        if (aPost.likedByUser) {
//            aPost.numberOfLikes+=1;
//        } else {
//            aPost.numberOfLikes-=1;
//        }
//        NSIndexPath *indexPath=[NSIndexPath indexPathForItem:currentIndex inSection:0];
//        [self.feedTbView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        id currentCell=[self.feedTbView cellForRowAtIndexPath:indexPath];
//        if ([currentCell isKindOfClass:[SHFBNormalFeedCell class]]) {
////            [(SHFBNormalFeedCell*)currentCell setSelectedState:YES];
//        } else if ([ currentCell isKindOfClass:[SHFBImageFeedCell class]]) {
////            [(SHFBImageFeedCell*)currentCell setSelectedState:YES];
//        }
//    }
    
    currentIndex=-1;
}
- (void) likeCommentDidFailed:(NSError*)error {
    NSLog(@"Error: %@",error.description);
    currentIndex=-1;
    [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Like unsuccessful" hideAfter:1.0f];
}

- (void) postCommentDidSuccess:(NSDictionary *)dic {
    //-update number of comments
//    if (currentIndex<feedDataArray.count) {
//        BBPost *aPost=[feedDataArray objectAtIndex:currentIndex];
//        aPost.numberOfComments+=1;
//        NSIndexPath *indexPath=[NSIndexPath indexPathForItem:currentIndex inSection:0];
//        [self.feedTbView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        id currentCell=[self.feedTbView cellForRowAtIndexPath:indexPath];
//        if ([currentCell isKindOfClass:[SHFBNormalFeedCell class]]) {
////            [(SHFBNormalFeedCell*)currentCell setSelectedState:YES];
//        } else if ([ currentCell isKindOfClass:[SHFBImageFeedCell class]]) {
////            [(SHFBImageFeedCell*)currentCell setSelectedState:YES];
//        }
//    }
    
    [progressAlertView dismissWithAnimation:DTAlertViewAnimationSlideLeft];
    currentIndex=-1;
    
    DTAlertView *alertView;
    alertView = [DTAlertView alertViewWithTitle:@"Facebook" message:@"Comment posted successfully" delegate:nil cancelButtonTitle:nil positiveButtonTitle:@"Ok"];
    alertView.alertViewMode = DTAlertViewModeNormal;
    [alertView setDismissAnimationWhenButtonClicked:DTAlertViewAnimationSlideLeft];
    [alertView showWithAnimation:DTAlertViewAnimationSlideLeft];
}

- (void) postCommentDidFailed:(NSError*)error {
    currentIndex=-1;
    [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Comment failed" hideAfter:1.0f];
}

#pragma mark - Cell delegate
- (void)likeButtonDidClick:(NSString*)postId {
    NSLog(@"post id: %@",postId);
    
    if (selectedPost.socialType==FACEBOOK_POST) {
        //-do action for facebook
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] likeCommentFacebook:!selectedPost.likedByUser withCommentID:postId];
    } else if (selectedPost.socialType==INSTAGRAM_POST) {
        //-do action for instagram
        ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
        if ([appDelegate.instagram isSessionValid]) {
            NSString *methodName=[NSString stringWithFormat:@"media/%@/likes?access_token=%@",selectedPost.postId,[appDelegate.instagram accessToken]];
            if (selectedPost.likedByUser) {
                [appDelegate.instagram requestWithMethodName:methodName params:nil httpMethod:@"DELETE" delegate:self];
            } else {
                [appDelegate.instagram requestWithMethodName:methodName params:nil httpMethod:@"POST" delegate:self];
            }
        }
    }
}
- (void)commentButtonDidClick:(NSString*)postId {
    NSLog(@"post id: %@",postId);
//    for (BBPost *aPost in feedDataArray) {
//        if ([aPost.postId isEqualToString:postId]) {
//            currentIndex=[feedDataArray indexOfObject:aPost];
//            break;
//        }
//    }
    [self showDialogWithTitle:@"Type your comment here" confirmButton:@"OK" cancelButton:@"Cancel"];
}

#pragma mark - SHExpandTWFeedCellDelegate
- (void)favoriteDidSelect:(NSString*)postId {
    NSLog(@"start favoring id: %@",postId);
//    for (BBPost *aPost in feedDataArray) {
//        if ([aPost.postId isEqualToString:postId]) {
//            currentIndex=[feedDataArray indexOfObject:aPost];
//            actionMode=TW_FAVORITE;
//            if (FHSTwitterEngine.sharedEngine.isAuthorized) {
//                NSError *error=[[FHSTwitterEngine sharedEngine] markTweet:postId asFavorite:!aPost.likedByUser];
//                if (error) {
////                    [self showAlertMessage:error.description withTitle:@"Error"];
//                    [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Action failed" hideAfter:1.0f];
//                    //-do nothing now
//                } else {
////                    [self showAlertMessage:@"Mark favorite successfully"];
//                    //-update UI here
//                    aPost.likedByUser=!aPost.likedByUser;
//                    NSIndexPath *indexPath=[NSIndexPath indexPathForItem:currentIndex inSection:0];
//                    [self.feedTbView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//                    id currentCell=[self.feedTbView cellForRowAtIndexPath:indexPath];
//                    if ([currentCell isKindOfClass:[SHExpandImgeTWFeedCell class]]) {
////                        [(SHExpandImgeTWFeedCell*)currentCell setSelectedState:YES];
//                    } else if ([ currentCell isKindOfClass:[SHExpandTWFeedCell class]]) {
////                        [(SHExpandTWFeedCell*)currentCell setSelectedState:YES];
//                    }
//                }
//            }
//            currentIndex=-1;
//            
//            break;
//        }
//    }
    
    actionMode=TW_FAVORITE;
    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
        NSError *error=[[FHSTwitterEngine sharedEngine] markTweet:postId asFavorite:!selectedPost.likedByUser];
        if (error) {
            //                    [self showAlertMessage:error.description withTitle:@"Error"];
            [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Action failed" hideAfter:1.0f];
            //-do nothing now
        } else {
            //                    [self showAlertMessage:@"Mark favorite successfully"];
            //-update UI here
            selectedPost.likedByUser=!selectedPost.likedByUser;
//            NSIndexPath *indexPath=[NSIndexPath indexPathForItem:currentIndex inSection:0];
//            [self.feedTbView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            id currentCell=[self.feedTbView cellForRowAtIndexPath:indexPath];
//            if ([currentCell isKindOfClass:[SHExpandImgeTWFeedCell class]]) {
//                //                        [(SHExpandImgeTWFeedCell*)currentCell setSelectedState:YES];
//            } else if ([ currentCell isKindOfClass:[SHExpandTWFeedCell class]]) {
//                //                        [(SHExpandTWFeedCell*)currentCell setSelectedState:YES];
//            }
        }
    }
}

- (void)retweetDidSelect:(NSString*)postId {
    NSLog(@"start retweeting id: %@",postId);
    actionMode=TW_RETWEET;
//    for (BBPost *aPost in feedDataArray) {
//        if ([aPost.postId isEqualToString:postId]) {
//            currentIndex=[feedDataArray indexOfObject:aPost];
//            break;
//        }
//    }
    [self showConfirmMessage:@"Retweet this post?" withTitle:@"Confirm" confirmButton:@"OK" cancelButton:@"Cancel"];
}

- (void)replyDidSelect:(NSString*)postId {
    NSLog(@"start replying id: %@",postId);
    actionMode=TW_REPLY;
//    for (BBPost *aPost in feedDataArray) {
//        if ([aPost.postId isEqualToString:postId]) {
//            currentIndex=[feedDataArray indexOfObject:aPost];
//            break;
//        }
//    }
    [self showDialogWithTitle:@"Reply" confirmButton:@"OK" cancelButton:@"Cancel"];
}


#pragma mark - IGRequestDelegate

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(IGRequest *)request didReceiveResponse:(NSHTTPURLResponse *)response {
    NSLog(@"did respond %d", response.statusCode);
    [progressAlertView dismissWithAnimation:DTAlertViewAnimationSlideLeft];
    if(response.statusCode == 200) {
        DTAlertView *alertView;
        alertView = [DTAlertView alertViewWithTitle:@"Success" message:@"\n\n\n" delegate:nil cancelButtonTitle:nil positiveButtonTitle:@"Ok"];
        alertView.alertViewMode = DTAlertViewModeNormal;
        [alertView setDismissAnimationWhenButtonClicked:DTAlertViewAnimationSlideLeft];
        [alertView showWithAnimation:DTAlertViewAnimationSlideLeft];
    }
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(IGRequest *)request didFailWithError:(NSError *)error {
//    [self stopIndicator];
//    [self showAlertMessage:[[error userInfo] objectForKey:@"error_message"] withTitle:@"Error"];
    [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:[[error userInfo] objectForKey:@"error_message"] hideAfter:1.0f];
}

/*
 
#pragma mark - JZSwipeCellDelegate methods

- (void)swipeCell:(JZSwipeCell*)cell triggeredSwipeWithType:(JZSwipeType)swipeType
{
//	if (swipeType != JZSwipeTypeNone)
//	{
//		NSIndexPath *indexPath = [self.feedTbView indexPathForCell:cell];
//		if (indexPath)
//		{
//			[feedDataArray removeObjectAtIndex:indexPath.row];
//			[self.feedTbView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//		}
//	}
	
}

- (void)swipeCell:(JZSwipeCell *)cell swipeTypeChangedFrom:(JZSwipeType)from to:(JZSwipeType)to
{
	// perform custom state changes here
	NSLog(@"Swipe Changed From (%d) To (%d)", from, to);
}

*/

#pragma mark - handle view action
- (void)viewImageTapped:(NSString*)postId {
    BBPost *targetPost;
    NSArray *feedDataArray;
    if(self.index == 0) {
        feedDataArray = [ARAppDelegate application].feedDataArray;
    } else if(self.index == 1) {
        feedDataArray = [ARAppDelegate application].facebookDataArray;
    } else if(self.index == 2) {
        feedDataArray = [ARAppDelegate application].twitterDataArray;
    } else {
        feedDataArray = [ARAppDelegate application].instagramDataArray;
    }
    for (BBPost *aPost in feedDataArray) {
        if ([aPost.postId isEqual:postId]) {
            targetPost=aPost;
            break;
        }
    }
    //-show image here
    UIImageView *photoView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    photoView.contentMode=UIViewContentModeScaleAspectFit;
    [photoView setImageWithURL:[NSURL URLWithString:targetPost.pictureLink] placeholderImage:[UIImage imageNamed:@"notif_placeholder.png"]];
    self.viewer.view=photoView;
    [self.viewer show];
    
    //-add double tap gesture to uiimageview
    doubleTapGesture.postId=postId;
    doubleTapGesture.type=targetPost.socialType;
    doubleTapGesture.likeStatus=targetPost.likedByUser;
    if (targetPost.likedByUser) {
        NSLog(@"liked by user before");
    } else {
        NSLog(@"not yet liked before");
    }
    self.viewer.view.userInteractionEnabled=YES;
    [self.viewer.view addGestureRecognizer:doubleTapGesture];
}

- (void)tappedUsernameLabel:(UIGestureRecognizer *)gesture {
    [self.feedTbView reloadData];
    int tag = gesture.view.tag;
    
    BBPost *aPost;
    if(self.index == 0) {
        aPost=[[ARAppDelegate application].feedDataArray objectAtIndex:tag];
    } else if(self.index == 1) {
        aPost=[[ARAppDelegate application].facebookDataArray objectAtIndex:tag];
    } else if(self.index == 2) {
        aPost=[[ARAppDelegate application].twitterDataArray objectAtIndex:tag];
    } else {
        aPost=[[ARAppDelegate application].instagramDataArray objectAtIndex:tag];
    }
    
    oneDetail = [[ARAppDelegate mainStoryboard] instantiateViewControllerWithIdentifier:@"OneProfileDetail"];
    oneDetail.userBBPost = aPost;
    if (aPost.socialType==FACEBOOK_POST) {
        oneDetail.socialType = 1;
    } else if (aPost.socialType==TWITTER_POST) {
        oneDetail.socialType = 2;
    } else {
        oneDetail.socialType = 3;
    }
    [self presentViewController:oneDetail animated:YES completion:nil];
}

// action for username button on custom cell.
- (void)usernameButtonDidClick:(BBPost *)aPost {
    [self.feedTbView reloadData];
    oneDetail = [[ARAppDelegate mainStoryboard] instantiateViewControllerWithIdentifier:@"OneProfileDetail"];
    oneDetail.userBBPost = aPost;
    if (aPost.socialType==FACEBOOK_POST) {
        oneDetail.socialType = 1;
    } else if (aPost.socialType==TWITTER_POST) {
        oneDetail.socialType = 2;
    } else {
        oneDetail.socialType = 3;
    }
    [self presentViewController:oneDetail animated:YES completion:nil];
}

#pragma mark - SHComposerVCDelegate
- (void)didPostWithTextContent:(NSString*)inputText {
    [FacebookHelper sharedInstance].fbDelegate=self;
    [[FacebookHelper sharedInstance] postToWallWithMessage:inputText andWithLink:@""];
}

- (void)didPostWithTextContent:(NSString *)inputText facebook:(BOOL)fFacebook twitter:(BOOL)fTwitter instagram:(BOOL)fInstagram {
//    [self showIndicatorWithMessage:@"Loading..."];
    if (fFacebook) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] postToWallWithMessage:inputText andWithLink:@""];
    }
    if (fTwitter) {
        //-post to twitter here
        if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    //-Fetch home timeline
                    id result=[[FHSTwitterEngine sharedEngine] postTweet:inputText];
                    if ([result isKindOfClass:[NSError class]]) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
//                            [self showAlertMessage:[(NSError*)result description]];
                            [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Cannot post to Twitter this time" hideAfter:1.0f];
                        });
                    } else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
//                            [self showAlertMessage:@"Successfully created your tweet"];
                        });
                    }
                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        [self stopIndicator];
                    });
                }
            });
        }
    }
    
    if (fInstagram) {
        //-currently not applicable
    }
}

- (void)didPostWithTextContent:(NSString*)inputText image:(UIImage*)image facebook:(BOOL)fFacebook twitter:(BOOL)fTwitter instagram:(BOOL)fInstagram {
//    [self showIndicatorWithMessage:@"Loading..."];
    if (fFacebook) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] postImageToWall:image withMessage:inputText];
    }
    if (fTwitter) {
        //-post to twitter here
        if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @autoreleasepool {
                    //-Fetch home timeline
                    id result=[[FHSTwitterEngine sharedEngine] postTweet:inputText withImageData:UIImagePNGRepresentation(image)];
                    if ([result isKindOfClass:[NSError class]]) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
//                            [self showAlertMessage:[(NSError*)result description]];
                            [MKInfoPanel showPanelInView:self.navigationController.view type:MKInfoPanelTypeError title:@"Error" subtitle:@"Action failed" hideAfter:1.0f];
                        });
                    } else {
                        dispatch_sync(dispatch_get_main_queue(), ^{
//                            [self showAlertMessage:@"Successfully created your tweet"];
                        });
                    }
                    dispatch_sync(dispatch_get_main_queue(), ^{
//                        [self stopIndicator];
                    });
                }
            });
        }
    }
    
    if (fInstagram) {
        //-currently not applicable
    }
}

- (IBAction)composeTapped:(id)sender {
    [self performSegueWithIdentifier:@"ShowComposer" sender:self];
}

#pragma mark - SHFeeddataDelegate method

- (void)didGetFeedData {
    // got data here
    getFeedData = nil;
    [self.feedTbView reloadData];
    self.feedTbView.pullTableIsRefreshing = NO;
    self.feedTbView.pullTableIsLoadingMore = NO;
//    [self.feedTbView setHidden:NO];
    [self viewWillAppear:YES];
}

- (void)populateFeedTable {
    [self.feedTbView reloadData];
    self.feedTbView.pullTableIsRefreshing = NO;
    self.feedTbView.pullTableIsLoadingMore = NO;
//    [self.feedTbView setHidden:NO];
    [self viewWillAppear:YES];
}

#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:1.0f];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:1.0f];
}

#pragma mark - Refresh and load more methods for table view

- (void) refreshTable {
    if([ARAppDelegate isNetworkAvailable]) {
        
        [ARAppDelegate application].pagingNumber=0;
        [ARAppDelegate application].lastTwitterPostId=@"";
        [ARAppDelegate application].lastITPostId=@"";
        [self initialSetUp];
        getFeedData = [[SHGetFeedData alloc] init];
        getFeedData.delegate = self;
        getFeedData.shouldRefresh = TRUE;
        [getFeedData loadSocialData];
        
    } else {
        self.feedTbView.pullTableIsRefreshing = NO;
    }
}

- (void) loadMoreDataToTable {
    // load more
    getFeedData = [[SHGetFeedData alloc] init];
    getFeedData.delegate = self;
    if(self.index == 0) {
        [getFeedData loadSocialData];
    } else if(self.index == 1) {
        [getFeedData loadFacebookData];
    } else if(self.index == 2) {
        [getFeedData loadTwitterData];
    } else {
        [getFeedData loadInstagramData];
    }
}

- (NSArray *)rightButtons:(id)cell
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor whiteColor] icon:nil];

//    if([cell isKindOfClass:[SHFBImageFeedCell class]] || [cell isKindOfClass:[SHFBNormalFeedCell class]]) {
//        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f] icon:[UIImage imageNamed:@"more"]];
//    } else if([cell isKindOfClass:[SHExpandImgeTWFeedCell class]] || [cell isKindOfClass:[SHExpandTWFeedCell class]]) {
//        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f] icon:[UIImage imageNamed:@"more"]];
//    } else if([cell isKindOfClass:[SHITImageFeedCell class]] || [cell isKindOfClass:[SHITNormalFeedCell class]]) {
//        [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f] icon:[UIImage imageNamed:@"more"]];
//    }

    return rightUtilityButtons;
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.07 green:0.75f blue:0.16f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"check.png"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:1.0f green:1.0f blue:0.35f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"clock.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0]
                                                icon:[UIImage imageNamed:@"delete_sign"]];
//    [leftUtilityButtons sw_addUtilityButtonWithColor:
//     [UIColor colorWithRed:0.55f green:0.27f blue:0.07f alpha:1.0]
//                                                icon:[UIImage imageNamed:@"list.png"]];
    
    return leftUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            isCellSlided = FALSE;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_STATE_NOTIFICATION object:nil userInfo:@{@"key":@"0"}];
            break;
        case 1:
            NSLog(@"left utility buttons open");
            isCellSlided = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_STATE_NOTIFICATION object:nil userInfo:@{@"key":@"1"}];
            break;
        case 2:
            NSLog(@"right utility buttons open");
            isCellSlided = TRUE;
            [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_STATE_NOTIFICATION object:nil userInfo:@{@"key":@"1"}];
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0: {
            NSLog(@"left button 0 was pressed");
            NSIndexPath *indexPath = [self.feedTbView indexPathForCell:cell];
            if (indexPath) {
                if(self.index == 0) {
                    [[ARAppDelegate application].feedDataArray removeObjectAtIndex:indexPath.row];
                } else if(self.index == 1) {
                    [[ARAppDelegate application].facebookDataArray removeObjectAtIndex:indexPath.row];
                } else if(self.index == 2) {
                    [[ARAppDelegate application].twitterDataArray removeObjectAtIndex:indexPath.row];
                } else {
                    [[ARAppDelegate application].instagramDataArray removeObjectAtIndex:indexPath.row];
                }
                [self.feedTbView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
//    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    NSIndexPath *indexPath = [self.feedTbView indexPathForCell:cell];
    BBPost *post;
    if(self.index == 0) {
        post = [[ARAppDelegate application].feedDataArray objectAtIndex:indexPath.row];
    } else if(self.index == 1) {
        post = [[ARAppDelegate application].facebookDataArray objectAtIndex:indexPath.row];
    } else if(self.index == 2) {
        post = [[ARAppDelegate application].twitterDataArray objectAtIndex:indexPath.row];
    } else {
        post = [[ARAppDelegate application].instagramDataArray objectAtIndex:indexPath.row];
    }
    switch (index) {
        case 0:
        {
            NSLog(@"More button was pressed");
//            UIAlertView *alertTest = [[UIAlertView alloc] initWithTitle:@"Hello" message:@"More more more" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil];
//            [alertTest show];
            
            [cell hideUtilityButtonsAnimated:YES];
            
//            feedDetailView = [[SHFeedDetailVC alloc] initWithNibName:NSStringFromClass([SHFeedDetailVC class ]) bundle:nil];
//            feedDetailView.post = post;
//            [self.navigationController pushViewController:feedDetailView animated:YES];
            break;
        }
        case 1:
        {
            // Delete button was pressed
//            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
//            
//            [_testArray[cellIndexPath.section] removeObjectAtIndex:cellIndexPath.row];
//            [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
//    if(state == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PAGE_VIEW_CONTROLLER_STATE_NOTIFICATION object:nil userInfo:@{@"key":@"1"}];
//    }
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2: {
            NSIndexPath *indexPath= [self.feedTbView indexPathForCell:cell];
            [self showDetailViewWithIndexPath:indexPath];
            [cell hideUtilityButtonsAnimated:YES];
            // set to NO to disable all right utility buttons appearing
            return YES;
        }
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)showDetailViewWithIndexPath:(NSIndexPath *)indexPath {
    if(!shownDetailView) {
        shownDetailView = TRUE;
        
        BBPost *post;
        if(self.index == 0) {
            post = [[ARAppDelegate application].feedDataArray objectAtIndex:indexPath.row];
        } else if(self.index == 1) {
            post = [[ARAppDelegate application].facebookDataArray objectAtIndex:indexPath.row];
        } else if(self.index == 2) {
            post = [[ARAppDelegate application].twitterDataArray objectAtIndex:indexPath.row];
        } else {
            post = [[ARAppDelegate application].instagramDataArray objectAtIndex:indexPath.row];
        }
        feedDetailView = [[SHFeedDetailVC alloc] initWithNibName:NSStringFromClass([SHFeedDetailVC class ]) bundle:nil];
        feedDetailView.post = post;
        [self.navigationController pushViewController:feedDetailView animated:YES];
    }
}

#pragma mark - Word detector delegate

-(void)wordDetector:(VSWordDetector *)wordDetector detectWord:(NSString *)word {
    NSLog(@"Detected Word: %@", word);
    NSLog(@"Detected Word: %@", [word substringFromIndex:1]);
    if([word hasPrefix:@"@"]) {
        // load twitter
        oneDetail = [[ARAppDelegate mainStoryboard] instantiateViewControllerWithIdentifier:@"OneProfileDetail"];
        oneDetail.screenName = [word substringFromIndex:1];
        oneDetail.socialType = 2;
        [self presentViewController:oneDetail animated:YES completion:nil];
    } else if([word hasPrefix:@"http"] || [word hasPrefix:@"www."]) {
        // load webview
        webView = [[SHWebViewController alloc] initWithNibName:NSStringFromClass([SHWebViewController class]) bundle:nil];
        webView.name = word;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webView];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

@end
