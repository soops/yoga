//
//  SHAccountSelectionVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHAccountSelectionVC.h"
#define kProfilePictureKey                  @"PROFILE_PICTURE"
#define kUserNameKey                        @"USERNAME"
#define kAccountTypeKey                     @"ACCOUNT_TYPE"
#define kAccountEnableKey                   @"ACCOUNT_ENABLE"


@interface SHAccountSelectionVC ()<UITableViewDataSource,UITableViewDelegate> {
    NSMutableArray *accountInfo;
}

@end

@implementation SHAccountSelectionVC

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
    // Do any additional setup after loading the view.
    NSDictionary *facebookDict=[NSDictionary dictionaryWithObjectsAndKeys:@"",kProfilePictureKey,@"Ben",kUserNameKey,@"Facebook",kAccountTypeKey,@"YES",kAccountEnableKey, nil];
    NSDictionary *twitterDict=[NSDictionary dictionaryWithObjectsAndKeys:@"",kProfilePictureKey,@"Tiendh",kUserNameKey,@"Twitter",kAccountTypeKey,@"NO",kAccountEnableKey, nil];
    NSDictionary *instaDict=[NSDictionary dictionaryWithObjectsAndKeys:@"",kProfilePictureKey,@"Ben",kUserNameKey,@"Twitter",kAccountTypeKey,@"YES",kAccountEnableKey, nil];
    [accountInfo addObject:facebookDict];
    [accountInfo addObject:twitterDict];
    [accountInfo addObject:instaDict];
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accountInfo count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AccountSelectionCell"];
    NSDictionary *cellDict=(NSDictionary*)[accountInfo objectAtIndex:indexPath.row];
//    UIImageView *profilePic=(UIImageView*)[cell viewWithTag:10];
//    UILabel *userName=(UILabel*)[cell viewWithTag:11];
//    UILabel *accountType=(UILabel*)[cell viewWithTag:12];
    UIImageView *accountEnablePic=(UIImageView*)[cell viewWithTag:13];
    if ([[cellDict objectForKey:kAccountEnableKey] isEqualToString:@"YES"]) {
        accountEnablePic.image=[UIImage imageNamed:@"check.png"];
    } else {
        accountEnablePic.image=[UIImage imageNamed:@"uncheck.png"];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate


@end
