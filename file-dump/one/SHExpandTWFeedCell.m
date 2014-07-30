//
//  SHFeedCell.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHExpandTWFeedCell.h"
#import "FacebookServiceCommon.h"
#import "UIImageView+WebCache.h"

@implementation SHExpandTWFeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNib:(NSString *)nibName
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self=[[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
        self.profilePicture.layer.borderColor=[UIColor lightGrayColor].CGColor;
        self.profilePicture.layer.borderWidth=0.8f;
        self.profilePicture.layer.cornerRadius= self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds=YES;
        self.favoriteBtn.hidden=YES;
        self.retplyBtn.hidden=YES;
        self.retweetBtn.hidden=YES;
        self.subBgView.hidden=YES;
        
//        self.imageSet = SwipeCellImageSetMake([UIImage imageNamed:@"pac-man"], [UIImage imageNamed:@"blinky"], [UIImage imageNamed:@"ice-cream"], [UIImage imageNamed:@"balloons"]);
    }
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
//	self.imageSet = SwipeCellImageSetMake([UIImage imageNamed:@"pac-man"], [UIImage imageNamed:@"blinky"], [UIImage imageNamed:@"ice-cream"], [UIImage imageNamed:@"balloons"]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)retweetTapped:(id)sender {
    NSLog(@"retweet tapped");
    if (self.twDelegate && [self.twDelegate respondsToSelector:@selector(retweetDidSelect:)]) {
        [self.twDelegate retweetDidSelect:postIdREF];
    }
}

- (IBAction)favoriteTapped:(id)sender {
    NSLog(@"favorite tapped");
    if (self.twDelegate && [self.twDelegate respondsToSelector:@selector(favoriteDidSelect:)]) {
        [self.twDelegate favoriteDidSelect:postIdREF];
    }
}

- (IBAction)replyTapped:(id)sender {
    NSLog(@"reply tapped");
    if (self.twDelegate && [self.twDelegate respondsToSelector:@selector(replyDidSelect:)]) {
        [self.twDelegate replyDidSelect:postIdREF];
    }
}

- (void)fillData:(BBPost*)aPost {
    post = aPost;
    postIdREF=aPost.postId;
    [self.profilePicture setImageWithURL:[NSURL URLWithString:aPost.profileImageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    self.userName.text=aPost.userName;
    self.updatedTime.text=aPost.timeStamp;
    
    // to make strings starting with "@" a separate color
    NSArray *words = [aPost.message componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:aPost.message];
    for (NSString *word in words)
    {
        if([word hasPrefix:@"@"]) {
            NSRange range = [aPost.message rangeOfString:word];
            
            if (range.location != NSNotFound) {
                [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:89/255.0f green:132/255.0f blue:179/255.0f alpha:1.0f] range:NSMakeRange(range.location, range.length)];
            }
        }
        if([word hasPrefix:@"http"] || [word hasPrefix:@"www."]) {
            NSRange range = [aPost.message rangeOfString:word];
            
            if (range.location != NSNotFound) {
                [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] range:NSMakeRange(range.location, range.length)];
            }
        }
    }
    
    self.message.attributedText = str;
    [self.message sizeToFit];
    
    //-UI update
    if (aPost.likedByUser) {
        [self.favouriteImage setImage:[UIImage imageNamed:@"tw_favorite_blue"]];
    } else {
        [self.favouriteImage setImage:[UIImage imageNamed:@"twitter-favourite"]];
    }
}

- (void)setSelectedState:(BOOL)status {
    if (status) {
        
        self.userName.textColor=[UIColor blackColor];
        self.updatedTime.textColor=[UIColor lightGrayColor];
        self.message.textColor=[UIColor darkGrayColor];
        self.favoriteBtn.hidden=NO;
        self.retplyBtn.hidden=NO;
        self.retweetBtn.hidden=NO;
        self.subBgView.hidden=NO;
        self.backgroundColor=UIColorFromRGB(0x3b3b3b);
        self.contentView.backgroundColor=UIColorFromRGB(0x3b3b3b);
    } else {
//        self.userName.textColor=[UIColor blackColor];
//        self.updatedTime.textColor=[UIColor lightGrayColor];
//        self.message.textColor=[UIColor darkGrayColor];
//        self.favoriteBtn.hidden=YES;
//        self.retplyBtn.hidden=YES;
//        self.retweetBtn.hidden=YES;
//        self.subBgView.hidden=YES;
        self.backgroundColor=[UIColor whiteColor];
//        self.contentView.backgroundColor=[UIColor whiteColor];
        
    }
}

- (IBAction)tappedUsernameButton:(id)sender {
    if (self.twDelegate && [self.twDelegate respondsToSelector:@selector(usernameButtonDidClick:)]) {
        [self.twDelegate usernameButtonDidClick:post];
    }
}

@end
