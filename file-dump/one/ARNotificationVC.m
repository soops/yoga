//
//  ARNotificationVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARNotificationVC.h"
#import "FacebookHelper.h"
#import "ARFBNotification.h"
#import "UIImageView+WebCache.h"
#import "NIAttributedLabel.h"

#define kFbUserPagePrefix                @"https://www.facebook.com"

@interface ARNotificationVC ()<UITableViewDataSource,UITableViewDelegate,FacebookHelperDelegate,NIAttributedLabelDelegate> {
    NSMutableArray *notifDataArray;
}

@end

@implementation ARNotificationVC

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
    notifDataArray=[[NSMutableArray alloc] init];
    [self renderNavigationBarWithTitle:@"Notifications"];
    
    //-Fetch notification here for facebook
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        [self showIndicatorWithMessage:@"Loading..."];
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getMeNotifications];
    }
    
    //-background colour
    self.view.backgroundColor=UIColorFromRGB(0xffffff);
    self.notifTbView.backgroundColor=[UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UItableviewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return notifDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *imageNotificationCell=@"ImageNotificationCell";
    static NSString *notificationCell=@"NotificationCell";
    ARFBNotification *fbNotification=[notifDataArray objectAtIndex:indexPath.row];
    if (fbNotification.thumbnailLink.length>2) {
        UITableViewCell *cell1=[tableView dequeueReusableCellWithIdentifier:imageNotificationCell];
        cell1.backgroundColor=[UIColor clearColor];
        cell1.contentView.backgroundColor=[UIColor clearColor];
        UIImageView *profilePicture=(UIImageView*)[cell1 viewWithTag:1];
        profilePicture.layer.cornerRadius=30;
        profilePicture.layer.borderWidth=1;
        profilePicture.layer.borderColor=[UIColor whiteColor].CGColor;
        profilePicture.clipsToBounds=YES;
        NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,fbNotification.friendId];
        [profilePicture setImageWithURL:[NSURL URLWithString:urlSTR] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
        //-content message with colored username
        NIAttributedLabel *message=(NIAttributedLabel*)[cell1 viewWithTag:2];
        message.delegate=self;
        message.userInteractionEnabled=YES;
        message.text=fbNotification.title;
        message.textColor=[UIColor lightGrayColor];
        NSRange userRange=NSMakeRange(0, fbNotification.friendName.length);
        NSString *userPageLink=[kFbUserPagePrefix stringByAppendingPathComponent:fbNotification.friendId];
        [message addLink:[NSURL URLWithString:userPageLink] range:userRange];
        message.autoDetectLinks=YES;
        
        //-thumbnail
        UIImageView *thumbnail=(UIImageView*)[cell1 viewWithTag:3];
        [thumbnail setImageWithURL:[NSURL URLWithString:fbNotification.thumbnailLink] placeholderImage:[UIImage imageNamed:@"notif_placeholder.png"]];
        
        return cell1;
    } else {
        UITableViewCell *cell2=[tableView dequeueReusableCellWithIdentifier:notificationCell];
        cell2.backgroundColor=[UIColor clearColor];
        cell2.contentView.backgroundColor=[UIColor clearColor];
        UIImageView *profilePicture=(UIImageView*)[cell2 viewWithTag:1];
        profilePicture.layer.cornerRadius=30;
        profilePicture.layer.borderWidth=1;
        profilePicture.layer.borderColor=[UIColor whiteColor].CGColor;
        profilePicture.clipsToBounds=YES;
        NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,fbNotification.friendId];
        [profilePicture setImageWithURL:[NSURL URLWithString:urlSTR] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        //-content message
        NIAttributedLabel *message=(NIAttributedLabel*)[cell2 viewWithTag:2];
        message.delegate=self;
        message.userInteractionEnabled=YES;
        message.text=fbNotification.title;
        message.textColor=[UIColor lightGrayColor];
        NSRange userRange=NSMakeRange(0, fbNotification.friendName.length);
        NSString *userPageLink=[kFbUserPagePrefix stringByAppendingPathComponent:fbNotification.friendId];
        [message addLink:[NSURL URLWithString:userPageLink] range:userRange];
        message.autoDetectLinks=YES;
        
        //-timestamp
        UILabel *timeStamp=(UILabel*)[cell2 viewWithTag:3];
        timeStamp.text=fbNotification.createdTime;
        
        return cell2;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ARFBNotification *fb_notification=[notifDataArray objectAtIndex:indexPath.row];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:fb_notification.targetLink]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - FacebookHelperDelegate
- (void) getNotificationsDidSuccess:(NSDictionary*)dic {
    [self stopIndicator];
    id data=[dic objectForKey:@"data"];
    if ([data isKindOfClass:[NSArray class]]) {
        for (NSDictionary *dict in data) {
            ARFBNotification *fbNotification=[[ARFBNotification alloc] initWithJSONDic:dict];
            [notifDataArray addObject:fbNotification];
        }
        [self.notifTbView reloadData];
    }
}

- (void) getNotificationsDidFail:(NSError*)error {
    [self stopIndicator];
}

#pragma mark - NIAttributeDelegate
- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point {
    NSLog(@"link tapped");
}

@end
