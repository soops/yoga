PressableButton Subclass
==============

Forked copy of HTPressableButton by <a href="http://www.github.com/herinkc">@herinkc</a>. Designed for iOS Developers to have the ability to spend time developing ideas, not building the basic buttons. These stylish, flat-designed buttons can easily be modified and are perfect for almost any project. With no worry over color choice, HTPressableButton also includes beautiful color schemes that perfectly suit with your app.

**Compatible with:**  iOS 7.1 and above

**Current Version:** 0.1

You can check out the original documentation [here](http://cocoadocs.org/docsets/HTPressableButton/). 

Installation
-------------------
HTPressableButton can be installed via [Cocoapods](http://cocoapods.org/)

```ruby
pod 'HTPressableButton'
```

You may also quickly try the HTPressableButton example project with

```ruby
pod try 'HTPressableButton'
```

However, if you are only interested to use the color scheme provided (shown below) then

```ruby
pod 'HTPressableButton/HTColor'
```

Another option is to use git submodules or just [download it](https://github.com/Grouper/FlatUIKit/archive/master.zip) and include it in your project manually.

**NOTE:** Please be reminded to add the header files to your project. You may add only the one that you'll use. 

```objective-c
#import "HTPressableButton.h"
#import "UIColor+HTColor.h"
```

<br>

Button Types
-------------------

**IMPORTANT:** You must specify the *frame* first. Also, do not forget to choose the *style* of the button you wish to add to your app.

###Rectangular Button
```objective-c
    HTPressableButton *rectButton = [HTPressableButton buttonWithType:UIButtonTypeCustom];
    rectButton.frame = CGRectMake(30, 150, 260, 50);
    rectButton.buttonColor = [UIColor grapeFruitColor];
    rectButton.shadowColor = [UIColor grapeFruitDarkColor];
    rectButton.style = HTPressableButtonStyleRect;
    [rectButton setTitle:@"Rect" forState:UIControlStateNormal];
    [self.view addSubview:rectButton];
```

![HTPressableButton](https://raw.github.com/herinkc/HTPressableButton/master/READMEImages/RectButtonImage.gif)

<br>

###Rounded Rectangular Button
```objective-c
    HTPressableButton *roundedRectButton = [HTPressableButton buttonWithType:UIButtonTypeCustom];
    roundedRectButton.frame = CGRectMake(30, 230, 260, 50);
    roundedRectButton.style = HTPressableButtonStyleRounded;
    [roundedRectButton setTitle:@"Rounded" forState:UIControlStateNormal];
    [self.view addSubview:roundedRectButton];
```

![HTPressableButton](https://raw.github.com/herinkc/HTPressableButton/master/READMEImages/RoundedRectButtonImage.gif)

<br>

###Circular Button
```objective-c
    //Circular mint color button
    HTPressableButton *circularButton = [HTPressableButton buttonWithType:UIButtonTypeCustom];
    circularButton.frame = CGRectMake(110, 300, 100, 100);
    circularButton.style = HTPressableButtonStyleCircular;
    circularButton.buttonColor = [UIColor mintColor];
    circularButton.shadowColor = [UIColor mintDarkColor];
    [circularButton setTitle:@"Circular" forState:UIControlStateNormal];
    [self.view addSubview:circularButton];
```

![HTPressableButton](https://raw.github.com/herinkc/HTPressableButton/master/READMEImages/CircularButtonImage.gif)

<br>

###Disabled Button
If you wish to create a disabled button, add:
```object-c
	buttonNameHere.enabled = NO;
```
Example:
```objective-c
    HTPressableButton *disabledRoundedRectButton = [HTPressableButton buttonWithType:UIButtonTypeCustom];
    disabledRoundedRectButton.frame = CGRectMake(30, 420, 260, 50);
    disabledRoundedRectButton.style = HTPressableButtonStyleRounded;
    disabledRoundedRectButton.disabledButtonColor = [UIColor pinkRoseColor];
    disabledRoundedRectButton.disabledShadowColor = [UIColor pinkRoseDarkColor];
    disabledRoundedRectButton.alpha = 0.5;
    disabledRoundedRectButton.enabled = NO;
	[disabledRoundedRectButton setTitle:@"DisabledButton" forState:UIControlStateNormal];
    [self.view addSubview:disabledRoundedRectButton];
```

![HTPressableButton](https://raw.github.com/herinkc/HTPressableButton/master/READMEImages/DisabledButtonImage.png)

The default *alpha* value is 1.0 for all type of buttons. The value can be changed (like the above button) by:
```objective-c
	buttonNameHere.alpha = 0.5;
```

<br>

**NOTE:** The default values of the buttons are:

| Attribute                    | Values                                           |
| ---------------------------- |:------------------------------------------------:|
| Font                         | Avenir                                           |
| Font Size                    | 18                                               |
| Shadow Height                | buttonSize * 0.17 `//17% of the button height`   |
| Button Color                 | jayColor                                         |
| Button Shadow Color          | jayDarkColor                                     |
| Disabled Button Color        | mediumColor                                      |
| Disabled Button Shadow Color | mediumDarkColor                                  |

<br>

###Additional Colors
You can freely use the additional colors in the file *UIColors+HTColor* anywhere in your project by:
```objective-c
    [UIColor colorNameHere]
    
    [UIColor jayColor]
    [UIColor pinkRoseDarkColor]
```
![HTPressableButton](https://raw.github.com/herinkc/HTPressableButton/master/READMEImages/HTPressableButtonColorScheme.png)

<br><br>

License
-------------------
Originally Developed by <a href="https://github.com/herinkc">He Rin Kim</a> and a group of others that can be found on the original repository, <a href="https://github.com/herinkc/HTPressableButton">here</a>.
