#import <Foundation/Foundation.h>

@interface TCNEvent : NSObject

/**
 The name of the event.
 */
@property (nonatomic, copy, nonnull, readonly) NSString *name;

/**
 A string describing the location of the event.
 */
@property (nonatomic, copy, nullable, readonly) NSString *location;

/**
 Timezone info related to the event.
 */
@property (nonatomic, strong, nullable, readonly) NSTimeZone *timezone;

/**
 Start time and date of the event.
 */
@property (nonatomic, strong, nonnull, readonly) NSDate *startDateTime;

/**
 End time and date of the event.
 */
@property (nonatomic, strong, nonnull, readonly) NSDate *endDateTime;

/**
 Whether the event is a full day event.
 */
@property (nonatomic, assign, readonly) BOOL isAllDay;

/**
 Whether the event is created due to a user selection action.
 */
@property (nonatomic, assign, readwrite) BOOL isSelected;

/**
 A human-readable string for this event's time and duration.
 */
@property (nonatomic, copy, nonnull, readonly) NSString *displayTimeString;

/**
 A new event with the specified data.

 @return An instance of @c TCNEvent, assuming the provided input is valid.
         A valid input has an endDateTime equal to or later than the startDateTime.
 */
- (nullable instancetype)initWithName:(nonnull NSString *)name
                        startDateTime:(nonnull NSDate *)startDateTime
                          endDateTime:(nonnull NSDate *)endDateTime
                             location:(nullable NSString *)location
                             timezone:(nullable NSTimeZone *)timezone
                             isAllDay:(BOOL)isAllDay;

/**
 A new @c TCNEvent with @c startDateTime and a length of one hour.

 @param name The event name or title.
 @param startDateTime The starting time of the event.
 @return A @c TCNEvent instance with a duration of one hour.
 */
- (nonnull instancetype)initWithName:(nonnull NSString *)name
                       startDateTime:(nonnull NSDate *)startDateTime;

/**
 Asks if this event occurs on the given date.

 @param date The reference date.
 @return YES if the event occurs on the same day as the given date, NO otherwise. If this is a multi-day event,
         @c YES if any part of this event occurs on the same day as the given date.
 */
- (BOOL)occursOnDay:(nonnull NSDate *)date;

/**
 Merges overlapping and adjacent events in an array of @c TCNEvent objects.
 Merged events will adopt all of the properties of the earliest composing event besides the end time.

 @param events The array of events to merge.
 @return The sequence of events provided, with all adjacent or overlapping events merged into one.
         All day events are not merged and are also returned in the resulting sequence.
 */
+ (nonnull NSArray<TCNEvent *> *)mergedEventsForEvents:(nonnull NSArray<TCNEvent *> *)events;

@end
