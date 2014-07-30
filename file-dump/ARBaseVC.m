//
//  ARBaseVC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "ARBaseVC.h"
#import "UIImageView+WebCache.h"

/* Navigation Bar Related Constants */
#define strSave                         @"Save"
#define strEdit                         @"Edit"
#define strCancel                       @"Cancel"
#define strBack                         @"Back"
#define strDone                         @"Done"
#define strShare                        @"Share"
#define strSend                         @"Send"
#define strPost                         @"Post"
#define strAddSymbol                    @"+"
#define strAdd                          @"Add"
#define strDelete                       @"Delete"
#define strRegistration                 @"Registration"
#define strRELOAD                       @"Reload"

#define kDialgTag                           111
#define kTextFieldTag                       1111
#define kConfirmTag                         112

#define GENERAL_ACTION_SHEET_TAG 			6000

@interface ARBaseVC ()<UIAlertViewDelegate,UIActionSheetDelegate> {
    UIImageView *wallpaperView;
    MBProgressHUD *HUD;
}

@end

@implementation ARBaseVC

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
    wallpaperView=[[UIImageView alloc] initWithFrame:self.view.frame];
    wallpaperView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    wallpaperView.contentMode=UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:wallpaperView];
    [self.view sendSubviewToBack:wallpaperView];
    
    //-translucent navigation bar
//    [self makeNavigationBarTranslucent];
    HUD = [[MBProgressHUD alloc] init];
    
    self.viewer=[SHYSViewerExtension new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utilities method
- (void)showAlertMessage:(NSString*)message withTitle:(NSString*)title {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alertView show];
    
    DTAlertView *alertView;
    alertView = [DTAlertView alertViewWithTitle:title message:message delegate:nil cancelButtonTitle:nil positiveButtonTitle:@"Ok"];
    alertView.alertViewMode = DTAlertViewModeNormal;
    [alertView setDismissAnimationWhenButtonClicked:DTAlertViewAnimationSlideLeft];
    [alertView showWithAnimation:DTAlertViewAnimationSlideLeft];
}

