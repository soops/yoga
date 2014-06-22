/*
 
 Copyright (c) 2014 Apollo Computational Research Group
 Clock Face for OSX by Douglas Bumby.
 
 Original: http://goo.gl/rXrQoq // Sam Soffes
 
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
 
 File: AppDelegate.m
 Version: 2.0
 
 */

#import "AppDelegate.h"
#import "ClockView.h"

@interface AppDelegate ()
@property (nonatomic) ScreenSaverView *clockView;
@end

@implementation AppDelegate


#pragma mark - Actions

- (IBAction)showConfiguration:(id)sender {
	[NSApp beginSheet:self.clockView.configureSheet modalForWindow:self.window modalDelegate:self didEndSelector:@selector(endSheet:) contextInfo:nil];
}


#pragma mark - Private

- (void)endSheet:(NSWindow *)sheet {
	[sheet close];
}


#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	self.clockView = [[ClockView alloc] init];
	self.clockView.frame = [self.window.contentView bounds];
	self.clockView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.window.contentView addSubview:self.clockView];

	[self.clockView startAnimation];
	[NSTimer scheduledTimerWithTimeInterval:[self.clockView animationTimeInterval] target:self.clockView selector:@selector(animateOneFrame) userInfo:nil repeats:YES];
}

@end
