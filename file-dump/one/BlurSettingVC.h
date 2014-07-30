//
//  BlurSettingVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARBaseVC.h"

@interface BlurSettingVC : ARBaseVC
@property (nonatomic, strong) UIImage *blurBgImage;
@property (strong, nonatomic) IBOutlet UIImageView *btImageView;
- (IBAction)btnAddTapped:(id)sender;
- (IBAction)btnSettingTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *accountTbView;
@end
