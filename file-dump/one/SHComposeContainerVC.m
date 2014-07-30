//
//  SHComposeContainerVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHComposeContainerVC.h"
#import "SHComposer2VC.h"
#import "ARAppDelegate.h"

@interface SHComposeContainerVC ()

@end

@implementation SHComposeContainerVC

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom methods

- (UINavigationController *)viewControllerAtIndex:(NSUInteger)index {
    SHComposer2VC *composer = [[ARAppDelegate mainStoryboard] instantiateViewControllerWithIdentifier:@"SHComposer2VC"];
    composer.selectedIndex = index;
    composer.delegate = self.delegate;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:composer];
    [self customizeNavigationBar:navigationController withIndex:index];
    return navigationController;
}

#pragma mark - PageVIewController delegate methods

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UINavigationController *)viewController {
    
    SHComposer2VC *feed = [viewController.childViewControllers objectAtIndex:0];
    NSUInteger index = [feed index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UINavigationController *)viewController {
    
    SHComposer2VC *feed = [viewController.childViewControllers objectAtIndex:0];
    NSUInteger index = [feed index];
    
    index++;
    
    if (index == 1) {
        return [self viewControllerAtIndex:index];
    }
    
    return nil;

}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 2;
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
    navigationTitleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    navigationTitleLabel.backgroundColor = [UIColor clearColor];
    
    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 30, 200, 25)];
    pageControl.numberOfPages = 2;
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.currentPage = index;
    [title addSubview:pageControl];
    
//    if(index == 0) {
//        // Timeline
//        navigationTitleLabel.text = @"Timeline";
//        navigationTitleLabel.textColor = [UIColor colorWithRed:6/255.0f green:6/255.0f blue:6/255.0f alpha:1.0];
//        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:196/255.0f green:196/255.0f blue:196/255.0f alpha:1.0f];
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:49/255.0f green:49/255.0f blue:49/255.0f alpha:1.0f];
//        
//    }
    if(index == 0) {
        // Facebook
        navigationTitleLabel.text = @"Facebook";
        navigationTitleLabel.textColor = [UIColor whiteColor];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f]];
        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:134/255.0f green:153/255.0f blue:191/255.0f alpha:1.0f]; // 173
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:216/255.0f green:222/255.0f blue:234/255.0f alpha:1.0f];
        
    } else if(index == 1) {
        // Twitter
        navigationTitleLabel.text = @"Twitter";
        navigationTitleLabel.textColor = [UIColor colorWithRed:249/255.0f green:249/255.0f blue:249/255.0f alpha:1.0];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f]];
        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:174/255.0f green:215/255.0f blue:247/255.0f alpha:1.0f]; // 241
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:221/255.0f green:238/255.0f blue:252/255.0f alpha:1.0f];
        
    }
    [title addSubview:navigationTitleLabel];
    
    nav.navigationBar.topItem.titleView = title;
}

@end
