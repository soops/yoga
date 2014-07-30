//
//  SHWebViewController.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHWebViewController.h"

@implementation SHWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.bounds = CGRectMake(0, 0, 80, 40);
    btn2.titleLabel.textColor = [UIColor blueColor];
    btn2.titleLabel.text = @"Close";

    [btn2 addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.name]]];
}

- (void)rightBarButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
