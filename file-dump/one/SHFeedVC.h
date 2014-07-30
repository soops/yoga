//
//  SHFeedVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARBaseVC.h"
#import "SHGetFeedData.h"
#import "PullTableView.h"
#import "SWTableViewCell.h"
#import "SHOneProfileDetailVC.h"

@interface SHFeedVC : ARBaseVC <getFeedDataDelegate, SWTableViewCellDelegate> {
    SHOneProfileDetailVC *oneDetail;
}
//-currently, mode=1 for Facebook, mode=2 for Twitter, mode=3 for Instagram
@property (nonatomic, assign) NSInteger mode;
- (IBAction)composeTapped:(id)sender;

@property (strong, nonatomic) IBOutlet PullTableView *feedTbView;
@property (assign, nonatomic) CATransform3D initialTransformation;

@end
