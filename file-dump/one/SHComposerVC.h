//
//  SHComposerVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARBaseVC.h"

@protocol SHComposerVCDelegate <NSObject>

@optional
- (void)didPostWithTextContent:(NSString*)inputText;
- (void)didPostWithTextContent:(NSString*)inputText facebook:(BOOL)fFacebook twitter:(BOOL)fTwitter instagram:(BOOL)fInstagram;
@end

@interface SHComposerVC : ARBaseVC
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, assign) id<SHComposerVCDelegate> delegate;
- (IBAction)cancelTapped:(id)sender;
- (IBAction)postTapped:(id)sender;

@end
