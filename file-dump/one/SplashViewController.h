//
//  SplashViewController.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHGetFeedData.h"

@interface SplashViewController : UIViewController <getFeedDataDelegate> {
    SHGetFeedData *getFeedData;
}

@end
