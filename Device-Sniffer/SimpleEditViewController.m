/*
 
 Copyright (c) 2014 Apollo Computational Research Group
 Commits Made by Douglas Bumby.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 File: SimpleEditViewController.m
 Version: 1.1
 
 */

#import "SimpleEditViewController.h"
// Not Fully Finished
@interface SimpleEditViewController ()
@property(nonatomic, retain) UITextField* textField;
@end

@implementation SimpleEditViewController

@synthesize delegate = _delegate;
@synthesize textField = _textField;

- (id)initWithTitle:(NSString*)title currentText:(NSString*)current {
	
	if ((self = [super init])) {
		self.title = title;
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

		// Add the "cancel" button to the navigation bar
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
		
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];

		CGSize size = self.view.frame.size;
		CGRect rect = CGRectMake(5, 5, size.width-10, 30);
		
		_textField = [[UITextField alloc] initWithFrame:rect];
		
		_textField.text = current;
		_textField.autocorrectionType = UITextAutocorrectionTypeNo;
		_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_textField.borderStyle = UITextBorderStyleRoundedRect;
		_textField.textColor = [UIColor blackColor];
		_textField.font = [UIFont systemFontOfSize:17.0];
		_textField.backgroundColor = [UIColor clearColor];
		_textField.keyboardType = UIKeyboardTypeURL;
		_textField.returnKeyType = UIReturnKeyDone;
		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		
		_textField.delegate = self;
		
		[self.view addSubview:_textField];
		
		[_textField becomeFirstResponder];
		
		cancelling = NO;
	}
	
	return self;
}


- (IBAction)cancelAction {
	cancelling = YES;
	[self.textField resignFirstResponder];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.textField) {
		[self.delegate simpleEditViewController:self didGetText:cancelling ? nil : self.textField.text];
	}
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.textField) {
		[self.textField resignFirstResponder];
	}
	return YES;
}


- (void)dealloc {
	[_textField release];
	[super dealloc];
}


@end

