//
//  SHContainerVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHContainerVC.h"
#import "SHFeedVC.h"
#import "ARAppDelegate.h"
#import "SplashViewController.h"
#import "SHConstant.h"

@interface SHContainerVC () {
    SplashViewController *splashView;
}

@end

@implementation SHContainerVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [[self.pageController view] setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+35)];
    
    UINavigationController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    splashView = [[SplashViewController alloc] initWithNibName:NSStringFromClass([SplashViewController class]) bundle:nil];
    [self.navigationController presentViewController:splashView animated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPageViewControllerState:) name:PAGE_VIEW_CONTROLLER_STATE_NOTIFICATION object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom methods

- (UINavigationController *)viewControllerAtIndex:(NSUInteger)index {
    SHFeedVC *feedViewController = [[ARAppDelegate mainStoryboard] instantiateViewControllerWithIdentifier:@"SHFeedVC"];
    feedViewController.index = index;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:feedViewController];
    [self customizeNavigationBar:navigationController withIndex:index];
    return navigationController;
}

#pragma mark - PageVIewController delegate methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UINavigationController *)viewController {
    
    SHFeedVC *feed = [viewController.childViewControllers objectAtIndex:0];
    NSUInteger index = [feed index];
    
    if (index == 0) {
        // to block the bounce effect of PageViewController.
        for (UIView *view in self.pageController.view.subviews ) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scroll = (UIScrollView *)view;
                scroll.bounces = NO;
            }
        }
        return nil;
    }
    
    for (UIView *view in self.pageController.view.subviews ) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            scroll.bounces = YES;
        }
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UINavigationController *)viewController {
    
    SHFeedVC *feed = [viewController.childViewControllers objectAtIndex:0];
    NSUInteger index = [feed index];
    
    index++;
    
    if (index == 4) {
        for (UIView *view in self.pageController.view.subviews ) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scroll = (UIScrollView *)view;
                scroll.bounces = NO;
            }
        }
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 4;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (void)pageViewController:(UIPageViewController *)viewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed){return;}
    
    // Find index of current page
//    ChildViewController *currentViewController = (ChildViewController *)[self.pageController.viewControllers lastObject];
//    NSUInteger indexOfCurrentPage = currentViewController.index;
//    self.pageControl.currentPage = indexOfCurrentPage;
//    
//    [self updateNavigationBarWithIndex:indexOfCurrentPage];
}

- (void)customizeNavigationBar:(UINavigationController *)nav withIndex:(NSInteger)index {
    UIView *title = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 66)];
    UILabel *navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 200, 20)];
    navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
    navigationTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    navigationTitleLabel.backgroundColor = [UIColor clearColor];
    
//    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 30, 200, 25)];
//    pageControl.numberOfPages = 4;
//    pageControl.backgroundColor = [UIColor clearColor];
//    pageControl.currentPage = index;
//    [title addSubview:pageControl];
    
    UIImageView *pageControl = [[UIImageView alloc] initWithFrame:CGRectMake(86, 38, 28, 4)];
    pageControl.backgroundColor = [UIColor clearColor];
    [title addSubview:pageControl];
    
    if(index == 0) {
        // Timeline
        navigationTitleLabel.text = @"Timeline";
        navigationTitleLabel.textColor = [UIColor colorWithRed:6/255.0f green:6/255.0f blue:6/255.0f alpha:1.0];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:196/255.0f green:196/255.0f blue:196/255.0f alpha:1.0f];
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:49/255.0f green:49/255.0f blue:49/255.0f alpha:1.0f];
        pageControl.image = [UIImage imageNamed:@"page-controll-1"];

    } else if(index == 1) {
        // Facebook
        navigationTitleLabel.text = @"Facebook";
        navigationTitleLabel.textColor = [UIColor whiteColor];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:134/255.0f green:153/255.0f blue:191/255.0f alpha:1.0f]; // 173
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:216/255.0f green:222/255.0f blue:234/255.0f alpha:1.0f];
        pageControl.image = [UIImage imageNamed:@"page-controll-2"];

    } else if(index == 2) {
        // Twitter
        navigationTitleLabel.text = @"Twitter";
        navigationTitleLabel.textColor = [UIColor colorWithRed:249/255.0f green:249/255.0f blue:249/255.0f alpha:1.0];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:174/255.0f green:215/255.0f blue:247/255.0f alpha:1.0f]; // 241
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:221/255.0f green:238/255.0f blue:252/255.0f alpha:1.0f];
        pageControl.image = [UIImage imageNamed:@"page-controll-3"];

    } else {
        // Instagram
        navigationTitleLabel.text = @"Instagram";
        navigationTitleLabel.textColor = [UIColor whiteColor];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:46/255.0f green:94/255.0f blue:134/255.0f alpha:1.0f]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:150/255.0f green:174/255.0f blue:194/255.0f alpha:1.0f]; // 158
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:213/255.0f green:223/255.0f blue:231/255.0f alpha:1.0f];
        pageControl.image = [UIImage imageNamed:@"page-controll-4"];

    }
    [title addSubview:navigationTitleLabel];
    
    nav.navigationBar.topItem.titleView = title;
}

// set the pageview controller state here.
-(void)setPageViewControllerState:(NSNotification *) notification {
    NSString *temp = [[notification valueForKey:@"userInfo"] valueForKey:@"key"];
    for (UIScrollView *view in self.pageController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            if([temp isEqualToString:@"0"]) {
                view.scrollEnabled = TRUE;
            } else {
                view.scrollEnabled = FALSE;
            }
        }
    }
}

@end
