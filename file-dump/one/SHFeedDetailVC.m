//
//  SHFeedDetailVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHFeedDetailVC.h"
#import "SHFBNormalFeedCell.h"
#import "SHFBImageFeedCell.h"
#import "SHExpandTWFeedCell.h"
#import "SHExpandImgeTWFeedCell.h"
#import "SHITImageFeedCell.h"
#import "SHGetFeedData.h"
#import "WFConfigs.h"

#define kStandardCellTextWidth                      246
#define kStandardImageCellImageViewHeight           154
#define kInstagramImageCellImageViewHeight          246

@interface SHFeedDetailVC () <SHFBNormalFeedCellDelegate, SHFBImageFeedCellDelegate, SHExpandTWFeedCellDelegate, SHExpandImageTWFeedCellDelegate, SHITImageFeedCellDelegate, getFeedDataDelegate, NSURLConnectionDataDelegate> {
    SHGetFeedData *getFeedData;
    NSMutableData *responseData;
}

@end

@implementation SHFeedDetailVC

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
    
    [self customiozeNavigationBar];
    [self.tabBarController.tabBar setHidden:TRUE];
    
//    if(self.post.socialType == FACEBOOK_POST) {
//        getFeedData = [[SHGetFeedData alloc] init];
//        getFeedData.delegate = self;
//        [getFeedData getCommentsForPost:self.post.postId];
//    }
//    
//    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FBAccessTokenKey];
//    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/v1.0/%@/comments?&access_token=%@", self.post.postId, accessToken]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
//    
//    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)customiozeNavigationBar {
    self.navigationController.navigationBar.topItem.title = @"";
    UILabel *navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 200, 20)];
    navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
    navigationTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    navigationTitleLabel.backgroundColor = [UIColor clearColor];
    if (self.post.socialType==FACEBOOK_POST) {
        navigationTitleLabel.textColor = [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
    } else if (self.post.socialType==TWITTER_POST) {
        navigationTitleLabel.textColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    } else {
        navigationTitleLabel.textColor = [UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f];
    }
    navigationTitleLabel.text = @"Detail";
    self.navigationItem.titleView = navigationTitleLabel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *FBNormalCell=@"FBNormalCell";
    static NSString *FBImageCell=@"FBImageCell";
    static NSString *TWExpandCell=@"SHExpandTWFeedCell";
    static NSString *TWExpandImageCell=@"SHExpandImgeTWFeedCell";
    static NSString *ITImageExpandCell=@"SHITImageFeedCell";
    
    if (self.post.socialType==FACEBOOK_POST) {
        //-Facebook mode
        if (self.post.postType==FBPlainStatus) {
            SHFBNormalFeedCell *cell1=[tableView dequeueReusableCellWithIdentifier:FBNormalCell];
            if (cell1==nil) {
                cell1=[[SHFBNormalFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBExpandedFeedDetailCell"];
                cell1.userName.textColor = [UIColor blackColor];
                cell1.socialType.textColor = [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
                cell1.updatedTime.textColor = [UIColor lightGrayColor];
                cell1.message.textColor = [UIColor darkGrayColor];
//                UIView *view = [cell1 viewWithTag:1001];
//                [view setBackgroundColor:[UIColor whiteColor]];
            }
            cell1.fbDelegate=self;
            [cell1 fillData:self.post];
            [cell1 setSelectedState:NO];
            
            return cell1;
        } else {
            SHFBImageFeedCell *cell2=[tableView dequeueReusableCellWithIdentifier:FBImageCell];
            if (cell2==nil) {
                cell2=[[SHFBImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBImageCell];
                
                cell2=[[SHFBImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FBNormalCell andNib:@"SHFBImageExpandedFeedDetailCell"];
                cell2.fbDelegate=self;
                cell2.userName.textColor = [UIColor blackColor];
                cell2.socialType.textColor = [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
                cell2.updatedTime.textColor = [UIColor lightGrayColor];
                cell2.message.textColor = [UIColor darkGrayColor];
//                UIView *view = [cell2 viewWithTag:1001];
//                [view setBackgroundColor:[UIColor whiteColor]];
            }
            [cell2 fillData:self.post];
            [cell2 setSelectedState:NO];
            
            return cell2;
        }
    } else if (self.post.socialType==TWITTER_POST) {
        //-Twitter mode
        if (self.post.pictureLink.length>2) {
            SHExpandImgeTWFeedCell *cell3=[tableView dequeueReusableCellWithIdentifier:TWExpandImageCell];
            if (cell3==nil) {
                cell3=[[SHExpandImgeTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHImageExpandedTWFeedDetailCell"];
                cell3.twDelegate=self;
                cell3.userName.textColor = [UIColor blackColor];
                cell3.socialType.textColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
                cell3.updatedTime.textColor = [UIColor lightGrayColor];
                cell3.message.textColor = [UIColor darkGrayColor];
//                UIView *view = [cell3 viewWithTag:1001];
//                [view setBackgroundColor:[UIColor whiteColor]];
            }
            [cell3 fillData:self.post];
            [cell3 setSelectedState:NO];
            
            return cell3;
        } else {
            SHExpandTWFeedCell *cell4=[tableView dequeueReusableCellWithIdentifier:TWExpandCell];
            if (cell4==nil) {
                cell4=[[SHExpandTWFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHExpandedTWFeedDetailCell"];
                cell4.twDelegate=self;
                cell4.userName.textColor = [UIColor blackColor];
                cell4.socialType.textColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
                cell4.updatedTime.textColor = [UIColor lightGrayColor];
                cell4.message.textColor = [UIColor darkGrayColor];
//                UIView *view = [cell4 viewWithTag:1001];
//                [view setBackgroundColor:[UIColor whiteColor]];
            }
            [cell4 fillData:self.post];
            [cell4 setSelectedState:NO];
            
            return cell4;
        }
    } else {
        //-Instagram image cell
        SHITImageFeedCell *cell5=[tableView dequeueReusableCellWithIdentifier:ITImageExpandCell];
        if (cell5==nil) {
            
            cell5=[[SHITImageFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWExpandCell andNib:@"SHITImageExpandedFeedDetailCell"];
            cell5.itDelegate=self;
            cell5.userName.textColor = [UIColor blackColor];
            cell5.socialType.textColor = [UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f];
            cell5.updatedTime.textColor = [UIColor lightGrayColor];
            cell5.message.textColor = [UIColor darkGrayColor];
//            UIView *view = [cell5 viewWithTag:1001];
//            [view setBackgroundColor:[UIColor whiteColor]];
        }
        [cell5 fillData:self.post];
        [cell5 setSelectedState:NO];
        
        return cell5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size = [self.post.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(kStandardCellTextWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat textHeight=size.height;
    if (self.post.socialType==FACEBOOK_POST) {
        //-Facebook
        if (self.post.postType==FBPlainStatus) {
                //                return kStandardCellHeight;
                return (textHeight+83+51); // 63
        } else {
                //                return kStandardImageCellHeight;
                return textHeight+kStandardImageCellImageViewHeight+83+51; // 173
        }
    } else if (self.post.socialType==TWITTER_POST) {
        //-Twitter & Instagram
        if (self.post.pictureLink.length>2) {
                //                return kStandardImageCellHeight;
                return textHeight+kStandardImageCellImageViewHeight+80+51;// Twitter image case
            
        } else {
                //  return kStandardCellHeight; // Twitter text case
                return textHeight+74+51;
            
        }
    } else {
        return textHeight+kInstagramImageCellImageViewHeight+80+51;
    }    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView reloadData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//    [responseData release];
//    [connection release];
//    [textView setString:@"Unable to fetch data"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[responseData
                                                   length]);
//    NSString *txt = [[NSString alloc] initWithData:responseData encoding: NSASCIIStringEncoding];
}

- (void)didGetFeedData {
    
}

@end
