//
//  SHGetFeedData.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHGetFeedData.h"
#import "ARAppDelegate.h"
#import "FacebookHelper.h"
#import "BBPost.h"
#import "AROneHelper.h"
#import "AROneUser.h"
#import "ARTwitterUser.h"
#import "ARInstagramUser.h"
#import "SHConstant.h"

#define kInstagramFeedLimitConst                    @"20"

@implementation SHGetFeedData

- (void)loadSocialData {
    
    if(self.shouldRefresh) {
        [[ARAppDelegate application].feedDataArray removeAllObjects];
        [[ARAppDelegate application].facebookDataArray removeAllObjects];
        [[ARAppDelegate application].twitterDataArray removeAllObjects];
        [[ARAppDelegate application].instagramDataArray removeAllObjects];
    }
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"CAAHabzJccv4BAEo0xbTSe6mwwaYPSZCwhoWHR6qhZAz6uMxDejA2a4ojYHdBE0FU3DTuG2YkUQP0ZCvj6GrmMKJvtimi4VpC8ypb7XnWk8iLNBy4J8xUO0PLPEuPvkfcyXKJdGpPJYgYC6GvIw4pk9ALHce9gq8BGT5wKoZCdIYQmEeBPFOE23UAs3tZAuxikG0jRtc7ASE2xZCZCdqsJm0nxiJxh0i0oXUOhkACK9lCgZDZD" forKey:FB_ACCESSTOKEN];
//    [[NSUserDefaults standardUserDefaults] setObject:@"100003935562333" forKey:FB_USERID];
//    [[NSUserDefaults standardUserDefaults] setObject:@"Shinoj Qbthree" forKey:FB_USERNAME];
     NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESSTOKEN]; // [[WFFacebookUser sharedInstance] accessToken]
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    //-show indicator here if needed
    if (fbAccessToken != nil || [[FHSTwitterEngine sharedEngine] isAuthorized] || [appDelegate.instagram isSessionValid]) {
        //        [self showIndicatorWithMessage:@"Loading..."];
    } else {
//        [feedDataArray removeAllObjects];
//        [self.feedTbView reloadData];
        if([self.delegate respondsToSelector:@selector(didGetFeedData)]) {
            [self.delegate didGetFeedData];
        }
        return;
    }
    
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        noOfAccounts ++;
    }
    if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
        noOfAccounts ++;
    }
    if ([appDelegate.instagram isSessionValid]) {
        noOfAccounts ++;
    }
    
    
    //-load newsfeed from facebook // if ([[FacebookHelper sharedInstance] isUserAuthenticated])
   
    NSString *fbUserId = [[NSUserDefaults standardUserDefaults] objectForKey:FB_USERID]; // [[WFFacebookUser sharedInstance] userId]
    NSString *fbUserName = [[NSUserDefaults standardUserDefaults] objectForKey:FB_USERNAME]; // [[WFFacebookUser sharedInstance] username]
    if (fbAccessToken != nil) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getMeNewsFeedLimit:kFeedsLimit offset:kFeedsLimit*[ARAppDelegate application].pagingNumber];
        
        NSLog(@"fb token - %@, fb username - %@, fb id - %@, one token - %@", fbAccessToken, fbUserName, fbUserId, [[NSUserDefaults standardUserDefaults] valueForKey:ONE_EMAIL]);
        //-update facebook access token here
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                                [[NSUserDefaults standardUserDefaults] valueForKey:ONE_EMAIL],@"email",
                                fbUserId,@"fb_id",
                                fbUserName,@"fb_username",
                                fbAccessToken,@"fb_access_token",
                                @"2015-09-09",@"fb_expiration_date",
                                [ARAppDelegate application].fbInsertFlag,@"insertFlag",
                                nil];
        [[AROneHelper sharedInstance] updateFacebookAccessToken:userInfo];
    }
    
    //-load newsfeed from twitter
    if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
        [self getTwitterTimeline];
        //        [self showIndicatorWithMessage:@"Loading..."];
        //-update twitter access token here
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                                [[AROneUser sharedInstance] accessToken],@"token",
                                [[ARTwitterUser sharedInstance] userId],@"t_id",
                                [[ARTwitterUser sharedInstance] screenName],@"t_screen_name",
                                @"fake.consumer.key",@"t_consumer_key",
                                @"fake.consumer.secret.key",@"t_consumer_secret",
                                @"fake.auth.token.key",@"t_auth_token",
                                @"fake.auth.token.secret",@"t_auth_token_secret",
                                @"1",@"insertFlag",
                                nil];
        NSLog(@"userInfo: %@",userInfo);
        [[AROneHelper sharedInstance] updateTwitterAccessToken:userInfo];
    }
    
    //-load newsfeed from Instagram
    if ([appDelegate.instagram isSessionValid]) {
        NSString *methodName=[NSString stringWithFormat:@"users/self/feed?access_token=%@",[appDelegate.instagram accessToken]];
        NSMutableDictionary *params;
        if ([ARAppDelegate application].lastITPostId && ([ARAppDelegate application].lastITPostId.length!=0)) {
            params=[NSMutableDictionary dictionaryWithObjectsAndKeys:kInstagramFeedLimitConst,@"count",[ARAppDelegate application].lastITPostId,@"max_id", nil];
        } else {
            params=[NSMutableDictionary dictionaryWithObjectsAndKeys:kInstagramFeedLimitConst,@"count", nil];
        }
        [appDelegate.instagram requestWithMethodName:methodName params:params httpMethod:@"GET" delegate:self];
        
        //-update instagram access token here
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                                [[AROneUser sharedInstance] accessToken],@"token",
                                [[ARInstagramUser sharedInstance] userId],@"i_id",
                                [[ARInstagramUser sharedInstance] username],@"i_username",
                                [[ARInstagramUser sharedInstance] accessToken],@"i_access_token",
                                @"1",@"insertFlag",
                                nil];
        [[AROneHelper sharedInstance] updateInstagramAccessToken:userInfo];
    }
}

