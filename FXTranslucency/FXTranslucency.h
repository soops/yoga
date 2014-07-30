//
//  FXTranslucency.h
//  Created by Douglas Bumby on 2014-07-20.
//

@import UIKit;
@import Accelerate.vecLib;
@import CoreGraphics.CGColor;

@interface FXTranslucency : UIView <UIBarPositioning, UIBarPositioningDelegate>

/// @documentation
/// This property is used to decide if you want the translucent blur effect enabled.
/// Default is `YES`. Translucency Alpha Effect has a default value of `1`.

@property (nonatomic) BOOL translucent;
@property (nonatomic) CGFloat translucentAlpha;

/// @documentation
/// The blur styles include: Default, Black and the Tint Color of the blur.
/// The `clearColor` value as a UIColor is the default.

@property (nonatomic) UIBarStyle translucentStyle;
@property (nonatomic, strong) UIColor *translucentTintColor;

@end
