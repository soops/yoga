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
 
 File: ClockConfigureWindowController.m
 Version: 2.0
 
 */

#import "ClockConfigureWindowController.h"
#import "ClockView.h"


@implementation ClockConfigureWindowController

#pragma mark - NSObject

- (void)awakeFromNib {
	[super awakeFromNib];

	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:SAMClockDefaultsModuleName];
	[self.faceStylePicker selectItemAtIndex:[defaults integerForKey:SAMClockStyleDefaultsKey]];
	[self.backgroundStylePicker selectItemAtIndex:[defaults integerForKey:SAMClockBackgroundStyleDefaultsKey]];
	self.tickMarksCheckbox.state = [defaults boolForKey:SAMClockTickMarksDefaultsKey];
	self.numbersCheckbox.state = [defaults boolForKey:SAMClockNumbersDefaultsKey];
	self.dateCheckbox.state = [defaults boolForKey:SAMClockDateDefaultsKey];
	self.logoCheckbox.state = [defaults boolForKey:SAMClockLogoDefaultsKey];
}

#pragma mark - NSWindowController

- (NSString *)windowNibName {
	return @"SAMClockConfiguration";
}


#pragma mark - Actions

- (IBAction)close:(id)sender {
	[NSApp endSheet:self.window];
}


- (IBAction)popUpChanged:(id)sender {
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:SAMClockDefaultsModuleName];
	[defaults setInteger:[sender indexOfSelectedItem] forKey:[self defaultsKeyForControl:sender]];
	[defaults synchronize];

	[[NSNotificationCenter defaultCenter] postNotificationName:SAMClockConfigurationDidChangeNotificationName object:nil];
}


- (IBAction)checkboxChanged:(id)sender {
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:SAMClockDefaultsModuleName];
	[defaults setBool:[sender state] forKey:[self defaultsKeyForControl:sender]];
	[defaults synchronize];

	[[NSNotificationCenter defaultCenter] postNotificationName:SAMClockConfigurationDidChangeNotificationName object:nil];
}


#pragma mark - Private

- (NSString *)defaultsKeyForControl:(id)sender {
	NSArray *keys = @[SAMClockStyleDefaultsKey, SAMClockBackgroundStyleDefaultsKey, SAMClockTickMarksDefaultsKey,
					  SAMClockNumbersDefaultsKey, SAMClockDateDefaultsKey, SAMClockLogoDefaultsKey];
	return keys[[sender tag]];
}

@end
