//
//  ARThreadDetailVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARBaseVC.h"

@interface ARThreadDetailVC : ARBaseVC

//-facebook specific
@property (nonatomic, strong) NSString *threadID;
@property (nonatomic, assign) NSInteger socialMode;
@property (strong, nonatomic) IBOutlet UITableView *threadTbView;
@property (strong, nonatomic) NSString *name;

@end
