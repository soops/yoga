//
//  FXTranslucency.m
//  Created by Douglas Bumby on 2014-07-20.
//

#import "FXTranslucency.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface FXTranslucency () {
    
#pragma mark - Documentation
#pragma mark - The UIView's, UIToolbar and BOOL values have been made.
#pragma mark - Methods are below.
    
    UIView *nonexistentSubView;
    UIView *toolbarContainerClipView;
    UIToolbar *toolBarBG;
    UIView *overlayBackgroundView;
    BOOL initComplete;
}

#pragma mark - Documentation
#pragma mark - The properties are for the backgrounds colour and the default background
#pragma mark - colour of the UIToolBars in the UIViewController.

@property (nonatomic, copy) UIColor *ColorBG;
@property (nonatomic, copy) UIColor *DefaultColorBG;

@end

@implementation FXTranslucency
@synthesize translucentAlpha = _translucentAlpha;

#pragma mark - Initalization
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createUI];
    }
    
    // Return the CGRect.
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    // Used for XIB's and Storyboards.
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self createUI];
    }
    
    // Return the NSCoder.
    return self;
}

- (void) createUI {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        _ColorBG = self.backgroundColor;
        self.DefaultColorBG=toolBarBG.barTintColor;
        
#pragma mark - Documentation
#pragma mark - ColorBG is getting the background color of the UIView.
#pragma mark - This can optionally be set through the Interface Builder.
#pragma mark - The DefaultColorBG is retrieving Apple's default background color of the UIToolBar.
        
        _translucent = YES;
        _translucentAlpha = 1;
        
        /// Creating the non-existent subview.
        nonexistentSubView = [[UIView alloc] initWithFrame:self.bounds];
        nonexistentSubView.backgroundColor = [UIColor clearColor];
        nonexistentSubView.clipsToBounds = YES;
        nonexistentSubView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin; // Different Formats and Margins
        
        [self insertSubview:nonexistentSubView atIndex:0];
        
        /// Creating the toolbarContainerClipView Method
        toolbarContainerClipView = [[UIView alloc] initWithFrame:self.bounds];
        toolbarContainerClipView.backgroundColor = [UIColor clearColor];
        toolbarContainerClipView.clipsToBounds = YES;
        toolbarContainerClipView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [nonexistentSubView addSubview:toolbarContainerClipView];
        
        /// Creating the toolbar background; we must clip a one pixel line on the top of the toolbar.
        CGRect rect = self.bounds;
        rect.origin.y -= 1; // Y axis
        rect.size.height += 1; // Height Value
        toolBarBG = [[UIToolbar alloc] initWithFrame:rect];
        toolBarBG.frame = rect;
        toolBarBG.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [toolbarContainerClipView addSubview:toolBarBG];
        
        /// Viewing above the toolbar. Great for changing blur effect in color environments.
        overlayBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        overlayBackgroundView.backgroundColor = self.backgroundColor;
        overlayBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [toolbarContainerClipView addSubview:overlayBackgroundView];
        
        /// The view must be transparent.
        [self setBackgroundColor: [UIColor clearColor]];
        
        /// Alternate Option: 'self.setBackgroundColor = [UIColor clearColor];'
        initComplete = YES;
        
    }
}

#pragma mark - Configuring a View's Visual Appearance

- (BOOL) isItClearColor: (UIColor *) color {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed: &red green: &green blue: &blue alpha: &alpha];
    if (red != 0 || green != 0 || blue != 0 || alpha != 0) {
        
        return NO;
        
#pragma mark - Documentation
#pragma mark - If "NO" doesn't work it will return "YES"
        
    } else {
        
        return YES;
    }
}

- (void) setFrame:(CGRect)frame {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect rect = frame;
        rect.origin.x = 0; // X axis
        rect.origin.y = 0; // Y axis
        
#pragma mark - Documentation
#pragma mark - Setting the frame of the View.
#pragma mark - The UIToolbar's frame is not /that/ great at animating. It produces a lot of glitches/bugs.
#pragma mark - Because of that, we will never actually reduce the size of a toolbar.
        
        if (toolbarContainerClipView.frame.size.width > rect.size.width) {
            rect.size.width = toolbarContainerClipView.frame.size.width;
        }
        
        if (toolbarContainerClipView.frame.size.height > rect.size.height) {
            rect.size.height = toolbarContainerClipView.frame.size.height;
        }
        
        toolbarContainerClipView.frame = rect;
        [super setFrame:frame];
        
        // self.bounds for nonexistentSubview
        [nonexistentSubView setFrame:self.bounds];
        
    } else
        [super setFrame:frame];
}

