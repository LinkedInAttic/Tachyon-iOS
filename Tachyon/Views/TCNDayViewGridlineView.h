#import <UIKit/UIKit.h>

#import "TCNReusableView.h"

/**
 A simple divider view, used in @c TCNDayView collection views for calendar lines.
 */
@interface TCNDayViewGridlineView : UICollectionReusableView <TCNReusableView>

/**
 The reuse identifier for this decoration view.
 */
@property (nonatomic, copy, nonnull, class, readonly) NSString *reuseIdentifier;

/**
 A string identifier for the dark gridline.
 */
@property (nonatomic, copy, nonnull, class, readonly) NSString *darkKind;

/**
 A string identifier for the light gridline.
 */
@property (nonatomic, copy, nonnull, class, readonly) NSString *lightKind;

@end
