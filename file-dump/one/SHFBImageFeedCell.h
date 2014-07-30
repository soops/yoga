//
//  SHFBImageCell.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBPost.h"
#import "FacebookServiceCommon.h"
#import "SWTableViewCell.h"
#import "OBGradientView.h"

@protocol SHFBImageFeedCellDelegate <NSObject>

@optional
- (void)likeButtonDidClick:(NSString*)postId;
- (void)commentButtonDidClick:(NSString*)postId;
- (void)viewImageTapped:(NSString*)postId;
- (void)usernameButtonDidClick:(BBPost *)post;

@end

@interface SHFBImageFeedCell : SWTableViewCell {
    NSString *postId;
    BBPost *post;
}
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *socialType;
@property (strong, nonatomic) IBOutlet UILabel *updatedTime;
@property (strong, nonatomic) IBOutlet UIImageView *contentImage;
@property (strong, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) IBOutlet UIButton *likeIcon;
@property (strong, nonatomic) IBOutlet UIButton *commentIcon;
@property (strong, nonatomic) IBOutlet UILabel *likeNum;
@property (strong, nonatomic) IBOutlet UILabel *commentNum;
@property (strong, nonatomic) IBOutlet UIButton *btnView;
@property (nonatomic, assign) id<SHFBImageFeedCellDelegate> fbDelegate;
@property (weak, nonatomic) IBOutlet OBGradientView *gradientView;

- (IBAction)viewImageClicked:(id)sender;
- (void)fillData:(BBPost*)aPost;
- (void)setSelectedState:(BOOL)status;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNib:(NSString *)nibName;

@end
