//
//  AROneProfileVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARBaseVC.h"

@interface AROneProfileVC : ARBaseVC<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UITableView *profileTbView;
@property (assign, nonatomic) NSInteger accountMode;
- (IBAction)btnCloseTapped:(id)sender;
@end
