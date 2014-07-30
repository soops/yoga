//
//  SHAccountSelectionView.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHAccountSelectionView.h"
#import "SHCheckedButton.h"
#import "ARInstagramUser.h"
#import "ARTwitterUser.h"
#import "FacebookHelper.h"
#import "SHConstant.h"
#import "ARFacebookUser.h"
#import "FHSTwitterEngine.h"
#import "ARAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "FHSTwitterEngine.h"
#import "SHComposer2VC.h"

#define kProfilePictureKey                  @"PROFILE_PICTURE"
#define kUserNameKey                        @"USERNAME"
#define kAccountTypeKey                     @"ACCOUNT_TYPE"
#define kAccountEnableKey                   @"ACCOUNT_ENABLE"

@implementation SHAccountSelectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self=[[[NSBundle mainBundle] loadNibNamed:@"SHAccountSelectionView" owner:self options:nil] firstObject];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)didMoveToSuperview {
    
    SHComposer2VC *com = (SHComposer2VC *) self.delegate;
    NSLog(@"%d", com.selectedIndex);
    //-dummy data
    accountInfo=[[NSMutableArray alloc] init];
    
    if(com.selectedIndex == 0) {
        // Facebook
        if ([[FacebookHelper sharedInstance] isUserAuthenticated]) {
            if (!FBSession.activeSession.isOpen) {
                // if the session is closed, then we open it here, and establish a handler for state changes
                [FBSession openActiveSessionWithReadPermissions:nil allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                    if (error) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                    } else if (session.isOpen) {
                        //run your user info request here
                        [self getFriendsList];
                    }
                }];
            } else {
                [self getFriendsList];
            }
        }
        
    } else if(com.selectedIndex == 1) {
        // Twitter
        if (FHSTwitterEngine.sharedEngine.isAuthorized) {
//            NSMutableDictionary *twitterDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[WFTWUser sharedInstance] profilePicture],kProfilePictureKey,[[WFTWUser sharedInstance] username],kUserNameKey,@"Twitter",kAccountTypeKey,@"NO",kAccountEnableKey, nil];
//            [accountInfo addObject:twitterDict];
            [self getFriendsList];
        }
    }
    
    //-get facebook user info
    
    
    //-load newsfeed from Instagram
//    SHAppDelegate *appDelegate=(SHAppDelegate*)[[UIApplication sharedApplication] delegate];
//    if ([appDelegate.instagram isSessionValid]) {
//        NSMutableDictionary *instaDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[[WFITUser sharedInstance] profilePicture],kProfilePictureKey,[[WFTWUser sharedInstance] username],kUserNameKey,@"Instagram",kAccountTypeKey,@"NO",kAccountEnableKey, nil];
//        [accountInfo addObject:instaDict];
//    }
    
    [self.accountTbView reloadData];
}

