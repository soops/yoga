//
//  ARMessageVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARMessageVC.h"
#import "FacebookHelper.h"
#import "ARFBInboxThread.h"
#import "TwitterMessage.h"
#import "UIImageView+WebCache.h"
#import "ARThreadDetailVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FHSTwitterEngine.h"
#import "WKFileHelper.h"
#import "ARFacebookUser.h"
#import "ARTWInboxThread.h"


#define kTwitterDirectMessageLimit              100
#define kSectionTitle                           @"title"
#define kSectionData                            @"data"
#define kTWMessageSavedFile                     @"TwitterMessageData"
#define kSentTWMEssageSavedFile                 @"TwitterSentMessageData"

#define SECOND 1
#define MINUTE (60 * SECOND)
#define HOUR (60 * MINUTE)
#define DAY (24 * HOUR)
#define MONTH (30 * DAY)

@interface ARMessageVC ()<UITableViewDataSource,UITableViewDelegate,FacebookHelperDelegate> {
    NSMutableArray *inboxThreadArray;
    NSString *threadREF;
    NSInteger socialMode;//-1 for facebook, 2 for twitter
    NSString *selectedUsername;
}

@end

@implementation ARMessageVC

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
    inboxThreadArray=[[NSMutableArray alloc] init];
    [self renderNavigationBarWithTitle:@"Messages" andLeftIcon:@"placeholder" andRightIcon:@"edit_selected"];
    socialMode=0;
}

- (void)viewWillAppear:(BOOL)animated {
//    [self getInboxData];
}

- (void)viewDidAppear:(BOOL)animated {
    [inboxThreadArray removeAllObjects];
    [self getInboxData];
}

