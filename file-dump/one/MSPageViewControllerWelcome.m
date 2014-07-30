//
//  MSPageViewController+Welcome.m
//  One
//
//  Created by Douglas Bumby on 2014-06-30.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "MSPageViewControllerWelcome.h"

@interface MSPageViewControllerIntro ()

@end

@implementation MSPageViewControllerIntro

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // styling
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)viewDidAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden=YES;
}

+ (void)initialize {
    if (self == MSPageViewControllerIntro.class) {
        UIPageControl *pageControl = UIPageControl.appearance;
        pageControl.pageIndicatorTintColor = UIColor.blackColor;
        pageControl.currentPageIndicatorTintColor = UIColor.redColor;
    }
}

- (NSArray *)pageIdentifiers {
    return @[@"page1", @"page2", @"page3", @"page4", @"page5"];
}



@end
