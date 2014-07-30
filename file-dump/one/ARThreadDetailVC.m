//
//  ARThreadDetailVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARThreadDetailVC.h"
#import "FacebookHelper.h"
#import "FacebookMessage.h"
#import "UIImageView+WebCache.h"
#import "WKFileHelper.h"
#import "TwitterMessage.h"
#import "RDRStickyKeyboardView.h"
#import "FHSTwitterEngine.h"
#import "NSString+Extensions.h"
#import "ARTwitterUser.h"

#define kTWMessageSavedFile                     @"TwitterMessageData"
#define kStandardCellTextWidth                  222

@interface ARThreadDetailVC ()<UITableViewDataSource,UITableViewDelegate,FacebookHelperDelegate> {
    NSMutableArray *messageArray;
}
@property (nonatomic) RDRStickyKeyboardView *keyboardView;
@end

@implementation ARThreadDetailVC

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
    messageArray=[[NSMutableArray alloc] init];
//    [self renderNavigationBarWithTitle:@"Message Thread"];
    UILabel *navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 200, 20)];
    navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
    navigationTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    navigationTitleLabel.backgroundColor = [UIColor clearColor];
    navigationTitleLabel.textColor = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0];
    navigationTitleLabel.text = self.name;
//    self.navigationController.navigationBar.topItem.titleView = navigationTitleLabel;
    self.navigationItem.titleView = navigationTitleLabel;
    
    // to remove the back button text
    self.navigationController.navigationBar.topItem.title = @"";
    
    //-for input toolbar
    self.keyboardView = [[RDRStickyKeyboardView alloc] initWithScrollView:self.threadTbView];
    self.keyboardView.frame = self.view.bounds;
    self.keyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.keyboardView.inputView.rightButton addTarget:self action:@selector(sendBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.keyboardView.inputViewScrollView.leftButton.hidden=YES;
    self.keyboardView.inputView.leftButton.hidden=YES;
    [self.view addSubview:self.keyboardView];
    
    //-Get thread detail
    if (self.socialMode==1) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getDetailInboxThread:self.threadID];
    } else if (self.socialMode==2) {
        //-load cached content
        NSString *filePath=[[WKFileHelper applicationDataDirectory] stringByAppendingPathComponent:kTWMessageSavedFile];
        if ([WKFileHelper isfileExisting:filePath]) {
            NSData *data=[NSData dataWithContentsOfFile:filePath];
            NSArray *dataArray=[NSKeyedUnarchiver unarchiveObjectWithData:data];
            for (TwitterMessage *aMessage in dataArray) {
                if ([self.threadID containsString:aMessage.senderId]&&[self.threadID containsString:aMessage.repicientId]) {
                    [messageArray addObject:aMessage];
                }
            }
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdTime" ascending:YES];
            [messageArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            
            [self.threadTbView reloadData];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    headerView.backgroundColor=[UIColor clearColor];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.socialMode==1) {
        //-facebook mode
        NSString *myFbId=[[FacebookHelper sharedInstance] getMeInfo].userId;
        FacebookMessage *aMessage=[messageArray objectAtIndex:indexPath.row];
        if ([myFbId isEqualToString:aMessage.friendId]) {
            UITableViewCell *cell1=[tableView dequeueReusableCellWithIdentifier:@"MyCell"];
            UIImageView *profileImage=(UIImageView *)[cell1 viewWithTag:1];
            NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,aMessage.friendId];
            [profileImage setImageWithURL:[NSURL URLWithString:urlSTR] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            profileImage.layer.cornerRadius=24;
            profileImage.layer.borderWidth=1;
            profileImage.layer.borderColor=[UIColor whiteColor].CGColor;
            profileImage.clipsToBounds=YES;
            UILabel *messageContent=(UILabel*)[cell1 viewWithTag:2];
            messageContent.text=aMessage.message;
            UILabel *bgLabel=(UILabel*)[cell1 viewWithTag:100];
            CGSize size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(205, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            [messageContent setFrame:CGRectMake(messageContent.frame.origin.x, messageContent.frame.origin.y, messageContent.frame.size.width, size.height+10)];
            [bgLabel setFrame:CGRectMake(bgLabel.frame.origin.x, bgLabel.frame.origin.y, bgLabel.frame.size.width, size.height+21)];
            bgLabel.layer.cornerRadius=2;
            
            return cell1;
        } else {
            UITableViewCell *cell2=[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
            UIImageView *profileImage=(UIImageView *)[cell2 viewWithTag:1];
            NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,aMessage.friendId];
            [profileImage setImageWithURL:[NSURL URLWithString:urlSTR] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            profileImage.layer.cornerRadius=24;
            profileImage.layer.borderWidth=1;
            profileImage.layer.borderColor=[UIColor whiteColor].CGColor;
            profileImage.clipsToBounds=YES;
            UILabel *messageContent=(UILabel*)[cell2 viewWithTag:2];
            messageContent.text=aMessage.message;
            
            CGSize size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(kStandardCellTextWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            [messageContent setFrame:CGRectMake(messageContent.frame.origin.x, messageContent.frame.origin.y, messageContent.frame.size.width, size.height+10)];
            
            UILabel *bgLabel=(UILabel*)[cell2 viewWithTag:100];
            [bgLabel setFrame:CGRectMake(bgLabel.frame.origin.x, bgLabel.frame.origin.y, bgLabel.frame.size.width, size.height+21)];
            bgLabel.layer.cornerRadius=2;
//            bgLabel.clipsToBounds=YES;
            
            return cell2;
        }
    } else {
        //-twitter mode
        TwitterMessage *aMessage=[messageArray objectAtIndex:indexPath.row];
        if ([aMessage.senderId isEqualToString:[[ARTwitterUser sharedInstance] userId]]) {
            UITableViewCell *cell1=[tableView dequeueReusableCellWithIdentifier:@"MyCell"];
            UIImageView *profileImage=(UIImageView *)[cell1 viewWithTag:1];
            [profileImage setImageWithURL:[NSURL URLWithString:aMessage.senderProfilePicture] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            profileImage.layer.cornerRadius=24;
            profileImage.layer.borderWidth=1;
            profileImage.layer.borderColor=[UIColor whiteColor].CGColor;
            profileImage.clipsToBounds=YES;
            UILabel *messageContent=(UILabel*)[cell1 viewWithTag:2];
            messageContent.text=aMessage.message;
            
            CGSize size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(205, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            [messageContent setFrame:CGRectMake(messageContent.frame.origin.x, messageContent.frame.origin.y, messageContent.frame.size.width, size.height)];
            UILabel *bgLabel=(UILabel*)[cell1 viewWithTag:100];
            [bgLabel setFrame:CGRectMake(bgLabel.frame.origin.x, bgLabel.frame.origin.y, bgLabel.frame.size.width, size.height+21)];
            bgLabel.layer.cornerRadius=2;
            
            return cell1;
        } else {
            UITableViewCell *cell2=[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
            UIImageView *profileImage=(UIImageView *)[cell2 viewWithTag:1];
            [profileImage setImageWithURL:[NSURL URLWithString:aMessage.senderProfilePicture] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            profileImage.layer.cornerRadius=24;
            profileImage.layer.borderWidth=1;
            profileImage.layer.borderColor=[UIColor whiteColor].CGColor;
            profileImage.clipsToBounds=YES;
            UILabel *messageContent=(UILabel*)[cell2 viewWithTag:2];
            messageContent.text=aMessage.message;
            
            CGSize size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(kStandardCellTextWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            [messageContent setFrame:CGRectMake(messageContent.frame.origin.x, messageContent.frame.origin.y, messageContent.frame.size.width, size.height)];
            UILabel *bgLabel=(UILabel*)[cell2 viewWithTag:100];
            [bgLabel setFrame:CGRectMake(bgLabel.frame.origin.x, bgLabel.frame.origin.y, bgLabel.frame.size.width, size.height+21)];
            bgLabel.layer.cornerRadius=2;
            
            return cell2;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 82;
    CGSize size;
    if (self.socialMode==1) {
        FacebookMessage *aMessage=[messageArray objectAtIndex:indexPath.row];
        if ([[[FacebookHelper sharedInstance] getMeInfo].userId isEqualToString:aMessage.friendId]) {
            size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(205, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        } else {
            size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(kStandardCellTextWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        }
        
    } else {
        TwitterMessage *aMessage=[messageArray objectAtIndex:indexPath.row];
        if([[[ARTwitterUser sharedInstance] userId] isEqualToString:aMessage.senderId]) {
            size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(205, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        } else {
            size = [aMessage.message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(kStandardCellTextWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        }
    }
    return size.height +60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - FacebookHelperDelegate
- (void) getMeInboxMessagesDidSuccess:(NSDictionary*)dic {
    NSArray *dataArray=[[dic objectForKey:@"comments"] objectForKey:@"data"];
    for (NSDictionary *dict in dataArray) {
        FacebookMessage *aMessage=[[FacebookMessage alloc] initWithJSONDic:dict];
        [messageArray addObject:aMessage];
    }
    
    [self.threadTbView reloadData];
}

- (void) getMeInboxMessagesDidFail:(NSError*)error {
    NSLog(@"error: %@",error.description);
}

#pragma mark - Internal methods


- (void)sendBtnTapped:(id)sender {
    if (self.socialMode==2) {
        //-twitter mode
        NSArray *subNames=[self.threadID componentsSeparatedByString:@"_"];
        NSString *repicientId=@"";
        for (NSString *userId in subNames) {
            if (![userId isEqualToString:[[ARTwitterUser sharedInstance] userId]]) {
                repicientId=userId;
            }
        }
        NSError *error=[[FHSTwitterEngine sharedEngine] sendDirectMessage:self.keyboardView.inputView.textView.text toUser:repicientId isID:YES];
        if (!error) {
//            [self showAlertMessage:@"send successfully"];
            
            //-save the new message
            TwitterMessage *firstMessage=[messageArray firstObject];
            TwitterMessage *newMessage=[[TwitterMessage alloc] init];
            newMessage.senderId=[[ARTwitterUser sharedInstance] userId];
            newMessage.senderName=[[ARTwitterUser sharedInstance] username];
            newMessage.senderProfilePicture=[[ARTwitterUser sharedInstance] profilePicture];
            newMessage.repicientId=repicientId;
            if ([firstMessage.senderId isEqualToString:[[ARTwitterUser sharedInstance] userId]]) {
                newMessage.repicientName=firstMessage.repicientName;
                newMessage.repicientProfilePicture=firstMessage.repicientProfilePicture;
            } else {
                newMessage.repicientName=firstMessage.senderName;
                newMessage.repicientProfilePicture=firstMessage.senderProfilePicture;
            }
            newMessage.message=self.keyboardView.inputView.textView.text;
            newMessage.createdTime=[NSDate date];
            
            //-reload on the tableview
            [messageArray addObject:newMessage];
            [self.threadTbView reloadData];
            self.keyboardView.inputView.textView.text=@"";
        }
    }
}

@end
