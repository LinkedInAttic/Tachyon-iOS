#import <UIKit/UIKit.h>
#import "TCNEvent.h"
#import "TCNDayViewConfig.h"

/**
 Represents a @c TCNEvent on a @c TCNDayView.
 */
@interface TCNEventCell : UICollectionViewCell <TCNDayViewConfigurable>

/**
 The reuse identifier for this cell type.
 */
@property (nonatomic, copy, nonnull, class, readonly) NSString *reuseIdentifier;

/**
 A code block that is called when the cancel "x" button is tapped on an event cell.
 */
@property (nonatomic, copy, nullable, readwrite) void(^cancelHandler)(void);

/**
 Populates the cell with the given @c TCNEvent.

 @param event A @c TCNEvent instance.
 */
- (void)updateWithEvent:(nonnull TCNEvent *)event;

@end
