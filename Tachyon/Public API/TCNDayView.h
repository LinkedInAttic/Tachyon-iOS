#import <UIKit/UIKit.h>
#import "TCNEvent.h"
#import "TCNDayViewConfig.h"

@class TCNDayView;

#pragma mark - TCNDayViewDelegate

/**
 Classes implementing this protocol may receive updates for UI events from the @c TCNDayView.
 */
@protocol TCNDayViewDelegate <NSObject>

/**
 Called when a timeslot is tapped on the calendar view and a selected event is created for that timeslot.

 The event created will have a start time equal to the nearest interval to the tap location,
 of interval granularity equal to @c TCNDayViewConfig.defaultEventLength.
 The event created will have a length equal to @c TCNDayViewConfig.defaultEventLength.

 @param dayView The @c TCNDayView responding to this UI event.
 @param event The new @c TCNEvent for the timeslot selected.
 */
- (void)dayView:(nonnull TCNDayView *)dayView didSelectAvailabilityWithEvent:(nonnull TCNEvent *)event;

/**
 Called when the cancel button on an event is tapped, or when a created event is tapped.

 @param dayView The @c TCNDayView responding to this UI event.
 @param event The cancelled @c TCNEvent.
 */
@optional
- (void)dayView:(nonnull TCNDayView *)dayView didCancelEvent:(nonnull TCNEvent *)event;

@end

#pragma mark - TCNDayViewDataSource

/**
 Classes implementing this protocol are responsible for providing the underlying data necessary to populate the
 @c TCNDayView.

 The day view contains two separate sections for all day events and non-all day events. This is implemented as
 two separate @c UICollectionView instances.
 */
@protocol TCNDayViewDataSource <NSObject>

/**
 The date for which the day view is currently displaying events.
 */
@property (nonatomic, strong, nonnull, readonly) NSDate *currentDate;

/**
 The events for this day that have specific time slots, i.e. not all-day events.

 e.g. In Apple EventKit, this would map to @c EKEvent.allDay == false
 */
@property (nonatomic, strong, nonnull, readonly) NSArray<TCNEvent *> *dayEvents;

/**
 The events for this day that span the entire day.

 e.g. In Apple EventKit, this would map to @c EKEvent.allDay == true.
 */
@property (nonatomic, strong, nonnull, readonly) NSArray<TCNEvent *> *allDayEvents;

@end

#pragma mark - TCNDayView

/**
 Displays a day's calendar event view. Users may interact with the day view to create new events.
 The day view also supports loading existing events from a data source, e.g. Apple EventKit.
 */
@interface TCNDayView : UIView

/**
 The day view's delegate, which may respond to events from the day view.
 */
@property (nonatomic, weak, nullable, readwrite) id<TCNDayViewDelegate> delegate;

/**
 The day view's data source, which is responsible for providing events to populate the view.
 */
@property (nonatomic, weak, nullable, readwrite) id<TCNDayViewDataSource> dataSource;

/**
 The default hour of the day view. Defaults to 8AM local time.
 */
@property (nonatomic, assign, readwrite) NSInteger defaultHour;

/**
 Initialize the day view with a frame and config. The config will be read during the initialization process.

 @param frame The starting frame.
 @param config The configuration object for UI styling.
 @return An @c TCNDayView instance.
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame config:(nonnull TCNDayViewConfig *)config NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Reloads the day view.

 This method should be called when a new date is selected for this day view.

 @param resetScrolling If true, the offset of the day will reset such that the @c defaultHour is at the top.
 */
- (void)reloadAndResetScrolling:(BOOL)resetScrolling
NS_SWIFT_NAME(reload(resetScrolling:));

@end
