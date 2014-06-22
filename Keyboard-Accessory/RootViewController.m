
/* Keyboard Accessory. Made by Douglas Bumby */

#import "ViewController.h"

@interface RootViewController () <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UIView *accessoryView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
// Required Property for NSLayoutConstraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintToAdjust;

@end

#pragma mark -

@implementation RootViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // set the right bar button item initially to "Edit" state
    self.navigationItem.rightBarButtonItem = self.editButton;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self editAction:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self adjustSelection:self.textView];
}


#pragma mark - Actions

- (IBAction)doneAction:(id)sender {
    
    [self.textView resignFirstResponder];
}

- (IBAction)editAction:(id)sender {
    
    // user tapped the Edit button, make the text view first responder
    [self.textView becomeFirstResponder];
}


#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    // note: you can create the accessory view programmatically (in code), or from the storyboard
    if (self.textView.inputAccessoryView == nil) {
        
        self.textView.inputAccessoryView = self.accessoryView;  // use what's in the storyboard
    }
    
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    
    [aTextView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = self.editButton;
    
    return YES;
}

- (void)adjustSelection:(UITextView *)textView {
    
    // workaround to UITextView bug, text at the very bottom is slightly cropped by the keyboard
    if ([textView respondsToSelector:@selector(textContainerInset)]) {
        [textView layoutIfNeeded];
        CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
        caretRect.size.height += textView.textContainerInset.bottom;
        [textView scrollRectToVisible:caretRect animated:NO];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [self adjustSelection:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    [self adjustSelection:textView];
}


#pragma mark - Responding to keyboard events

- (void)adjustTextViewByKeyboardState:(BOOL)showKeyboard keyboardInfo:(NSDictionary *)info {

    UIViewAnimationCurve animationCurve = [info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionBeginFromCurrentState;
    if (animationCurve == UIViewAnimationCurveEaseIn) {
        animationOptions |= UIViewAnimationOptionCurveEaseIn;
    }
    else if (animationCurve == UIViewAnimationCurveEaseInOut) {
        animationOptions |= UIViewAnimationOptionCurveEaseInOut;
    }
    else if (animationCurve == UIViewAnimationCurveEaseOut) {
        animationOptions |= UIViewAnimationOptionCurveEaseOut;
    }
    else if (animationCurve == UIViewAnimationCurveLinear) {
        animationOptions |= UIViewAnimationOptionCurveLinear;
    }
    
    [self.textView setNeedsUpdateConstraints];
    
    if (showKeyboard) {
        UIDeviceOrientation orientation = self.interfaceOrientation;
        BOOL isPortrait = UIDeviceOrientationIsPortrait(orientation);
        
        NSValue *keyboardFrameVal = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
        CGFloat height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
        
        self.constraintToAdjust.constant += height;
    }
    else {
        self.constraintToAdjust.constant = 0;
    }

    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];

    NSRange selectedRange = self.textView.selectedRange;
    // [self.textView scrollRangeToVisible:selectedRange];
}

- (void)keyboardWillShow:(NSNotification *)notification {

    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:YES keyboardInfo:userInfo];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:NO keyboardInfo:userInfo];
}


#pragma mark - Accessory view action

- (IBAction)tappedMe:(id)sender {
    NSMutableString *text = [self.textView.text mutableCopy];
    NSRange selectedRange = self.textView.selectedRange;
    
    [text replaceCharactersInRange:selectedRange withString:@"\nYou tapped me."];
    self.textView.text = text;
    
    [self adjustSelection:sender];
}

@end
