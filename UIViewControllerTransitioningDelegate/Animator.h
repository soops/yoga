
/* CustomViewTransitions by Douglas Bumby (c) Apollo Creative */

#import <Foundation/Foundation.h>

@interface Animator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresented) BOOL presenting;

@end
