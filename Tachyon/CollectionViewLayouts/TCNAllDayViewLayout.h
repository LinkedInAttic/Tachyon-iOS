#import <UIKit/UIKit.h>
#import "TCNDayViewLayout.h"

/**
 The default collection view layout for an all day event collection view.

 For the layout used in the standard event collection view, refer to @c TCNDayViewLayout.
 */
@interface TCNAllDayViewLayout : TCNDayViewLayout

/**
 Asks for the required height for an all day view, given @c eventCount.

 @param eventCount The number of events.
 @return A floating-point height for the all day view.
 */
+ (CGFloat)allDayViewHeightForEventCount:(NSInteger)eventCount;

@end
