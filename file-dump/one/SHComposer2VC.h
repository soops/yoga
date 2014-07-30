//
//  SHComposer2VC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARBaseVC.h"

@protocol SHComposer2VCDelegate <NSObject>

@optional
- (void)didPostWithTextContent:(NSString*)inputText;
- (void)didPostWithTextContent:(NSString*)inputText facebook:(BOOL)fFacebook twitter:(BOOL)fTwitter instagram:(BOOL)fInstagram;
- (void)didPostWithTextContent:(NSString*)inputText image:(UIImage*)image facebook:(BOOL)fFacebook twitter:(BOOL)fTwitter instagram:(BOOL)fInstagram;
@end

@interface SHComposer2VC : ARBaseVC
@property (strong,nonatomic) UIImage *bgImage;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (strong, nonatomic) IBOutlet UIImageView *bgBlurView;
@property (strong, nonatomic) IBOutlet UITextView *textViewInput;
@property (nonatomic, assign) id<SHComposer2VCDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIView *inputContainer;
- (IBAction)postTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)cameraTapped:(id)sender;
- (IBAction)peopleTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *limitLb;
@property (strong, nonatomic) IBOutlet UIButton *btnCamera;
@property (strong, nonatomic) IBOutlet UIButton *btnPeople;

@end
