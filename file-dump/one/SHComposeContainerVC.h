//
//  SHComposeContainerVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHComposeContainerVC : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic, assign) id delegate;

@end
