**NOTICE:** I am no longer maintaining this project because of the lack of time. All the Objective C works. Project is completely open. Use it for anything you want.


#Purpose
FXTranslucency is a subclass that replicates the iOS 7 realtime translucency blur effect, but works on iOS 8.x and will be written in Swift. It is designed to be as fast and as simple to use as possible. It can be used on all iOS devices in real time without performance problems. The subclass also supports smooth animation's in the UIView; ranging from color, frame, alpha and more! FXTranslucency offers two modes of operation: static, where the view is rendered only once when it is added to a superview or dynamic, where it will automatically redraw itself on a background thread as often as possible.

###Supported iOS & SDK Versions
FXTranslucency supports the iOS 8.0 (Xcode 6.0, Apple LLVM compiler 6.0) build targets. The earliest supported developer target is iOS 6.x on the iPhone, iPad and iPod Touch. iOS 6.x to iOS 8.x is supported.

###ARC Compatibility
FXTranslucency requires ARC. If you wish to use FXTranslucency in a non-ARC project, just add the -fobjc-arc compiler flag to the FXTranslucency.m class. To do this, go to the Build Phases tab in your target settings, open the Compile Sources group, double-click FXTranslucency.m in the list and type -fobjc-arc into the popover.

If you wish to convert your whole project to ARC, comment out the #error line in FXTranslucency.m, then run the Edit > Refactor > Convert to Objective-C ARC... tool in Xcode and make sure all files that you wish to use ARC for (including FXTranslucency.m) are checked.

##Installation
To use FXTranslucency, just drag the class files into your project and add the Accelerate framework. You can add the framework by writing **Objective C:** `@import Accelerate;` or **Swift:** `import Accelerate` in the classes you're wanting to use FXTranslucency in, or in the target.

You can create FXTranslucency instances programatically, or create them in Interface Builder by dragging an ordinary UIView into your view and setting its class to FXTranslucency. If you are using Interface Builder, to set the custom properties of FXTranslucency (ones that are not supported by regular UIViews) either create an IBOutlet for your view and set the properties in code, or use the User Defined Runtime Attributes feature in Interface Builder (introduced in Xcode 4.2 for iOS 5+).

###Setup

You can use FXTranslucency as a normal UIView with additional methods and properties. This method applies a translucent blur effect and returns the blurred layout without modifying the original graphic/lower level content. 

```objectivec
FXTranslucency *translucentView = [[FXTranslucency alloc] initWithFrame:CGRectMake(0, 0, 250, 150)];
[self.view addSubview:translucentView];

translucentView.translucentAlpha = 1;
translucentView.translucentStyle = UIBarStyleDefault;
translucentView.translucentTintColor = [UIColor clearColor];
translucentView.backgroundColor = [UIColor clearColor];
```

Here we can explain the additional features in the initial version of FXTranslucency. **Notice:** Features are subject to change in future versions. 

| Method  | Description and Usage |
| ------------- | ------------- |
| translucentAlpha  | The translucent's alpha value. The value of this property is a floating-point number in the range 0.0 to 1.0, where 0.0 represents view without translucent effect and 1.0 represents maximum translucent effect.  |
| translucentStyle  | TranslucentView uses UIToolbar to provide translucent effect. This property specifies its appearance.  |
| translucentTintColor  | The tint color to apply to the translucent color.  |
| translucentColor  | For iOS 6-, this is the view’s background color. For iOS 7+ it represents background color of layer above translucent layer.  |
