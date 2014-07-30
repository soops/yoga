//
//  SHComposer2VC.m
//  Project One
//
//  Created by Douglas Bumby on 6-29-14.
//  Copyright (c) 2014 Apollo Research. All rights reserved.
//

#import "SHComposer2VC.h"
#import "SHConstant.h"
#import "SHAccountSelectionVC.h"
#import "SHAccountSelectionView.h"

#define kComposerCharLimit          140

@interface SHComposer2VC ()<UITextViewDelegate,SHAccountSelectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    BOOL fFacebookSelected;
    BOOL fTwitterSelected;
    BOOL fInstagramSelected;
    BOOL fPeopleSelected;
    BOOL fCameraSelected;
    UIImage *selectedImage;
}
@property (strong, nonatomic) IBOutlet UIButton *peopleBtn;

@end

@implementation SHComposer2VC

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
    [self renderNavigationBarWithTitle:@"Compose" leftButtonTitle:@"Cancel" rightButtonTitle:@"Post"];
//    [self customizeNavigationBar:self.navigationController withIndex:self.selectedIndex];
    fFacebookSelected=NO;
    fTwitterSelected=NO;
    fInstagramSelected=NO;
    fPeopleSelected=NO;
    fCameraSelected=NO;
//    self.bgBlurView.image=self.bgImage;
    self.bgBlurView.image=nil;
//    self.inputContainer.hidden=YES;
    self.textViewInput.inputAccessoryView=self.inputContainer;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
//    self.textViewInput.backgroundColor=[UIColor clearColor];
    if(self.selectedIndex == 0) {
        fFacebookSelected = YES;
        fTwitterSelected = NO;
    } else if(self.selectedIndex == 1) {
        fFacebookSelected = NO;
        fTwitterSelected = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.textViewInput becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeSelectedPhotoView];
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

#pragma mark - Overriden methods
- (void)rightBarButtonTapped:(id)sender {
    NSLog(@"right button tapped");
}

- (void)leftBarButtonTapped:(id)sender {
    NSLog(@"left button tapped");
    [self removeAccountTable];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSheetSelectedAtIndex:(NSInteger)index {
    NSLog(@"index: %d",index);
    if (index==1) {
        //-camera selected
        [self removeSelectedPhotoView];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //-show camera here
        } else {
            [self showAlertMessage:@"Camera not available"];
        }
    } else if (index==0) {
        //-library selected
        [self removeSelectedPhotoView];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
			ipc.delegate = self;
			ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			ipc.allowsEditing = YES;
			ipc.navigationBar.barStyle = UIBarStyleBlack;
			ipc.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:ipc animated:YES completion:nil];
        } else {
            [self showAlertMessage:@"Access not available"];
        }
    }
}

- (IBAction)postTapped:(id)sender {
    if (fFacebookSelected || fTwitterSelected || fInstagramSelected) {
        if (self.textViewInput.text.length!=0) {
            if (selectedImage==nil) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didPostWithTextContent:facebook:twitter:instagram:)]) {
                    [self.delegate didPostWithTextContent:self.textViewInput.text facebook:fFacebookSelected twitter:fTwitterSelected instagram:fInstagramSelected];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didPostWithTextContent:image:facebook:twitter:instagram:)]) {
                    [self.delegate didPostWithTextContent:self.textViewInput.text image:selectedImage facebook:fFacebookSelected twitter:fTwitterSelected instagram:fInstagramSelected];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        } else {
            [self showAlertMessage:@"Cannot post a blank"];
        }
    } else {
        [self showAlertMessage:@"Please select at least a social network"];
    }
    [self removeAccountTable];
    [self removeSelectedPhotoView];
}

