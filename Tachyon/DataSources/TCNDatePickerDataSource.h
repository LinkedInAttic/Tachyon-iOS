#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TCNDatePickerConfig.h"

/**
 The default data source for @c TCNDatePickerView.

 This class handles logic for paging between weeks and dates.
 */
@interface TCNDatePickerDataSource : NSObject <UICollectionViewDataSource>

/**
 The days of the previous week. The previous week is the week chronologically prior
 to the currently visible week.
 */
@property (nonatomic, strong, nonnull, readonly) NSArray<NSDate *> *previousWeekDates;

/**
 The days of the current week. The current week is the currently visible week.
 */
@property (nonatomic, strong, nonnull, readonly) NSArray<NSDate *> *activeWeekDates;

/**
 The days of the next week. The next week is the week chronologically after
 the currently visible week.
 */
@property (nonatomic, strong, nonnull, readonly) NSArray<NSDate *> *nextWeekDates;

/**
 The currently selected date of the date picker. The date picker is initialized with the current date.
 */
@property (nonatomic, strong, nonnull, readwrite) NSDate *selectedDate;

/**
 The date picker section index for the previous week.
 */
@property (nonatomic, assign, class, readonly) NSInteger datePickerSectionPreviousWeek;

/**
 The date picker section index for the currently visible week.
 */
@property (nonatomic, assign, class, readonly) NSInteger datePickerSectionActiveWeek;

/**
 The date picker section index for the next week.
 */
@property (nonatomic, assign, class, readonly) NSInteger datePickerSectionNextWeek;

/**
 Sets up the data source's previous week, active week and next week dates given a reference date.
 The reference date will be in the active week's dates.

 @param date The reference date.
 */
- (void)setupWeekDatesWithCurrentlyVisibleDate:(nonnull NSDate *)date;

/**
 Requests a date's @c indexPath relative to previous, active, or next weeks' dates.

 @param date The reference date.
 @return An index path for the given date.
 */
- (nullable NSIndexPath *)indexPathForDate:(nonnull NSDate *)date;

/**
 Requests the date at the given @c indexPath.

 @param indexPath The @c NSIndexPath for which we want to find a corresponding date.
 @return A date for the given index path.
 */
- (nullable NSDate *)dateForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;

/**
 A new date picker data source with the specified @c config.

 @param config The configuration object for the parent @c TCNDatePickerView.
 @return A @c TCNDatePickerDataSource instance.
 */
- (nonnull instancetype)initWithConfig:(nonnull TCNDatePickerConfig *)config NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end