- (void)getInboxData {
    //-load twitter messages
//    [inboxThreadArray removeAllObjects];
    if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
        NSMutableArray *associatedArray=[[NSMutableArray alloc] init];
        //-get direct messages
        id result=[[FHSTwitterEngine sharedEngine] getDirectMessages:kTwitterDirectMessageLimit];
        if ([result isKindOfClass:[NSArray class]]) {
            for (NSDictionary *aDict in (NSArray*)result) {
                TwitterMessage *aTwMessage=[[TwitterMessage alloc] initWithTwitterJSONDic:aDict];
                [associatedArray addObject:aTwMessage];
            }
        }
        //-get sent direct message
        id sentResult=[[FHSTwitterEngine sharedEngine] getSentDirectMessages:kTwitterDirectMessageLimit];
        if ([sentResult isKindOfClass:[NSArray class]]) {
            for (NSDictionary *aDict in (NSArray*)sentResult) {
                TwitterMessage *aTwMessage=[[TwitterMessage alloc] initWithTwitterJSONDic:aDict];
                [associatedArray addObject:aTwMessage];
            }
        }
        //-filter results here
        //-tagging all messages
        for (int counter=0; counter<associatedArray.count; counter++) {
            TwitterMessage *twMsg=[associatedArray objectAtIndex:counter];
            if (twMsg.threadTag==-1) {
                twMsg.threadTag=counter;
                for (int nextPos=(counter+1); nextPos<associatedArray.count; nextPos++) {
                    TwitterMessage *nextTwMsg=[associatedArray objectAtIndex:nextPos];
                    if (nextTwMsg.threadTag==-1) {
                        if (([twMsg.senderId isEqualToString:nextTwMsg.repicientId]&&[twMsg.repicientId isEqualToString:nextTwMsg.senderId])||([twMsg.senderId isEqualToString:nextTwMsg.senderId]&&[twMsg.repicientId isEqualToString:nextTwMsg.repicientId])) {
                            nextTwMsg.threadTag=twMsg.threadTag;
                        }
                    } else {
                        continue;
                    }
                }
            } else {
                continue;
            }
        }
        //-here all the messages have been tagged, now we turn them into groups
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"threadTag" ascending:YES];
        [associatedArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        //-create thread objects
//        NSMutableArray *threadArray=[[NSMutableArray alloc] init];
        for (int counter=0; counter<associatedArray.count; counter++) {
            TwitterMessage *twMsg=[associatedArray objectAtIndex:counter];
            ARTWInboxThread *twThread=[[ARTWInboxThread alloc] init];
            twThread.threadId=[NSString stringWithFormat:@"%@_%@",twMsg.senderId,twMsg.repicientId];
            twThread.firstSpeakerId=twMsg.senderId;
            twThread.firstSpeakerName=twMsg.senderName;
            twThread.firstSpeakerProfilePicture=twMsg.senderProfilePicture;
            twThread.secondSpeakerId=twMsg.repicientId;
            twThread.secondSpeakerName=twMsg.repicientName;
            twThread.secondSpeakerProfilePicture=twMsg.repicientProfilePicture;
            twThread.lastMessage=twMsg.message;
            twThread.createdTime=twMsg.createdTime;
            if (counter==0) {
//                [threadArray addObject:twThread];
                [inboxThreadArray addObject:twThread];
            } else {
                TwitterMessage *preMsg=[associatedArray objectAtIndex:(counter-1)];
                if (preMsg.threadTag != twMsg.threadTag) {
//                    [threadArray addObject:twThread];
                    [inboxThreadArray addObject:twThread];
                }
            }
        }
        
        //-save to file
        NSString *filePath=[[WKFileHelper applicationDataDirectory] stringByAppendingPathComponent:kTWMessageSavedFile];
        [NSKeyedArchiver archiveRootObject:associatedArray toFile:filePath];
        
//        NSDictionary *sectionDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Twitter Inbox",kSectionTitle,threadArray,kSectionData, nil];
//        [inboxThreadArray addObject:sectionDict];
        [self rearrangePostsByTime];
        [self.inboxThreadTbView reloadData];
    }
    
    //-load facebook messages
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        //        [self showIndicatorWithMessage:@"Loading..."];
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getMeInboxMessages];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    NSDictionary *sectionDict=[inboxThreadArray objectAtIndex:section];
//    return [sectionDict objectForKey:kSectionTitle];
//}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return inboxThreadArray.count;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSDictionary *sectionDict=[inboxThreadArray objectAtIndex:section];
//    NSArray *messageArray=[sectionDict objectForKey:kSectionData];
//    return messageArray.count;
    
    return [inboxThreadArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSDictionary *sectionDict=[inboxThreadArray objectAtIndex:indexPath.section];
//    NSArray *sectionData=[sectionDict objectForKey:kSectionData];
//    id cellData=[sectionData objectAtIndex:indexPath.row];
    id cellData = [inboxThreadArray objectAtIndex:indexPath.row];
    if ([cellData isKindOfClass:[ARFBInboxThread class]]) {
        //-facebook case
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
//        SHFBInboxThread *aThread=[sectionData objectAtIndex:indexPath.row];
        ARFBInboxThread *aThread=[inboxThreadArray objectAtIndex:indexPath.row];
        UIImageView *profilePicture=(UIImageView*)[cell viewWithTag:1];
        profilePicture.layer.cornerRadius=24;
        profilePicture.layer.borderWidth=1;
        profilePicture.layer.borderColor=[UIColor whiteColor].CGColor;
        profilePicture.clipsToBounds=YES;
        
        NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,aThread.friendIds.firstObject];
        [profilePicture setImageWithURL:[NSURL URLWithString:urlSTR] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        UILabel *userName=(UILabel*)[cell viewWithTag:2];
        userName.text=@"";
        for (NSString *a_name in aThread.friendNames) {
            ARFacebookUser *fbUser=[[FacebookHelper sharedInstance] getMeInfo];
            NSInteger usIndex=[aThread.friendNames indexOfObject:a_name];
            if ([fbUser.userId isEqualToString:[aThread.friendIds objectAtIndex:usIndex]]) {
                continue;
            }
            userName.text=[userName.text stringByAppendingString:[NSString stringWithFormat:@"%@,",a_name]];
            //-remove the last character (comma)
            userName.text=[userName.text substringToIndex:userName.text.length-1];
        }
        
        UILabel *message=(UILabel*)[cell viewWithTag:3];
        message.text=aThread.lastMessage;
        [message sizeToFit];
        UILabel *timeStamp=(UILabel*)[cell viewWithTag:4];
//        NSDateFormatter *fr = [[NSDateFormatter alloc] init];
//        [fr setTimeZone:[NSTimeZone systemTimeZone]];
//        [fr setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
//        NSDate *date = [fr dateFromString:aThread.createdTime];
        timeStamp.text = [self timeIntervalWithStartDate:aThread.createdTime withEndDate:[NSDate date]];
        UILabel *mediaName = (UILabel*)[cell viewWithTag:5];
        mediaName.text = @"Facebook";
        mediaName.textColor = [UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f];
        
        return cell;
    } else {
        //-twitter case
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
//        SHTWMessage *aMessage=[sectionData objectAtIndex:indexPath.row];
//        SHTWInboxThread *twThread=[sectionData objectAtIndex:indexPath.row];
        ARTWInboxThread *twThread=[inboxThreadArray objectAtIndex:indexPath.row];
        UIImageView *profilePicture=(UIImageView*)[cell viewWithTag:1];
        profilePicture.layer.cornerRadius=24;
        profilePicture.layer.borderWidth=1;
        profilePicture.layer.borderColor=[UIColor whiteColor].CGColor;
        profilePicture.clipsToBounds=YES;
        [profilePicture setImageWithURL:[NSURL URLWithString:twThread.firstSpeakerProfilePicture] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        UILabel *userName=(UILabel*)[cell viewWithTag:2];
        userName.text=[NSString stringWithFormat:@"@%@",twThread.firstSpeakerName];
        UILabel *message=(UILabel*)[cell viewWithTag:3];
        message.text=twThread.lastMessage;
        [message sizeToFit];
        UILabel *timeStamp=(UILabel*)[cell viewWithTag:4];
        timeStamp.text = [self timeIntervalWithStartDate:twThread.createdTime withEndDate:[NSDate date]];
        UILabel *mediaName = (UILabel*)[cell viewWithTag:5];
        mediaName.text = @"Twitter";
        mediaName.textColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
//    NSDictionary *sectionDict=[inboxThreadArray objectAtIndex:indexPath.section];
//    NSArray *sectionData=[sectionDict objectForKey:kSectionData];
//    id cellData=[sectionData objectAtIndex:indexPath.row];
    id cellData=[inboxThreadArray objectAtIndex:indexPath.row];
    if ([cellData isKindOfClass:[ARFBInboxThread class]]) {
        //-facebook mode
        ARFBInboxThread *aThread=(ARFBInboxThread*)cellData;
        threadREF=aThread.threadId;
        socialMode=1;
    } else {
        //-currently twitter mode
        socialMode=2;
        ARTWInboxThread *aTwThread=(ARTWInboxThread*)cellData;
        threadREF=aTwThread.threadId;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *userName=(UILabel*)[cell viewWithTag:2];
    selectedUsername = userName.text;
    [self performSegueWithIdentifier:@"ShowMessageThread" sender:self];
}

//-Override this method of super class
- (void)rightBarButtonTapped:(id)sender {
    NSLog(@"start writing message here");
    
//    FB.ui({ method: 'feed',
//    message: 'msg',
//    name: 'name',
//    link: 'your link',
//    picture: 'your pic',
//    caption: 'caption',
//    description: 'desc',
//    display: 'touch' // TAKE NOTE
//    });
//    FB.ui
    
    /*
    UIWebView *webView=[[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:webView];
    NSString *jvString=@"FB.ui({ method: 'feed',message: 'msg',name: 'name',link: 'your link',picture: 'your pic',caption: 'caption',description: 'desc',display: 'touch'});";
    [webView stringByEvaluatingJavaScriptFromString:jvString];
     */
}

- (void)leftBarButtonTapped:(id)sender {
}

#pragma mark - FacebookHelperDelegate
- (void) getMeInboxMessagesDidSuccess:(NSDictionary*)dic {
    [self stopIndicator];
    id data=[dic objectForKey:@"data"];
    if ([data isKindOfClass:[NSArray class]]) {
//        NSMutableArray *fbMessages=[NSMutableArray array];
        for (NSDictionary *dict in data) {
            ARFBInboxThread *fbThread=[[ARFBInboxThread alloc] initWithJSONDic:dict];
//            [fbMessages addObject:fbThread];
            [inboxThreadArray addObject:fbThread];
        }
//        NSDictionary *sectionDict=[NSDictionary dictionaryWithObjectsAndKeys:@"Facebook Inbox",kSectionTitle,fbMessages,kSectionData, nil];
//        [inboxThreadArray addObject:sectionDict];
        [self rearrangePostsByTime];
        [self.inboxThreadTbView reloadData];
    }
}

- (void) getMeInboxMessagesDidFail:(NSError*)error {
    [self stopIndicator];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ARThreadDetailVC *destinationVC=segue.destinationViewController;
    destinationVC.name = selectedUsername;
    if (socialMode==1) {
        //-facebook
        destinationVC.threadID=threadREF;
        destinationVC.socialMode=socialMode;
        socialMode=-1;
    } else if (socialMode==2) {
        destinationVC.threadID=threadREF;
        destinationVC.socialMode=socialMode;
        socialMode=-1;
    } else {
        socialMode=-1;
    }
}

- (NSString*)timeIntervalWithStartDate:(NSDate*)d1 withEndDate:(NSDate*)d2
{
    //Calculate the delta in seconds between the two dates
    NSTimeInterval delta = [d2 timeIntervalSinceDate:d1];
    
    if (delta < 1 * MINUTE) {
        return delta == 1 ? @"1s" : [NSString stringWithFormat:@"%d sec", (int)delta];
    }
    if (delta < 2 * MINUTE) {
        return @"1m";
    }
    if (delta < 45 * MINUTE) {
        int minutes = floor((double)delta/MINUTE);
        return [NSString stringWithFormat:@"%dm", minutes];
    }
    if (delta < 90 * MINUTE) {
        return @"1h";
    }
    if (delta < 24 * HOUR) {
        int hours = floor((double)delta/HOUR);
        return [NSString stringWithFormat:@"%dh", hours];
    }
    if (delta < 48 * HOUR) {
        return @"1d";
    }
    if (delta < 30 * DAY) {
        int days = floor((double)delta/DAY);
        return [NSString stringWithFormat:@"%dd", days];
    }
    if (delta < 12 * MONTH) {
        int months = floor((double)delta/MONTH);
        return months <= 1 ? @"1 month" : [NSString stringWithFormat:@"%dm", months];
    } else {
        int years = floor((double)delta/MONTH/12.0);
        return years <= 1 ? @"1 year" : [NSString stringWithFormat:@"%dy", years];
    }
}

- (void)renderNavigationBarWithTitle:(NSString *)barTitle andLeftIcon:(NSString*)leftIcon andRightIcon:(NSString*)rightIcon {
    if (leftIcon) {
        UIImage *imageLeft=[UIImage imageNamed:leftIcon];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.bounds = CGRectMake(0, 0, imageLeft.size.width, imageLeft.size.height);
        [btn setImage:imageLeft forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(leftBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    if (rightIcon) {
        UIImage *imageRight=[UIImage imageNamed:rightIcon];
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.bounds = CGRectMake(0, 0, 30, 27);
        [btn2 setImage:imageRight forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    }
    
    self.title = barTitle;
}

- (void)rearrangePostsByTime {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdTime" ascending:YES];
    [inboxThreadArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

@end
