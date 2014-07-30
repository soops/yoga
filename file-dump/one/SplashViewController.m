//
//  SplashViewController.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SplashViewController.h"
#import "SHConstant.h"
#import "ARAppDelegate.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

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
    
    [ARAppDelegate application].pagingNumber=0;
    [ARAppDelegate application].lastTwitterPostId=@"";
    [ARAppDelegate application].lastITPostId=@"";
    
    getFeedData = [[SHGetFeedData alloc] init];
    getFeedData.delegate = self;
    [getFeedData loadSocialData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didGetFeedData {
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.1];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:NO completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_FEED_TABLE_NOTIFICATION object:nil];
}

@end