- (void)showAlertMessage:(NSString*)message {
    [self showAlertMessage:message withTitle:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
}

- (void)showConfirmMessage:(NSString*)message withTitle:(NSString*)title confirmButton:(NSString*)confirm cancelButton:(NSString*)cancel {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
//    alertView.tag=kConfirmTag;
//    [alertView show];
    
    DTAlertView *alertView;
    alertView = [DTAlertView alertViewWithTitle:title message:message delegate:self cancelButtonTitle:cancel positiveButtonTitle:confirm];
    alertView.tag=kConfirmTag;
    alertView.alertViewMode = DTAlertViewModeNormal;
    [alertView setDismissAnimationWhenButtonClicked:DTAlertViewAnimationSlideTop];
    [alertView showWithAnimation:DTAlertViewAnimationSlideTop];
}

- (void)showDialogWithTitle:(NSString*)title confirmButton:(NSString*)confirm cancelButton:(NSString*)cancel {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"\n\n\n" delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
//    alert.tag = kDialgTag;
//    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
//        UITextView *CommentTXT=[[UITextView alloc] initWithFrame:CGRectMake(20, 50, 245, 60)];
//        CommentTXT.tag=kTextFieldTag;
//        [alert addSubview:CommentTXT];
//    } else {
//        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
//    }
//    self.viewer.view=alert;
//    [self.viewer show];
    
//    [self.view setUserInteractionEnabled:YES];
//    [alert show];
    
    DTAlertView *alertView;
    alertView = [DTAlertView alertViewWithTitle:title message:@"\n\n\n" delegate:self cancelButtonTitle:cancel positiveButtonTitle:confirm];
    
    alertView.tag = kDialgTag;
    alertView.alertViewMode = DTAlertViewModeTextInput;
    
    [alertView setDismissAnimationWhenButtonClicked:DTAlertViewAnimationSlideTop];
    [alertView showWithAnimation:DTAlertViewAnimationSlideTop];
}



- (void)showActionSheetTitle:(NSString*)title destructiveButton:(NSString*)destructive cancelButton:(NSString*)cancelTitle buttons:(NSArray*)buttons {
    UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(title,@"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleAutomatic];
	for(NSString *buttonTitle in buttons) {
		[actionSheet addButtonWithTitle:buttonTitle];
	}
	actionSheet.cancelButtonIndex=[actionSheet addButtonWithTitle:cancelTitle];
    actionSheet.destructiveButtonIndex=[actionSheet addButtonWithTitle:destructive];
	[actionSheet showInView:self.view];
}

- (void)renderNavigationBarWithTitle:(NSString*)barTitle {
    //self.title=barTitle;
}

- (void)renderNavigationBarWithTitle:(NSString *)barTitle andRightIcon:(NSString*)rightIcon {
    self.title=barTitle;
    UIImage *image=[UIImage imageNamed:rightIcon];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    [btn setImage:image forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)renderNavigationBarWithTitle:(NSString *)barTitle andLeftIcon:(NSString*)leftIcon andRightIcon:(NSString*)rightIcon {
//    self.title=barTitle;
//    UIView *title = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 66)];
//    UILabel *navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 200, 20)];
//    navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
//    navigationTitleLabel.font = [UIFont boldSystemFontOfSize:15.0];
//    navigationTitleLabel.text = barTitle;
//    navigationTitleLabel.backgroundColor = [UIColor clearColor];
//    [title addSubview:navigationTitleLabel];
//    
//    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 30, 200, 25)];
//    self.pageControl.pageIndicatorTintColor = [UIColor greenColor];
//    self.pageControl.backgroundColor = [UIColor clearColor];
//    self.pageControl.currentPage = self.index;
//    [title addSubview:self.pageControl];
//    
//    if(self.index == 0) {
//        self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
//        navigationTitleLabel.textColor = [UIColor blackColor];
//    } else {
//        self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
//        navigationTitleLabel.textColor = [UIColor whiteColor];
//    }
//    
//    self.navigationController.navigationBar.topItem.titleView = title;

    
    if (leftIcon) {
        
        UIView *profileContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [profileContainer setBackgroundColor:[UIColor clearColor]];
        
        UIImageView *profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [profileImage setImageWithURL:[NSURL URLWithString:leftIcon] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
        [profileContainer addSubview:profileImage];
        profileImage.layer.borderColor=[UIColor lightGrayColor].CGColor;
        profileImage.layer.borderWidth=0.8f;
        profileImage.layer.cornerRadius= profileContainer.frame.size.width / 2;
        profileImage.clipsToBounds=YES;
        profileImage.userInteractionEnabled = TRUE;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftBarButtonTapped:)];
        [profileImage addGestureRecognizer:tap];
        
        //        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        btn.bounds = CGRectMake(0, 0, 35, 35);
        //        [btn setBackgroundColor:[UIColor clearColor]];
        ////        [btn setImage:imageLeft forState:UIControlStateNormal];
        //        [btn addTarget:self action:@selector(leftBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //        [profileImage addSubview:btn];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:profileContainer];
        
//        UIImage *imageLeft=[UIImage imageNamed:leftIcon];
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.bounds = CGRectMake(0, 0, imageLeft.size.width, imageLeft.size.height);
//        [btn setImage:[UIImage imageNamed:@"placeholder"] forState:UIControlStateNormal];
////        UIImageView *im = [[UIImageView alloc] init];
////        [im setImageWithURL:[NSURL URLWithString:leftIcon] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
////            [btn setImage:image forState:UIControlStateNormal];
////        }];
//        
//        [btn addTarget:self action:@selector(leftBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    if (rightIcon) {
        UIImage *imageRight=[UIImage imageNamed:rightIcon];
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.bounds = CGRectMake(0, 0, 30, 27);
        [btn2 setImage:imageRight forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(rightBarButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    }
}

-(void)renderNavigationBarWithTitle:(NSString*)barTitle leftButtonTitle:(NSString*)_leftButtonTitle rightButtonTitle:(NSString*)_rightButtonTitle {
    self.title=barTitle;
    // left button
	if(_leftButtonTitle==nil) {
		[self removeLeftBarButtonOnNavigationBar];
	} else {
		if(self.navigationItem.leftBarButtonItem.customView!=nil)
			self.navigationItem.leftBarButtonItem.customView=nil;
		
		if(self.navigationItem.leftBarButtonItem) {
			self.navigationItem.leftBarButtonItem.title=NSLocalizedString(_leftButtonTitle,@"Left Button Title");
		} else {
			self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(_leftButtonTitle,@"Left Button Title") style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonTapped:)];
		}
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
	}
	
    // right button
	if(_rightButtonTitle==nil) {
		[self removeRightBarButtonOnNavigationBar];
	} else {
		if(self.navigationItem.rightBarButtonItem.customView!=nil)
			self.navigationItem.rightBarButtonItem.customView=nil;
		
		if(self.navigationItem.rightBarButtonItem) {
			if(self.navigationItem.rightBarButtonItem.style==UIBarButtonItemStylePlain)
				self.navigationItem.rightBarButtonItem.title=NSLocalizedString(_rightButtonTitle,@"Right Button Title");
		} else {
			if([_rightButtonTitle isEqualToString:strAddSymbol])
				self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonTapped:)];
			else
				self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(_rightButtonTitle,@"Right Button Title") style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonTapped:)];
		}
        
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
	}
}