- (IBAction)cancelTapped:(id)sender {
    [self removeAccountTable];
    [self removeSelectedPhotoView];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cameraTapped:(id)sender {
    NSLog(@"camera tapped");
    if (fCameraSelected) {
        fCameraSelected=NO;
        [self.btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [self removeSelectedPhotoView];
    } else {
        fCameraSelected=YES;
        [self.btnCamera setImage:[UIImage imageNamed:@"camera_selected"] forState:UIControlStateNormal];
        [self showSelectedPhotoView];
    }
    fPeopleSelected=NO;
    [self.peopleBtn setImage:[UIImage imageNamed:@"people"] forState:UIControlStateNormal];
}

- (IBAction)peopleTapped:(id)sender {
    if (!fPeopleSelected) {
        [self.peopleBtn setImage:[UIImage imageNamed:@"people_selected"] forState:UIControlStateNormal];
        fPeopleSelected=YES;
        [self showAccountTable];
    } else {
        [self.peopleBtn setImage:[UIImage imageNamed:@"people"] forState:UIControlStateNormal];
        fPeopleSelected=NO;
        [self removeAccountTable];
    }
    fCameraSelected=NO;
    [self.btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger currentLength=textView.text.length;
    self.limitLb.text=[NSString stringWithFormat:@"%d/%d",currentLength,kComposerCharLimit];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return textView.text.length + (text.length - range.length) <= 140;
}

#pragma mark - Utilities method

- (void)customizeNavigationBar:(UINavigationController *)nav withIndex:(NSInteger)index {
    UIView *title = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 66)];
    UILabel *navigationTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 200, 20)];
    navigationTitleLabel.textAlignment = NSTextAlignmentCenter;
    navigationTitleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    navigationTitleLabel.backgroundColor = [UIColor clearColor];
    
//    UIPageControl *pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 30, 200, 25)];
//    pageControl.numberOfPages = 4;
//    pageControl.backgroundColor = [UIColor clearColor];
//    pageControl.currentPage = index;
//    [title addSubview:pageControl];
    
    if(index == 0) {
        // Timeline
        navigationTitleLabel.text = @"Timeline";
        navigationTitleLabel.textColor = [UIColor colorWithRed:6/255.0f green:6/255.0f blue:6/255.0f alpha:1.0];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:196/255.0f green:196/255.0f blue:196/255.0f alpha:1.0f];
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:49/255.0f green:49/255.0f blue:49/255.0f alpha:1.0f];
        
    } else if(index == 1) {
        // Facebook
        navigationTitleLabel.text = @"Facebook";
        navigationTitleLabel.textColor = [UIColor whiteColor];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:59/255.0f green:89/255.0f blue:152/255.0f alpha:1.0f]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:134/255.0f green:153/255.0f blue:191/255.0f alpha:1.0f]; // 173
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:216/255.0f green:222/255.0f blue:234/255.0f alpha:1.0f];
        
    } else if(index == 2) {
        // Twitter
        navigationTitleLabel.text = @"Twitter";
        navigationTitleLabel.textColor = [UIColor colorWithRed:249/255.0f green:249/255.0f blue:249/255.0f alpha:1.0];
        [nav.navigationBar setBarTintColor:[UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f]];
//        pageControl.pageIndicatorTintColor = [UIColor colorWithRed:174/255.0f green:215/255.0f blue:247/255.0f alpha:1.0f]; // 241
//        pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:221/255.0f green:238/255.0f blue:252/255.0f alpha:1.0f];
        
    }
    [title addSubview:navigationTitleLabel];
    
    nav.navigationBar.topItem.titleView = title;
}

- (void)showWaitingView {
    CGRect frame = CGRectMake(90, 190, 32, 32);
    UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
    [progressInd startAnimating];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    
    frame = CGRectMake(130, 193, 140, 30);
    UILabel *waitingLable = [[UILabel alloc] initWithFrame:frame];
    waitingLable.text = @"Processing...";
    waitingLable.textColor = [UIColor whiteColor];
    waitingLable.font = [UIFont systemFontOfSize:20];;
    waitingLable.backgroundColor = [UIColor clearColor];
    frame = [[UIScreen mainScreen] applicationFrame];
    UIView *theView = [[UIView alloc] initWithFrame:frame];
    theView.backgroundColor = [UIColor blackColor];
    theView.alpha = 0.7;
    theView.tag = 999;
    [theView addSubview:progressInd];
    [theView addSubview:waitingLable];
    UIWindow *window=[[[UIApplication sharedApplication] windows] objectAtIndex:1];
    [window addSubview:theView];
    [window bringSubviewToFront:theView];
}