- (void)loadFacebookData {
    //-load newsfeed from facebook
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getMeNewsFeedLimit:kFeedsLimit offset:kFeedsLimit*[ARAppDelegate application].pagingNumber];
        
        //-update facebook access token here
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                                [[AROneUser sharedInstance] accessToken],@"token",
                                [[ARFacebookUser sharedInstance] userId],@"fb_id",
                                [[ARFacebookUser sharedInstance] username],@"fb_username",
                                [[ARFacebookUser sharedInstance] accessToken],@"fb_access_token",
                                @"2015-09-09",@"fb_expiration_date",
                                @"1",@"insertFlag",
                                nil];
        [[AROneHelper sharedInstance] updateFacebookAccessToken:userInfo];
    }
}

- (void)loadTwitterData {
    //-load newsfeed from twitter
    if ([[FHSTwitterEngine sharedEngine] isAuthorized]) {
        [self getTwitterTimeline];
        //        [self showIndicatorWithMessage:@"Loading..."];
        //-update twitter access token here
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                                [[AROneUser sharedInstance] accessToken],@"token",
                                [[ARTwitterUser sharedInstance] userId],@"t_id",
                                [[ARTwitterUser sharedInstance] screenName],@"t_screen_name",
                                @"fake.consumer.key",@"t_consumer_key",
                                @"fake.consumer.secret.key",@"t_consumer_secret",
                                @"fake.auth.token.key",@"t_auth_token",
                                @"fake.auth.token.secret",@"t_auth_token_secret",
                                @"1",@"insertFlag",
                                nil];
        NSLog(@"userInfo: %@",userInfo);
        [[AROneHelper sharedInstance] updateTwitterAccessToken:userInfo];
    }
}

- (void)loadInstagramData {
    //-load newsfeed from Instagram
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.instagram isSessionValid]) {
        NSString *methodName=[NSString stringWithFormat:@"users/self/feed?access_token=%@",[appDelegate.instagram accessToken]];
        NSMutableDictionary *params;
        if ([ARAppDelegate application].lastITPostId && ([ARAppDelegate application].lastITPostId.length!=0)) {
            params=[NSMutableDictionary dictionaryWithObjectsAndKeys:kInstagramFeedLimitConst,@"count",[ARAppDelegate application].lastITPostId,@"max_id", nil];
        } else {
            params=[NSMutableDictionary dictionaryWithObjectsAndKeys:kInstagramFeedLimitConst,@"count", nil];
        }
        [appDelegate.instagram requestWithMethodName:methodName params:params httpMethod:@"GET" delegate:self];
        
        //-update instagram access token here
        NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:
                                [[AROneUser sharedInstance] accessToken],@"token",
                                [[ARInstagramUser sharedInstance] userId],@"i_id",
                                [[ARInstagramUser sharedInstance] username],@"i_username",
                                [[ARInstagramUser sharedInstance] accessToken],@"i_access_token",
                                @"1",@"insertFlag",
                                nil];
        [[AROneHelper sharedInstance] updateInstagramAccessToken:userInfo];
    }
}

