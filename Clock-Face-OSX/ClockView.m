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
 
 File: ClockView.m
 Version: 2.0
 
 */

#import "ClockView.h"
#import "ClockConfigureWindowController.h" // Import

NSString *const SAMClockConfigurationDidChangeNotificationName = @"SAMClockConfigurationDidChangeNotification";
NSString *const SAMClockDefaultsModuleName = @"com.samsoffes.clock";
NSString *const SAMClockStyleDefaultsKey = @"SAMClockStyle";
NSString *const SAMClockBackgroundStyleDefaultsKey = @"SAMClockBackgroundStyleDefaults";
NSString *const SAMClockTickMarksDefaultsKey = @"SAMClockTickMarks";
NSString *const SAMClockNumbersDefaultsKey = @"SAMClockNumbers";
NSString *const SAMClockDateDefaultsKey = @"SAMClockDate";
NSString *const SAMClockLogoDefaultsKey = @"SAMClockLogo";

@interface ClockView ()
@property (nonatomic, readonly) ClockConfigureWindowController *configureWindowController;
@property (nonatomic) NSImage *logoImage;
@end

@implementation ClockView

#pragma mark - Accessors

@synthesize configureWindowController = _configureWindowController;

- (ClockConfigureWindowController *)configureWindowController {
	if (!_configureWindowController) {
		_configureWindowController = [[ClockConfigureWindowController alloc] init];
		[_configureWindowController loadWindow];
	}
	return _configureWindowController;
}


#pragma mark - NSObject

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - ScreenSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
	if ((self = [super initWithFrame:frame isPreview:isPreview])) {
		[self setAnimationTimeInterval:1.0 / 4.0];
		self.wantsLayer = YES;

		ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:SAMClockDefaultsModuleName];
		[defaults registerDefaults:@{
			SAMClockStyleDefaultsKey: @(SAMClockStyleLight),
			SAMClockStyleDefaultsKey: @(SAMClockStyleDark),
			SAMClockTickMarksDefaultsKey: @YES,
			SAMClockNumbersDefaultsKey: @YES,
			SAMClockDateDefaultsKey: @YES,
			SAMClockLogoDefaultsKey: @NO
		}];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configurationDidChange:) name:SAMClockConfigurationDidChangeNotificationName object:nil];
		[self configurationDidChange:nil];
	}
	return self;
}


- (void)startAnimation {
    [super startAnimation];
}


- (void)stopAnimation {
    [super stopAnimation];
}


- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];

	CGSize size = rect.size;

	NSColor *handColor;
	NSColor *backgroundColor;
	NSColor *clockBackgroundColor;
	NSColor *secondsColor = [NSColor colorWithCalibratedRed:0.965 green:0.773 blue:0.180 alpha:1];

	if (self.faceStyle == SAMClockStyleLight) {
		handColor = [NSColor colorWithCalibratedRed:0.039f green:0.039f blue:0.043f alpha:1.0f];
		clockBackgroundColor = [NSColor colorWithCalibratedRed:0.996f green:0.996f blue:0.996f alpha:1.0f];
	} else {
		backgroundColor = [NSColor whiteColor];
		handColor = [NSColor colorWithCalibratedRed:0.988f green:0.992f blue:0.988f alpha:1.0f];
		clockBackgroundColor = [NSColor colorWithCalibratedRed:0.129f green:0.125f blue:0.141f alpha:1.0f];
	}

	if (self.backgroundStyle == SAMClockStyleLight) {
		backgroundColor = self.faceStyle == SAMClockStyleDark ? [NSColor whiteColor] : [NSColor colorWithCalibratedRed:0.996f green:0.996f blue:0.996f alpha:1.0f];
	} else {
		backgroundColor = self.faceStyle == SAMClockStyleLight ? [NSColor blackColor] : [NSColor colorWithCalibratedRed:0.129f green:0.125f blue:0.141f alpha:1.0f];
	}

	// Screen background
	[backgroundColor setFill];
	[NSBezierPath fillRect:rect];

	// Clock background
	[clockBackgroundColor setFill];
	CGRect frame = [self clockFrameForBounds:self.bounds];
	CGFloat width = frame.size.width;
	NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:frame];
	path.lineWidth = 4.0f;
	[path fill];

	CGFloat twoPi = M_PI * 2.0f;
	CGFloat angleOffset = M_PI_2;
	CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));

	if (self.drawsTicks) {
		// Ticks divider
		CGFloat dividerPosition = 0.074960128f;
		[[backgroundColor colorWithAlphaComponent:0.05f] setStroke];
		path = [NSBezierPath bezierPathWithOvalInRect:CGRectInset(frame, frame.size.width * dividerPosition, frame.size.width * dividerPosition)];
		path.lineWidth = 1.0f;
		[path stroke];

		// Ticks
		CGFloat tickLength = ceilf(width * -0.049441786f);
		CGFloat tickRadius = ceilf(width * 0.437799043f);
		for (NSUInteger i = 0; i < 60; i++) {
			BOOL large = (i % 5) == 0;
			CGFloat angle = -((CGFloat)i / 60.0f * twoPi) + angleOffset;
			NSBezierPath *path = [NSBezierPath bezierPath];
			[path moveToPoint:CGPointMake(center.x + cosf(angle) * (tickRadius - tickLength), center.y + sinf(angle) * (tickRadius - tickLength))];
			[path lineToPoint:CGPointMake(center.x + cosf(angle) * tickRadius, center.y + sinf(angle) * tickRadius)];
			path.lineWidth = ceilf(width * (large ? 0.009569378f : 0.004784689f));
			[large ? handColor : [handColor colorWithAlphaComponent:0.5f] setStroke];
			[path stroke];
		}
	}


	// Numbers
	if (self.drawsNumbers) {
		CGFloat textRadius = frame.size.width * 0.402711324f;

		for (NSUInteger i = 0; i < 12; i++) {
			NSString *text = [NSString stringWithFormat:@"%i", ((int)i - 12 % 12) ?: 12];
			NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
			NSRange range = NSMakeRange(0, string.length);
			[string addAttribute:NSForegroundColorAttributeName value:handColor range:range];
			[string addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue-Light" size:ceilf(width * 0.071770334f)] range:range];
			[string addAttribute:NSKernAttributeName value:@(ceilf(width * -0.01275917f)) range:range];

			CGSize stringSize = [string size];
			CGFloat angle = -((CGFloat)i / 12.0f * twoPi) + angleOffset;
			CGRect rect = CGRectMake(center.x + cosf(angle) * (textRadius - (stringSize.width / 2.0f)), center.y + sinf(angle) * (textRadius - (stringSize.height / 2.0f)), stringSize.width, stringSize.height);
			rect.origin.x -= stringSize.width / 2.0f;
			rect.origin.y -= stringSize.height / 2.0f;

			[string drawInRect:rect];
		}
	}

	// Get time components
	NSDate *date = [NSDate date];
	NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:date];

	// Date
	if (self.drawsDate) {
		NSColor *dateArrowColor = [NSColor colorWithCalibratedRed:0.847f green:0.227f blue:0.286f alpha:1.0f];
		NSColor *dateBackgroundColor = [NSColor colorWithCalibratedRed:0.894f green:0.933f blue:0.965f alpha:1.0f];

		CGFloat dateWidth = ceilf(width * 0.057416268f);
		CGRect dateFrame = CGRectIntegral(CGRectMake(frame.origin.x + ((width - dateWidth) / 2.0f), frame.origin.y + (width * 0.199362041f), dateWidth, width * 0.071770335f));

		[dateBackgroundColor setFill];
		[NSBezierPath fillRect:dateFrame];

		[handColor setFill];

		NSString *text = [NSString stringWithFormat:@"%i", (int)comps.day];
		NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
		NSRange range = NSMakeRange(0, string.length);
		[string addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue-Light" size:ceilf(width * 0.044657098f)] range:range];
		[string addAttribute:NSKernAttributeName value:@(ceilf(width * -0.01275917f)) range:range];

		CGRect stringFrame = dateFrame;
		stringFrame.size = [string size];
		stringFrame.origin.x += (dateFrame.size.width - stringFrame.size.width) / 2.0f;
		stringFrame.origin.y += width * 0.003189793f;
		[string drawInRect:CGRectIntegral(stringFrame)];

		[dateArrowColor setFill];
		CGFloat y = CGRectGetMaxY(dateFrame) + ceilf(width * 0.015948963f);
		CGFloat height = ceilf(width * 0.022328549f);
		CGFloat pointDip = ceilf(width * 0.009569378f);

		NSBezierPath *path = [NSBezierPath bezierPath];
		[path moveToPoint:CGPointMake(CGRectGetMinX(dateFrame), y)];
		[path lineToPoint:CGPointMake(CGRectGetMinX(dateFrame), y - height)];
		[path lineToPoint:CGPointMake(CGRectGetMidX(dateFrame), y - height - pointDip)];
		[path lineToPoint:CGPointMake(CGRectGetMaxX(dateFrame), y - height)];
		[path lineToPoint:CGPointMake(CGRectGetMaxX(dateFrame), y)];
		[path lineToPoint:CGPointMake(CGRectGetMidX(dateFrame), y - pointDip)];
		[path fill];
	}

	// Logo
	if (self.logoImage) {
		NSImage *image = self.logoImage;
		CGSize imageSize = image.size;
		imageSize.width = ceilf(width * 0.156299841f);
		imageSize.height *= (imageSize.width / image.size.width);
		[image drawInRect:CGRectMake(roundf((size.width - imageSize.width) / 2.0f), frame.origin.y + ceilf(width * 0.622009569f), imageSize.width, imageSize.height)];
	}

	CGFloat seconds = (CGFloat)comps.second / 60.0f;
	CGFloat minutes = ((CGFloat)comps.minute / 60.0f) + (seconds / 60.0f);
	CGFloat hours = ((CGFloat)comps.hour / 12.0f) + ((minutes / 60.0f) * (60.0f / 12.0f));

	// Hours
	[[handColor colorWithAlphaComponent:0.7f] setStroke];
	CGFloat angle = -(twoPi * hours) + angleOffset;
	[self drawHandWithSize:CGSizeMake(ceilf(width * 0.023125997f), ceilf(width * 0.263955343f)) angle:angle lineCapStyle:NSSquareLineCapStyle];

	// Minutes
	[handColor setStroke];
	angle = -(twoPi * minutes) + angleOffset;
	[self drawHandWithSize:CGSizeMake(ceilf(width * 0.014354067f), ceilf(width * 0.391547049f)) angle:angle lineCapStyle:NSSquareLineCapStyle];

	// Seconds
	[secondsColor set];
	angle = -(twoPi * seconds) + angleOffset;
	[self drawHandWithSize:CGSizeMake(ceilf(width * 0.009569378f), ceilf(width * 0.391547049f)) angle:angle lineCapStyle:NSSquareLineCapStyle];

	// Counterweight
	[self drawHandWithSize:CGSizeMake(ceilf(width * 0.028708134f), -ceilf(width * 0.076555024f)) angle:angle lineCapStyle:NSRoundLineCapStyle];

	// Counterweight circle
	CGFloat nubSize = ceilf(width * 0.052631579f);
	frame = CGRectMake(ceilf((size.width - nubSize) / 2.0f), ceilf((size.height - nubSize) / 2.0f), nubSize, nubSize);
	path = [NSBezierPath bezierPathWithOvalInRect:frame];
	[path fill];

	// Screw
	CGFloat dotSize = ceilf(width * 0.006379585f);
	[[NSColor blackColor] setFill];
	frame = CGRectMake(ceilf((size.width - dotSize) / 2.0f), ceilf((size.height - dotSize) / 2.0f), dotSize, dotSize);
	path = [NSBezierPath bezierPathWithOvalInRect:frame];
	[path fill];
}


