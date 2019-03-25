#import <UIKit/UIKit.h>
#import "TCNDayViewConfig.h"
#import "TCNReusableView.h"

/**
 Displays a label denoting the hour or time of an associated time slot on a @c TCNDayView.
 */
@interface TCNDayViewTimeView : UICollectionReusableView <TCNDayViewConfigurable>

/**
 The reuse identifier for this cell type.
 */
@property (nonatomic, copy, nonnull, class, readonly) NSString *reuseIdentifier;

/**
 Setting this property automatically updates the label indicating the time appropriately.
 */
@property (nonatomic, strong, nonnull, readwrite) NSDate *time;

/**
 Updates the label to the all day event text specified by the parent day view's @c TCNDayViewConfig.
 */
- (void)updateAllDayEventText;

@end
