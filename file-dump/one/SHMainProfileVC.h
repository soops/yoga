//
//  SHMainProfileVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARBaseVC.h"

@interface SHMainProfileVC : ARBaseVC<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *socialProfiles;
@end
