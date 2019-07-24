#import "TCNViewUtils.h"

@implementation TCNViewUtils

+ (BOOL)isLayoutDirectionRTL {
    return UIApplication.sharedApplication.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
}

+ (void)layoutSubviewsForRTL:(nonnull UIView *)view {
    if (![self isLayoutDirectionRTL]) {
        return;
    }

    for (UIView *const subview in view.subviews) {
        CGRect subviewRTLFrame = subview.frame;
        subviewRTLFrame.origin.x = CGRectGetWidth(view.frame) - CGRectGetMaxX(subview.frame);
        subview.frame = subviewRTLFrame;
        [self layoutSubviewsForRTL:subview];
    }
}

@end
