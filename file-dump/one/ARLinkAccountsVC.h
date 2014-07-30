//
//  ARLinkAccountsVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Douglas Bumby. All rights reserved.
//

#import "ARBaseVC.h"

@interface ARLinkAccountsVC : ARBaseVC

@property (strong, nonatomic) IBOutlet UIButton *fbBtn;
@property (strong, nonatomic) IBOutlet UIButton *twitterBtn;
@property (strong, nonatomic) IBOutlet UIButton *instagramBtn;

- (IBAction)facebookTapped:(id)sender;
- (IBAction)twitterTapped:(id)sender;
- (IBAction)instagramTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarBtn;

- (IBAction)rightBarBtnTapped:(id)sender;
- (IBAction)leftBarBtnTapped:(id)sender;

@end