- (void)showAccountTable {
    [self removeSelectedPhotoView];
    //-set image for button camera
//    [self.btnCamera setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    UIView *containerView=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-kStandardKeyboardHeight, self.view.bounds.size.width, kStandardKeyboardHeight)];
    containerView.backgroundColor=[UIColor greenColor];
    containerView.tag=100;
    
    SHAccountSelectionView *selectView=[[SHAccountSelectionView alloc] initWithFrame:containerView.frame];
    selectView.delegate=self;
    [containerView addSubview:selectView];
    
    if ([[[UIApplication sharedApplication] windows] count]>1) {
        UIWindow *window=[[[UIApplication sharedApplication] windows] objectAtIndex:1];
        [window addSubview:containerView];
        [window bringSubviewToFront:containerView];
    }
}

- (void)removeAccountTable {
    if ([[[UIApplication sharedApplication] windows] count]>1) {
        UIWindow *window=[[[UIApplication sharedApplication] windows] objectAtIndex:1];
        UIView *containerView=[window viewWithTag:100];
        [containerView removeFromSuperview];
    }
}

- (void)showSelectedPhotoView {
    [self removeAccountTable];
    UIView *containerView=[[[NSBundle mainBundle] loadNibNamed:@"HorizonPhotos" owner:nil options:nil] firstObject];
    containerView.frame=CGRectMake(0, self.view.bounds.size.height-kStandardKeyboardHeight, self.view.bounds.size.width, kStandardKeyboardHeight);
    containerView.tag=101;
    
    
    UIButton *guideBtn=(UIButton*)[containerView viewWithTag:11];
    [guideBtn addTarget:self action:@selector(btnGuideTapped:) forControlEvents:UIControlEventTouchUpInside];
    //-image view
    UIImageView *imgView=(UIImageView*)[containerView viewWithTag:10];
    if (selectedImage!=nil) {
        imgView.image=selectedImage;
        [guideBtn setTitle:@"Remove this picture" forState:UIControlStateNormal];
    } else {
        [guideBtn setTitle:@"Add your picture" forState:UIControlStateNormal];
    }
    imgView.userInteractionEnabled=YES;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(postImageTapped:)];
    tapGesture.numberOfTapsRequired=1;
    [imgView addGestureRecognizer:tapGesture];
    
    //-set image here
    if ([[[UIApplication sharedApplication] windows] count]>1) {
        UIWindow *window=[[[UIApplication sharedApplication] windows] objectAtIndex:1];
        [window addSubview:containerView];
        [window bringSubviewToFront:containerView];
    }
}

- (void)removeSelectedPhotoView {
    if ([[[UIApplication sharedApplication] windows] count]>1) {
        UIWindow *window=[[[UIApplication sharedApplication] windows] objectAtIndex:1];
        UIView *containerView=[window viewWithTag:101];
        [containerView removeFromSuperview];
    }
}

- (void)postImageTapped:(id)sender {
    [self presentActionSheetWithButtons:[NSArray arrayWithObjects:@"Library",@"Camera", nil] tag:-1 title:@"Choose an existing picture"];
}

- (void)btnGuideTapped:(id)sender {
    //-do nothing now
    selectedImage=nil;
    [self removeSelectedPhotoView];
    [self showSelectedPhotoView];
}

#pragma mark - Keyboard handling
- (void)keyboardWillShow:(NSNotification*)note {
    NSDictionary *userInfo = [note userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    NSLog(@"Keyboard Height: %f Width: %f", kbSize.height, kbSize.width);
}

#pragma mark - SHAccountSelectionViewDelegate
- (void)userDidChangeSelection:(BOOL)facebook twitter:(BOOL)twitter instagram:(BOOL)instagram {
    if (facebook) {
        NSLog(@"Facebook enabled");
    }
    if (twitter) {
        NSLog(@"Twitter enabled");
    }
    if (instagram) {
        NSLog(@"Instagram enabled");
    }
    fFacebookSelected=facebook;
    fTwitterSelected=twitter;
    fInstagramSelected=instagram;
}

#pragma mark - UIImagePickerViewDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:nil];
    selectedImage=image;
    [self showSelectedPhotoView];
    [self.textViewInput becomeFirstResponder];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissViewControllerAnimated:YES completion:nil];
}

@end