- (void)animateOneFrame {
	[self setNeedsDisplay:YES];
}


- (BOOL)hasConfigureSheet {
    return YES;
}


- (NSWindow *)configureSheet {
    return self.configureWindowController.window;
}


#pragma mark - Private

- (CGRect)clockFrameForBounds:(CGRect)bounds {
	CGSize size = bounds.size;
	CGFloat clockSize = MIN(size.width, size.height) * 0.55f;
	return CGRectMake(ceilf((size.width - clockSize) / 2.0f), ceilf((size.height - clockSize) / 2.0f), clockSize, clockSize);
}


// The size's height is the hand length. The size's width is the hand width, duh.
- (void)drawHandWithSize:(CGSize)size angle:(CGFloat)angle lineCapStyle:(NSLineCapStyle)lineCapStyle {
	CGRect frame = [self clockFrameForBounds:self.bounds];
	CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
	CGPoint point = CGPointMake(center.x + cosf(angle) * size.height, center.y + sinf(angle) * size.height);

	NSBezierPath *path = [NSBezierPath bezierPath];
	[path moveToPoint:center];
	[path lineToPoint:point];
	path.lineWidth = size.width;
	path.lineCapStyle = lineCapStyle;
	[path stroke];
}


- (void)configurationDidChange:(NSNotification *)notification {
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:SAMClockDefaultsModuleName];

	self.faceStyle = [defaults integerForKey:SAMClockStyleDefaultsKey];
	self.backgroundStyle = [defaults integerForKey:SAMClockBackgroundStyleDefaultsKey];
	self.drawsTicks = [defaults boolForKey:SAMClockTickMarksDefaultsKey];
	self.drawsNumbers = [defaults boolForKey:SAMClockNumbersDefaultsKey];
	self.drawsDate = [defaults boolForKey:SAMClockDateDefaultsKey];
	self.drawsLogo = [defaults boolForKey:SAMClockLogoDefaultsKey];

	if (self.drawsLogo) {
#if DEMO
		self.logoImage = [NSImage imageNamed:self.faceStyle == SAMClockStyleLight ? @"braun-dark" : @"braun-light"];
#else
		NSBundle *bundle = [NSBundle bundleWithIdentifier:SAMClockDefaultsModuleName];
		NSString *path = [bundle pathForResource:self.faceStyle == SAMClockStyleLight ? @"braun-dark" : @"braun-light" ofType:@"pdf"];
		self.logoImage = [[NSImage alloc] initWithContentsOfFile:path];
#endif
	} else {
		self.logoImage = nil;
	}
}

@end
