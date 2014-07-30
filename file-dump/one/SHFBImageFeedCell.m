//
//  SHFBImageCell.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHFBImageFeedCell.h"
#import "UIImageView+WebCache.h"

@implementation SHFBImageFeedCell

#define kMessageLabelWidth 246

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNib:(NSString *)nibName
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self=[[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex:0];
        [self.likeIcon addTarget:self action:@selector(handleLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.commentIcon addTarget:self action:@selector(handleCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        
        //-styling the profile picture view
        self.profilePicture.layer.borderColor=[UIColor lightGrayColor].CGColor;
        self.profilePicture.layer.borderWidth=0.0f;
        self.profilePicture.layer.cornerRadius= self.profilePicture.frame.size.width / 2.0;
        self.profilePicture.clipsToBounds=YES;
        
//        self.contentImage.layer.cornerRadius= 9.0;
//        self.contentImage.clipsToBounds = YES;
//        self.contentImage.layer.cornerRadius= 0.5f;
//        self.contentImage.layer.borderWidth= 0.2f;
//        self.contentImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        
        self.contentImage.clipsToBounds=YES;
        
        self.likeIcon.hidden=YES;
        self.likeNum.hidden=YES;
        self.commentIcon.hidden=YES;
        self.commentNum.hidden=YES;
        
        //-add tap gesture for content image
        self.contentImage.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        tapGesture.numberOfTapsRequired=1;
        [self.contentImage addGestureRecognizer:tapGesture];
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

- (IBAction)viewImageClicked:(id)sender {
    if (self.fbDelegate && [self.fbDelegate respondsToSelector:@selector(viewImageTapped:)]) {
        [self.fbDelegate viewImageTapped:postId];
    }
}

- (void)imageTapped:(id)sender {
    if (self.fbDelegate && [self.fbDelegate respondsToSelector:@selector(viewImageTapped:)]) {
        [self.fbDelegate viewImageTapped:postId];
    }
}

- (void)fillData:(BBPost*)aPost {
    post = aPost;
    postId=aPost.postId;
    NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,aPost.userId];
    [self.profilePicture setImageWithURL:[NSURL URLWithString:urlSTR] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    self.userName.text=aPost.userName;
    self.socialType.text=@"facebook";
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
    self.commentNum.text=[NSString stringWithFormat:@"%d",aPost.numberOfComments];
    self.likeNum.text=[NSString stringWithFormat:@"%d",aPost.numberOfLikes];
    [self.contentImage setImageWithURL:[NSURL URLWithString:aPost.pictureLink] placeholderImage:nil];
    
    //-UI update
    if (aPost.likedByUser) {
        [self.likeIcon setImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
    } else {
        [self.likeIcon setImage:[UIImage imageNamed:@"white_heart.png"] forState:UIControlStateNormal];
    }
    
    CGSize size;
    size.height = 0;
    if(aPost.message.length != 0) {
        [self.message setHidden:FALSE];
        size = [aPost.message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(kMessageLabelWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
        [self.message setFrame:CGRectMake(67, 65, 246, size.height)];
        [self.contentImage setFrame:CGRectMake(0, 5 + size.height + 18, 246, 154)]; // y was 65
    } else {
        [self.message setHidden:TRUE];
        [self.contentImage setFrame:CGRectMake(0, 5 + size.height + 18, 246, 154)]; // y was 65
    }
    
    [self.message sizeToFit];
}

- (IBAction)handleLikeButton:(id)sender {
    if (self.fbDelegate && [self.fbDelegate respondsToSelector:@selector(likeButtonDidClick:)]) {
        [self.fbDelegate likeButtonDidClick:postId];
    }
}

- (IBAction)handleCommentButton:(id)sender {
    if (self.fbDelegate && [self.fbDelegate respondsToSelector:@selector(commentButtonDidClick:)]) {
        [self.fbDelegate commentButtonDidClick:postId];
    }
}

- (void)setSelectedState:(BOOL)status {
    if (status) {
        self.userName.textColor=[UIColor blackColor];
        self.updatedTime.textColor=[UIColor lightGrayColor];
        self.message.textColor=UIColorFromRGB(0x4d4d4d);
        self.likeNum.hidden=NO;
        self.likeIcon.hidden=NO;
        self.commentNum.hidden=NO;
        self.commentIcon.hidden=NO;
        self.btnView.hidden=NO;
        self.backgroundColor=UIColorFromRGB(0x3b3b3b);
        self.contentView.backgroundColor=UIColorFromRGB(0x3b3b3b);
    } else {
//        self.userName.textColor=[UIColor blackColor];
//        self.updatedTime.textColor=[UIColor lightGrayColor];
//        self.message.textColor=[UIColor darkGrayColor];
//        self.likeNum.hidden=YES;
//        self.likeIcon.hidden=YES;
//        self.commentNum.hidden=YES;
//        self.commentIcon.hidden=YES;
//        self.subBgView.hidden=YES;
//        self.btnView.hidden=YES;
        self.backgroundColor=[UIColor whiteColor];
//        self.contentView.backgroundColor=[UIColor whiteColor];
    }
}

- (IBAction)tappedUsernameButton:(id)sender {
    if (self.fbDelegate && [self.fbDelegate respondsToSelector:@selector(usernameButtonDidClick:)]) {
        [self.fbDelegate usernameButtonDidClick:post];
    }
}

@end