- (void) setBounds:(CGRect)bounds {
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect rect = bounds;
        rect.origin.x = 0; // X axis
        rect.origin.y = 0; // Y axis

#pragma mark - Documentation
#pragma mark - The UIToolbar's have bounds, and they're not /that/ great at animating. Like before,
#pragma mark - it produces a lot of glitches/bugs. Because of that we're never actually
#pragma mark - going to reduce the size of the toolbar.
        
        if (toolbarContainerClipView.bounds.size.width > rect.size.width) {
            rect.size.width = toolbarContainerClipView.bounds.size.width;
            // bounds x size x width = output
        }
        
        if (toolbarContainerClipView.bounds.size.height > rect.size.height) {
            rect.size.height = toolbarContainerClipView.bounds.size.height;
            // rect + size x height = output
        }
        
        toolbarContainerClipView.bounds = rect;
        [super setBounds:bounds];
        [nonexistentSubView setFrame:self.bounds];
        
    } else
        
        [super setBounds:bounds];
}

- (void) setTranslucentStyle:(UIBarStyle)translucentStyle {
    toolBarBG.barStyle = translucentStyle;
}

- (UIBarStyle) translucentStyle {
    return toolBarBG.barStyle;
}

- (void) setTranslucentTintColor:(UIColor *)translucentTintColor {
    _translucentTintColor = translucentTintColor;
    // The tint colour of UIToolbar
    
    if ([self isItClearColor:translucentTintColor])
        [toolBarBG setBarTintColor:self.DefaultColorBG];
    // Or we can do...
    else
        [toolBarBG setBarTintColor:translucentTintColor];
}

- (void) setBackgroundColor:(UIColor *)backgroundColor {
    
#pragma mark - @documentation
#pragma mark - We're manipulating the 'backgroundColor of the view.
#pragma mark - Actually change the tintColor of the Toolbar
    
    if (initComplete) {
        
        self.ColorBG = backgroundColor;
        if (_translucent) {
            overlayBackgroundView.backgroundColor = backgroundColor;
            [super setBackgroundColor: [UIColor clearColor]];
            // Clear the UIColor
        } else {
            
            [super setBackgroundColor:self.ColorBG];
        }
    } else
        
        [super setBackgroundColor:backgroundColor];
}

- (void) setTranslucent:(BOOL)translucent {
    // Enabling and Disabling the Blur effect on the UIViewController's
    _translucent = translucent;
    
    toolBarBG.translucent = translucent;
    if (translucent) {
        toolBarBG.hidden = NO;
        [toolBarBG setBarTintColor:self.ColorBG];
        [self setBackgroundColor: [UIColor clearColor]];
    } else {
        toolBarBG.hidden=YES;
        [self setBackgroundColor:self.ColorBG];
    }
}

- (void) setTranslucentAlpha:(CGFloat)translucentAlpha {
    
    if (translucentAlpha > 1)
        _translucentAlpha = 1;
    else if (translucentAlpha < 0)
        _translucentAlpha = 0;
    else
        
    _translucentAlpha = translucentAlpha;
    toolBarBG.alpha = translucentAlpha;
}

#pragma mark = Managing the View Hierarchy

- (NSArray *) subviews {
    // Must exclude the 'nonexistentSubview'.
    
    if (initComplete) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:[super subviews]];
        [array removeObject:nonexistentSubView];
        return (NSArray *)array;
    }
    else {
        return [super subviews];
    }
}

- (void) sendSubviewToBack:(UIView *)view {
    if (initComplete) {
        [self insertSubview:view aboveSubview:toolbarContainerClipView];
        return; // Returning all values
    }
    else
        [super sendSubviewToBack:view];
}

- (void) insertSubview:(UIView *)view atIndex:(NSInteger)index {
    // We will again, exclude the 'nonexistentSubview' property
    
    if (initComplete) {
        [super insertSubview:view atIndex:(index+1)];
    }
    else
        // Insert the View into the Subview Family
        [super insertSubview:view atIndex:index];
}

- (void) exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2 {
    // Excluding the 'nonexistentSubview' property
    
    if (initComplete)
        [super exchangeSubviewAtIndex:(index1 + 1) withSubviewAtIndex:(index2+1)];
    else
        [super exchangeSubviewAtIndex:(index1) withSubviewAtIndex:(index2)];
}

@end
