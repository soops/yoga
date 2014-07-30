//
//  SHGetFeedData.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookHelper.h"
#import "IGRequest.h"

@protocol getFeedDataDelegate;

@interface SHGetFeedData : NSObject <FacebookHelperDelegate,IGRequestDelegate> {
    int noOfAccounts;
}

@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) BOOL shouldRefresh;

- (void)loadSocialData;
- (void)loadFacebookData;
- (void)loadTwitterData;
- (void)loadInstagramData;
- (void)getCommentsForPost:(NSString *)postId;

@end

@protocol getFeedDataDelegate <NSObject>

- (void)didGetFeedData;

@end