-(void)removeRightBarButtonOnNavigationBar
{
	UIView* customView = [[UIView alloc] init];
//    NSLog(@"hello cock");
	customView.frame=CGRectMake(0, 0, 70,44);
	customView.backgroundColor=[UIColor clearColor];
	self.navigationItem.rightBarButtonItem.customView=customView;
}

-(void) removeLeftBarButtonOnNavigationBar
{
	UIView* customView = [[UIView alloc] init];
	customView.frame=CGRectMake(0, 0, 70, 44);
	customView.backgroundColor=[UIColor clearColor];
	self.navigationItem.leftBarButtonItem.customView=customView;
}

- (void)makeNavigationBarTranslucent {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)setWallpaper:(UIImage*)image {
    [wallpaperView setImage:image];
}

- (void)showIndicator {
    [self showIndicatorWithMessage:@""];
}

- (void)showIndicatorWithMessage:(NSString*)message {
    HUD.labelText = message;
    [self.view addSubview:HUD];
    [HUD show:YES];
}

- (void)stopIndicator {
    [HUD hide:YES];
}

//-override these methods
- (void)confirmButtonTappedAtIndex:(NSInteger)index {

}

- (void)dialogDidAcceptWithMessage:(NSString*)inputMessage {
    
}

- (void)actionSheetSelectedAtIndex:(NSInteger)index {

}

- (void)rightBarButtonTapped:(id)sender {

}

- (void)leftBarButtonTapped:(id)sender {

}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(DTAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==kConfirmTag) {
        //-for alert view
        if(buttonIndex == 1) {
            [self confirmButtonTappedAtIndex:buttonIndex];
        }
    } else if (alertView.tag==kDialgTag) {
        //-for dialog view
//        if (buttonIndex==1) {
//            NSString *textInput=@"";
//            if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
//                UITextView *textView=(UITextView*)[alertView viewWithTag:kTextFieldTag];
//                textInput=textView.text;
//            } else {
//                textInput=[[alertView textFieldAtIndex:0] text];
//            }
//            [self dialogDidAcceptWithMessage:textInput];
//        }
        if (buttonIndex==1) {
            [self dialogDidAcceptWithMessage:alertView.textField.text];
        }
    }
}

#pragma mark - UIActionsheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self actionSheetSelectedAtIndex:buttonIndex];
}

#pragma mark - UIActionSheet methods
/*
 * To show activity indicatory with message specific view
 */
-(void) presentActionSheetWithButtons:(NSArray*)buttonTiles
{
	[self presentActionSheetWithButtons:buttonTiles tag:GENERAL_ACTION_SHEET_TAG title:@"One"];
}

/*
 * some times we may need to use multiple action sheets in same VC.
 * in such case the tag can be passed
 */
-(void) presentActionSheetWithButtons:(NSArray*)buttonTiles tag:(NSInteger)_tag title:(NSString*)title
{
	UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:NSLocalizedString(title,@"") delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = _tag;
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
	for(NSString *buttonTitle in buttonTiles) {
		[actionSheet addButtonWithTitle:NSLocalizedString(buttonTitle, @"button title")];
	}
	actionSheet.cancelButtonIndex=[actionSheet addButtonWithTitle:NSLocalizedString(strCancel,strCancel)];
    UIWindow *window=[[[UIApplication sharedApplication] windows] objectAtIndex:1];
    [actionSheet showInView:window];
//    [actionSheet showInView:[self.navigationController.childViewControllers objectAtIndex:0]];
}

@end
