//
//  ARProfileVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARBaseVC.h"
#import "PullTableView.h"
#import "FXPageControl.h"

@interface ARProfileVC : ARBaseVC
@property (strong, nonatomic) IBOutlet PullTableView *profileTbView;
@property (nonatomic, assign) NSInteger pageIndex;
//-1 for facebook, 2 for twitter and 3 for instagram
@property (nonatomic, assign) NSInteger socialAccountMode;
@property (nonatomic, assign) BOOL isMyProfile;

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
@property (nonatomic, weak) IBOutlet FXPageControl *customPageControl;

- (void)LoadProfile;
- (void)refreshTableViewData;
@end
