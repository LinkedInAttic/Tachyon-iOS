#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TCNViewUtils : NSObject

/**
 @return YES if the @c UIApplication layout direction is right to left.
 */
+ (BOOL)isLayoutDirectionRTL;

/**
 Recursively layouts this view and its subviews for right-to-left support.

 If the application's layout direction is not RTL, this is a no-op.

 @param view The view to lay out with RTL support.
 */
+ (void)layoutSubviewsForRTL:(nonnull UIView *)view;

@end
