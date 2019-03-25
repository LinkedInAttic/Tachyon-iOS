#import <UIKit/UIKit.h>
#import "TCNDayViewConfig.h"

@class TCNDayViewLayout;

#pragma mark - TCNDayViewLayoutDelegate

/**
 Classes implementing this protocol are responsible for providing information necessary to layout a @c TCNDayView correctly.
 */
@protocol TCNDayViewLayoutDelegate <UICollectionViewDelegate>

/**
 Asks for an event start time at the given index path. The layout will then use this start time
 to render any events at this index path.

 @param collectionView The calling collection view.
 @param layout The calling layout.
 @param indexPath The index path for which to return information.
 @return An @c NSDate start time.
 */
- (nonnull NSDate *)collectionView:(nullable UICollectionView *)collectionView
                            layout:(nonnull TCNDayViewLayout *)collectionViewLayout
       startTimeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;

/**
 Asks for an event end time at the given index path. The layout will then use this end time
 to render any events at this index path.

 @param collectionView The calling collection view.
 @param layout The calling layout.
 @param indexPath The index path for which to return information.
 @return An @c NSDate end time.
 */
- (nonnull NSDate *)collectionView:(nullable UICollectionView *)collectionView
                            layout:(nonnull TCNDayViewLayout *)collectionViewLayout
         endTimeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;

/**
 Asks if the event at the given index path should have its layout adjusted to accomodate other events
 at that index path. If false, this event will lay on top of other events in its time slot.

 @param collectionView The calling collection view.
 @param layout The calling layout.
 @param indexPath The index path for which to return information.
 @return YES if the event should have layout adjusted, NO otherwise.
 */
- (BOOL)collectionView:(nullable UICollectionView *)collectionView
                                layout:(nonnull TCNDayViewLayout *)collectionViewLayout
  shouldAdjustLayoutForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;

@end

#pragma mark - TCNDayViewLayout

/**
 The default layout for the @c TCNDayView non-all day collection view.

 For the layout used for the all day event collection view, refer to @c TCNAllDayViewLayout.
 */
@interface TCNDayViewLayout : UICollectionViewLayout

/**
 The collection view's default top content inset.
 */
@property (nonatomic, assign, class, readonly) CGFloat topInsetMargin;

/**
 The delegate of this @c TCNDayViewLayout.
 */
@property (nonatomic, weak, nullable, readwrite) id<TCNDayViewLayoutDelegate> delegate;

/**
 A new day view layout with the specified @c config.

 @param config The configuration object for UI styling.
 @return A @c TCNDayViewLayout instance.
 */
- (nonnull instancetype)initWithConfig:(nonnull TCNDayViewConfig *)config NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_UNAVAILABLE;

- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 The offset for the top of the time slot specified by @c indexPath.

 @param indexPath An index path corresponding to a time slot.
 @param minY The reference Y value corresponding to the top of the day view time slots.
 @return A floating point offset for the given indexPath.
 */
+ (CGFloat)offsetForIndexPath:(nonnull NSIndexPath *)indexPath minY:(CGFloat)minY;

/**
 An NSDate with nil date components, with the hour and minute set according to the provided collection view offset.

 @param offset A Y value corresponding to a time of day.
 @return A date corresponding to the provided y value.
 */
+ (nonnull NSDate *)timeForYOffset:(CGFloat)offset;

@end
