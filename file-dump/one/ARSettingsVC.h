//
//  SHSettingsVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSTwitterEngine.h"
#import "ARInstagramUser.h"
#import "Instagram.h"
#import "SWTableViewCell.h"

@interface ARSettingsVC : UIViewController <FHSTwitterEngineAccessTokenDelegate,IGSessionDelegate, SWTableViewCellDelegate, UIActionSheetDelegate> {
    NSMutableArray *accountsArray;
    NSMutableDictionary *accountsDict;
}

@property (nonatomic, weak) IBOutlet UITableView *accountsTableView;

@end
