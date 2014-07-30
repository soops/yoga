//
//  SHOneProfileDetailVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARBaseVC.h"
#import "BBPost.h"
#import "PullTableView.h"

@interface SHOneProfileDetailVC : ARBaseVC
@property (nonatomic, assign) NSInteger socialType;
@property (nonatomic, strong) BBPost *userBBPost;
@property (nonatomic, strong) NSString *screenName;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *designationLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbFriendsCountLabel;
@property (weak, nonatomic) IBOutlet UIView *butttonsContainerView;
@property (weak, nonatomic) IBOutlet UILabel *postsOrTweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsOrTweetsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet PullTableView *profileTbView;

@end
