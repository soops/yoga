//
//  ARBaseVC.h
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "YSViewer.h"
#import "SHYSViewerExtension.h"
#import "DTAlertView.h"

@interface ARBaseVC : UIViewController <DTAlertViewDelegate>

@property (strong, nonatomic) SHYSViewerExtension *viewer;

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) UIPageControl *pageControl;

//-Show alert message
- (void)showAlertMessage:(NSString*)message withTitle:(NSString*)title;
- (void)showAlertMessage:(NSString*)message;

//-show confirm message
- (void)showConfirmMessage:(NSString*)message withTitle:(NSString*)title confirmButton:(NSString*)confirm cancelButton:(NSString*)cancel;

//-Alert with dialog
- (void)showDialogWithTitle:(NSString*)title confirmButton:(NSString*)confirm cancelButton:(NSString*)cancel;

//-render navigation bar
- (void)renderNavigationBarWithTitle:(NSString*)barTitle;
//-render navigation bar with left icon
- (void)renderNavigationBarWithTitle:(NSString *)barTitle andRightIcon:(NSString*)rightIcon;
- (void)renderNavigationBarWithTitle:(NSString *)barTitle andLeftIcon:(NSString*)leftIcon andRightIcon:(NSString*)rightIcon;
-(void)renderNavigationBarWithTitle:(NSString*)barTitle leftButtonTitle:(NSString*)_leftButtonTitle rightButtonTitle:(NSString*)_rightButtonTitle;

//-wallaper setting
- (void)setWallpaper:(UIImage*)image;

//-show progress indicator
- (void)showIndicator;
- (void)showIndicatorWithMessage:(NSString*)message;
- (void)stopIndicator;

//-show actionsheet method
-(void) presentActionSheetWithButtons:(NSArray*)buttonTiles;
-(void) presentActionSheetWithButtons:(NSArray*)buttonTiles tag:(NSInteger)_tag title:(NSString*)title;

//-override these methods
- (void)confirmButtonTappedAtIndex:(NSInteger)index;
- (void)actionSheetSelectedAtIndex:(NSInteger)index;
- (void)rightBarButtonTapped:(id)sender;
- (void)leftBarButtonTapped:(id)sender;
- (void)dialogDidAcceptWithMessage:(NSString*)inputMessage;

@end