- (void)getTwitterTimeline {
    //-Load newsfeed for twitter
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //-Fetch home timeline
            id result;
            NSLog(@"lastTwitterPostId: %@",[ARAppDelegate application].lastTwitterPostId);
            if ([ARAppDelegate application].lastTwitterPostId && ([ARAppDelegate application].lastTwitterPostId.length!=0)) {
                //                result=[[FHSTwitterEngine sharedEngine] getHomeTimelineSinceID:lastTwitterPostId count:kFeedsLimit];
                result=[[FHSTwitterEngine sharedEngine] getHomeTimelineMaxID:[ARAppDelegate application].lastTwitterPostId count:kFeedsLimit];
            } else {
                result=[[FHSTwitterEngine sharedEngine] getHomeTimelineMaxID:@"" count:kFeedsLimit];
            }
            if ([result isKindOfClass:[NSArray class]]) {
                for (NSDictionary *postDict in (NSArray*)result) {
                    BBPost *aPost=[[BBPost alloc] initWithTwitterDic:postDict];
                    [[ARAppDelegate application].feedDataArray addObject:aPost];
                    [[ARAppDelegate application].twitterDataArray addObject:aPost];
                    [ARAppDelegate application].lastTwitterPostId=aPost.postId;//-last post id
                }
                //-re-arrange posts by time here
                [self rearrangePostsByTime];
                dispatch_sync(dispatch_get_main_queue(), ^{
//                    [self.feedTbView reloadData];
                    noOfAccounts --;
                    if(noOfAccounts <= 0) {
//                        [self.feedTbView setHidden:NO];
//                        [self viewWillAppear:YES];
                        if([self.delegate respondsToSelector:@selector(didGetFeedData)]) {
                            [self.delegate didGetFeedData];
                        }
                    }
                });
            } else if ([result isKindOfClass:[NSDictionary class]]) {
                NSLog(@"Dictionary class");
                [ARAppDelegate application].lastTwitterPostId=@"";
            } else {
                [ARAppDelegate application].lastTwitterPostId=@"";
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                //                [self stopIndicator];
            });
        }
    });
}

#pragma mark - FacebookDelegate
- (void) getNewsFeedDidSuccess:(NSDictionary*)dict {
    //    [self stopIndicator];
    NSArray *dataArray = (NSArray*)[dict objectForKey:@"data"];
    if (dataArray.count>0) {
        [ARAppDelegate application].pagingNumber++;//increase paging number for the next page
        for(id dict in dataArray){
            if ([dict isKindOfClass:[NSDictionary class]]) {
                BBPost *bbPost = [[BBPost alloc] initWithJSONDic:dict];
                if ((bbPost.postType != MISC) && bbPost) {
                    [[ARAppDelegate application].feedDataArray addObject:bbPost];
                    [[ARAppDelegate application].facebookDataArray addObject:bbPost];
                }
            }
        }
        [self rearrangePostsByTime];
//        [self.feedTbView reloadData];
        noOfAccounts --;
        if(noOfAccounts <= 0) {
//            [self.feedTbView setHidden:NO];
//            [self viewWillAppear:YES];
            if([self.delegate respondsToSelector:@selector(didGetFeedData)]) {
                [self.delegate didGetFeedData];
            }
        }
    }
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(IGRequest *)request didLoad:(id)result {
    //    [self stopIndicator];
    NSString *requestURL=[request url];
    if ([requestURL rangeOfString:@"likes"].location!=NSNotFound) {
        //-like request
//        if (currentIndex<feedDataArray.count) {
//            BBPost *aPost=[feedDataArray objectAtIndex:currentIndex];
//            aPost.likedByUser=!aPost.likedByUser;
//            if (aPost.likedByUser) {
//                aPost.numberOfLikes+=1;
//            } else {
//                aPost.numberOfLikes-=1;
//            }
//            NSIndexPath *indexPath=[NSIndexPath indexPathForItem:currentIndex inSection:0];
//            [self.feedTbView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            id currentCell=[self.feedTbView cellForRowAtIndexPath:indexPath];
//            if ([currentCell isKindOfClass:[SHITImageFeedCell class]]) {
//                //                [(SHITImageFeedCell*)currentCell setSelectedState:YES];
//            } else if ([ currentCell isKindOfClass:[SHITNormalFeedCell class]]) {
//                //                [(SHITNormalFeedCell*)currentCell setSelectedState:YES];
//            }
//        }
//        currentIndex=-1;
    } else if ([requestURL rangeOfString:@"comments"].location!=NSNotFound) {
        //-comment request
        NSLog(@"instagram response: %@",[request responseText]);
    } else if ([requestURL rangeOfString:@"feed"].location!=NSNotFound) {
        //-feed request
        NSArray *dataArray=[result objectForKey:@"data"];
        for (NSDictionary *aDict in dataArray) {
            BBPost *aPost=[[BBPost alloc] initWithInstagramDic:aDict];
            if (aPost!=nil) {
                [[ARAppDelegate application].feedDataArray addObject:aPost];
                [[ARAppDelegate application].instagramDataArray addObject:aPost];
                [ARAppDelegate application].lastITPostId=aPost.postId;
            }
        }
        //-re-arrange posts by time here
        [self rearrangePostsByTime];
//        [self.feedTbView reloadData];
        noOfAccounts --;
        if(noOfAccounts <= 0) {
//            [self.feedTbView setHidden:NO];
//            [self viewWillAppear:YES];
            if([self.delegate respondsToSelector:@selector(didGetFeedData)]) {
                [self.delegate didGetFeedData];
            }
        }
    }
}

- (void)rearrangePostsByTime {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedTime" ascending:NO];
    [[ARAppDelegate application].feedDataArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [[ARAppDelegate application].facebookDataArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [[ARAppDelegate application].twitterDataArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [[ARAppDelegate application].instagramDataArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)getCommentsForPost:(NSString *)postId {
    if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
        [FacebookHelper sharedInstance].fbDelegate=self;
        [[FacebookHelper sharedInstance] getCommentsForPost:postId];
    }
}

@end
