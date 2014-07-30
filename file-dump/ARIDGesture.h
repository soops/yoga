//
//  ARIDGesture.h
//  Project One
//
//  Created by Douglas Bumby
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBPost.h"

@interface ARIDGesture : UITapGestureRecognizer
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, assign) SOCIAL_TYPE type; //@"facebook",@"twitter",@"instagram"
@property (nonatomic, assign) BOOL likeStatus;
@end