- (void)getFriendsList {
    SHComposer2VC *com = (SHComposer2VC *) self.delegate;
    if(com.selectedIndex == 0) {
         [FBRequestConnection startForMyFriendsWithCompletionHandler:
         ^(FBRequestConnection *connection, id friends, NSError *error)
         {
         if(!error && [friends respondsToSelector:@selector(data)]) {
         
         NSArray *friendsList = [friends objectForKey:@"data"];
         //                 [CPDataStore sharedStore].facebookFriendsArray = [NSMutableArray new];
         for(NSDictionary *dict in friendsList) {
         //                     CPFacebookFriend *friend = [CPFacebookFriend friendWithFirstName:[dict objectForKey:@"first_name"]
         //                                                                             lastName:[dict objectForKey:@"last_name"]
         //                                                                             username:[dict objectForKey:@"username"]
         //                                                                           facebookID:[dict objectForKey:@"id"]];
         //                     // Add to DataStore
         //                     [[CPDataStore sharedStore] addFacebookFriend:friend];
         
         NSString *urlSTR = [NSString stringWithFormat:@"%@/%@/picture",FB_API_PREFIX_NO_SECURE,[dict objectForKey:@"id"]];
         NSMutableDictionary *facebookDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:urlSTR,kProfilePictureKey,[dict objectForKey:@"name"],kUserNameKey,@"Facebook",kAccountTypeKey,@"NO",kAccountEnableKey, nil];
         [accountInfo addObject:facebookDict];
         }
         
         //                 NSLog(@"Friends Array populated: %ld",(long)[[CPDataStore sharedStore] facebookFriendsCount]);
         
         [self.accountTbView reloadData];
         }
         }];
    } else if(com.selectedIndex == 1) {
        NSLog(@"%@ -- %@", [[FHSTwitterEngine sharedEngine]authenticatedUsername], [[ARTwitterUser sharedInstance] username]);
        NSMutableArray *followersArray = [[NSMutableArray alloc]init];
        NSMutableDictionary *dict = [[FHSTwitterEngine sharedEngine]listFollowersForUser:[[FHSTwitterEngine sharedEngine]authenticatedUsername] isID:YES withCursor:@"-1"];
        if ([dict isKindOfClass:[NSError class]]) {
            NSLog(@"Getting error and the error is %@",dict);
        } else {
            if ([[dict allKeys]count]>0) {
                [followersArray addObjectsFromArray:[dict objectForKey:@"users"]];
                for (int m=1; m!=0; ) {
                    dict = [[FHSTwitterEngine sharedEngine]listFollowersForUser:[[FHSTwitterEngine sharedEngine]authenticatedUsername] isID:YES withCursor:[dict objectForKey:@"next_cursor_str"]];
                    if ([dict isKindOfClass:[NSError class]]) {
                        NSLog(@"Getting error and the error is %@",dict);
                        break;
                    } else {
                        m = [[dict objectForKey:@"next_cursor"] intValue];
                        [followersArray addObjectsFromArray:[dict objectForKey:@"users"]];
                    }
                }
                NSLog(@"The followers list is %@",followersArray);
                for(NSDictionary *dict in followersArray) {
                    NSMutableDictionary *twitterDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[dict objectForKey:@"profile_image_url_https"],kProfilePictureKey,[dict objectForKey:@"name"],kUserNameKey,@"Twitter",kAccountTypeKey,@"NO",kAccountEnableKey, nil];
                    [accountInfo addObject:twitterDict];
                }
                
                [self.accountTbView reloadData];
            }
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [accountInfo count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"AccountSelectionCell"];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"SHAccountSelectionView" owner:self options:nil] objectAtIndex:1];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    NSDictionary *cellDict=(NSDictionary*)[accountInfo objectAtIndex:indexPath.row];
    UIImageView *profilePic=(UIImageView*)[cell viewWithTag:20];
    [profilePic setImageWithURL:[NSURL URLWithString:[cellDict objectForKey:kProfilePictureKey]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    UILabel *userName=(UILabel*)[cell viewWithTag:11];
    userName.text=[cellDict objectForKey:kUserNameKey];
    UILabel *accountType=(UILabel*)[cell viewWithTag:12];
    accountType.text=[cellDict objectForKey:kAccountTypeKey];
    SHCheckedButton *accountEnablePic=(SHCheckedButton*)[cell viewWithTag:13];
    [accountEnablePic addTarget:self action:@selector(checkmarkTapped:) forControlEvents:UIControlEventTouchUpInside];
    if ([[cellDict objectForKey:kAccountEnableKey] isEqualToString:@"YES"]) {
        [accountEnablePic setImage:[UIImage imageNamed:@"tick"] forState:UIControlStateNormal];
    } else {
        [accountEnablePic setImage:nil forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)checkmarkTapped:(id)sender {
    SHCheckedButton *tappedButton=(SHCheckedButton*)sender;
    id cell=[[[tappedButton superview] superview] superview];
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        NSInteger cellIndex=[(NSIndexPath*)[self.accountTbView indexPathForCell:(UITableViewCell*)cell] row];
        NSMutableDictionary *cellDict=[accountInfo objectAtIndex:cellIndex];
        NSString *enableStr=[cellDict objectForKey:kAccountEnableKey];
        if ([enableStr isEqualToString:@"YES"]) {
            [cellDict setObject:@"NO" forKey:kAccountEnableKey];
        } else {
            [cellDict setObject:@"YES" forKey:kAccountEnableKey];
        }
        [self.accountTbView reloadData];
        
        //-for delegate method
        BOOL fFacebook=NO;
        BOOL fTwitter=NO;
        BOOL fInstagram=NO;
        for (NSDictionary *accountDict in accountInfo) {
            NSString *selectionStatus=[accountDict objectForKey:kAccountEnableKey];
            NSString *accountType=[accountDict objectForKey:kAccountTypeKey];
            if ([accountType isEqualToString:@"Facebook"]) {
                if ([selectionStatus isEqualToString:@"YES"]) {
                    fFacebook=YES;
                }
            }
            if ([accountType isEqualToString:@"Twitter"]) {
                if ([selectionStatus isEqualToString:@"YES"]) {
                    fTwitter=YES;
                }
            }
            if ([accountType isEqualToString:@"Instagram"]) {
                if ([selectionStatus isEqualToString:@"YES"]) {
                    fInstagram=YES;
                }
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(userDidChangeSelection:twitter:instagram:)]) {
            [self.delegate userDidChangeSelection:fFacebook twitter:fTwitter instagram:fInstagram];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    SHCheckedButton *accountEnablePic=(SHCheckedButton*)[cell viewWithTag:13];
//    id cell=[[[tappedButton superview] superview] superview];
    if ([cell isKindOfClass:[UITableViewCell class]]) {
        NSInteger cellIndex=[(NSIndexPath*)[self.accountTbView indexPathForCell:(UITableViewCell*)cell] row];
        NSMutableDictionary *cellDict=[accountInfo objectAtIndex:cellIndex];
        NSString *enableStr=[cellDict objectForKey:kAccountEnableKey];
        if ([enableStr isEqualToString:@"YES"]) {
            [cellDict setObject:@"NO" forKey:kAccountEnableKey];
        } else {
            [cellDict setObject:@"YES" forKey:kAccountEnableKey];
        }
        [self.accountTbView reloadData];
        
        //-for delegate method
        BOOL fFacebook=NO;
        BOOL fTwitter=NO;
        BOOL fInstagram=NO;
        for (NSDictionary *accountDict in accountInfo) {
            NSString *selectionStatus=[accountDict objectForKey:kAccountEnableKey];
            NSString *accountType=[accountDict objectForKey:kAccountTypeKey];
            if ([accountType isEqualToString:@"Facebook"]) {
                if ([selectionStatus isEqualToString:@"YES"]) {
                    fFacebook=YES;
                }
            }
            if ([accountType isEqualToString:@"Twitter"]) {
                if ([selectionStatus isEqualToString:@"YES"]) {
                    fTwitter=YES;
                }
            }
            if ([accountType isEqualToString:@"Instagram"]) {
                if ([selectionStatus isEqualToString:@"YES"]) {
                    fInstagram=YES;
                }
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(userDidChangeSelection:twitter:instagram:)]) {
            [self.delegate userDidChangeSelection:fFacebook twitter:fTwitter instagram:fInstagram];
        }
    }
}

@end
