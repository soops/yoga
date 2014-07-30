//
//  SHFeedCell.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBPost.h"
#import "ExampleCell.h"
#import "SWTableViewCell.h"
#import "OBGradientView.h"

@protocol SHExpandTWFeedCellDelegate <NSObject>

@optional
- (void)favoriteDidSelect:(NSString*)postId;
- (void)retweetDidSelect:(NSString*)postId;
- (void)replyDidSelect:(NSString*)postId;
- (void)usernameButtonDidClick:(BBPost *)post;

@end

@interface SHExpandTWFeedCell: SWTableViewCell {
    NSString *postIdREF;
    BBPost *post;
}
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIImageView *favouriteImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *socialType;
@property (strong, nonatomic) IBOutlet UILabel *updatedTime;
@property (strong, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) IBOutlet UIButton *retplyBtn;
@property (strong, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (strong, nonatomic) IBOutlet UIButton *retweetBtn;
@property (strong, nonatomic) IBOutlet UIView *subBgView;
@property (nonatomic, assign) id<SHExpandTWFeedCellDelegate> twDelegate;
@property (weak, nonatomic) IBOutlet OBGradientView *gradientView;

- (IBAction)retweetTapped:(id)sender;
- (IBAction)favoriteTapped:(id)sender;
- (IBAction)replyTapped:(id)sender;

- (void)fillData:(BBPost*)aPost;
- (void)setSelectedState:(BOOL)status;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNib:(NSString *)nibName;

@end
