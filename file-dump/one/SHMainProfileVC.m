//
//  SHMainProfileVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "SHMainProfileVC.h"
#import "ARProfileVC.h"
#import "FacebookHelper.h"
#import "ARAppDelegate.h"
#import "FHSTwitterEngine.h"
#import "ARInstagramUser.h"
#import "SHConstant.h"

@interface SHMainProfileVC () {
    NSInteger currentIndex;
}

@end

@implementation SHMainProfileVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.socialProfiles=[[NSMutableArray alloc] init];
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSString *fbAccessToken = [[NSUserDefaults standardUserDefaults] objectForKey:FB_ACCESSTOKEN]; // FBSession.activeSession.accessTokenData.accessToken
    // if ([[FacebookHelper sharedInstance] isUserAuthenticated])
    
    if (fbAccessToken != nil) {
        [self.socialProfiles addObject:@"Facebook"];
    }
    if (FHSTwitterEngine.sharedEngine.isAuthorized) {
        [self.socialProfiles addObject:@"Twitter"];
    }
    ARAppDelegate *appDelegate=(ARAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.instagram isSessionValid]) {
        [self.socialProfiles addObject:@"Instagram"];
    }
    
    if (self.socialProfiles.count==0) {
        return;
    }
    
    //render navigation bar
    currentIndex=0;
    [self renderNavigationBarWithTitle:[self.socialProfiles firstObject]];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageVC"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate=self;
    
//    for (UIView *view in self.pageViewController.view.subviews ) {
//        if ([view isKindOfClass:[UIScrollView class]]) {
//            UIScrollView *scroll = (UIScrollView *)view;
//            scroll.bounces = NO;
//        }
//    }
    
    ARProfileVC *startingViewController = [self viewControllerAtIndex:0];
    NSString *currentSocialModeDescription=[self.socialProfiles firstObject];
    if ([currentSocialModeDescription isEqualToString:@"Facebook"]) {
        startingViewController.socialAccountMode=1;
    } else if ([currentSocialModeDescription isEqualToString:@"Twitter"]) {
        startingViewController.socialAccountMode=2;
    } else {
        startingViewController.socialAccountMode=3;
    }
    startingViewController.isMyProfile=YES;
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = self.view.frame;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
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

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ARProfileVC*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        // to block the bounce effect of PageViewController.
        for (UIView *view in self.pageViewController.view.subviews ) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scroll = (UIScrollView *)view;
                scroll.bounces = NO;
            }
        }

        return nil;
    }
    
    for (UIView *view in self.pageViewController.view.subviews ) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scroll = (UIScrollView *)view;
            scroll.bounces = YES;
        }
    }
    
    index--;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ARProfileVC*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.socialProfiles count]) {
        
        for (UIView *view in self.pageViewController.view.subviews ) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scroll = (UIScrollView *)view;
                scroll.bounces = NO;
            }
        }
        return nil;
    } else {
        return [self viewControllerAtIndex:index];
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.socialProfiles count];
}

//-starting index
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        ARProfileVC *profileVC=(ARProfileVC*)[self.pageViewController.viewControllers firstObject];
        currentIndex=profileVC.pageIndex;
//        NSString *titleStr=[self.socialProfiles objectAtIndex:currentIndex];
//        if ([titleStr isEqualToString:@"Facebook"]) {
//            profileVC.socialAccountMode=1;
//        } else if ([titleStr isEqualToString:@"Twitter"]) {
//            profileVC.socialAccountMode=2;
//        } else {
//            profileVC.socialAccountMode=3;
//        }
//        //-adjust navigation title
//        [self renderNavigationBarWithTitle:[self.socialProfiles objectAtIndex:currentIndex]];
        //-reload profile
        [profileVC LoadProfile];
        [profileVC refreshTableViewData];
    }
}

#pragma mark - Utilities method
- (ARProfileVC *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.socialProfiles count] == 0) || (index >= [self.socialProfiles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ARProfileVC *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profileContentVC"];
    pageContentViewController.pageIndex = index;
    currentIndex=index;
    if([[self.socialProfiles objectAtIndex:index] isEqualToString:@"Facebook"]) {
        pageContentViewController.socialAccountMode = 1;
    } else if([[self.socialProfiles objectAtIndex:index] isEqualToString:@"Twitter"]) {
        pageContentViewController.socialAccountMode = 2;
    } else if([[self.socialProfiles objectAtIndex:index] isEqualToString:@"Instagram"]) {
        pageContentViewController.socialAccountMode = 3;
    }
//    pageContentViewController.socialAccountMode = currentIndex +1;
    return pageContentViewController;
}

@end
