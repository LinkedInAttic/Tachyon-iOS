#import <Foundation/Foundation.h>

/**
 Contains helper functions for date manipulation.

 Many NSCalendar operations return optional values. In practice, these methods almost never return nil even when passed
 a seemingly invalid argument, e.g.:

 @code
 var components = DateComponents()
 components.year = -1
 components.month = 13
 Calendar.date(from: components)

 -> Date? = -001-12-30 07:52:58 UTC
 @endcode

 Therefore, some of the helper methods here that wrap these NSCalendar methods return
 non-optional values by simply coalescing to the given date.
 */
@interface TCNDateUtil : NSObject

#pragma mark - Date manipulation

/**
 Requests the provided hour, local time, for the provided date.

 @param date The reference date.
 @param hour The hour to set on the reference date.
 @return An @c NSDate set to the given hour on the reference date.
 */
+ (nonnull NSDate *)dateWithDate:(nonnull NSDate *)date atHour:(NSInteger)hour;

/**
 Requests the provided hour & minute, local time, for the provided date.

 @param date The reference date.
 @param hour The hour to set on the reference date.
 @param minute The minute to set on the reference date.
 @return An @c NSDate set to the given hour and minute on the reference date.
 */
+ (nonnull NSDate *)dateWithDate:(nonnull NSDate *)date atHour:(NSInteger)hour andMinute:(NSInteger)minute;

/**
 Requests the reference date, adding the number of days provided.

 @param days The number of days to add to the reference date.
 @param date The reference date.
 @return An @c NSDate at the time of the reference date, plus the given number of days.
 */
+ (nonnull NSDate *)dateByAddingDays:(NSInteger)days toDate:(nonnull NSDate *)date;

/**
 Requests the reference date, adding the number of weeks provided.

 @param weeks The number of weeks to add to the reference date.
 @param date The reference date.
 @return An @c NSDate at the time of the reference date, plus the given number of weeks.
 */
+ (nonnull NSDate *)dateByAddingWeeks:(NSInteger)weeks toDate:(nonnull NSDate *)date;

/**
 Requests the middle day of the week for the date provided. The middle day is the 4th day of that week.
 In most locales, this translates to Wednesday since the week starts on Sunday.

 @param date The reference date.
 @return An @c NSDate set to the middle day of the week of the reference date.
 */
+ (nonnull NSDate *)middleOfWeekForDate:(nonnull NSDate *)date;

/**
 Requests the end of the day for the date provided. The end of the day is defined as the last second of that day,
 or the second before midnight.

 @param date The reference date.
 @return The end of the day (e.g. 11:59 p.m.) on the reference date.
 */
+ (nonnull NSDate *)endOfDayForDate:(nonnull NSDate *)date;

#pragma mark - Date comparison

/**
 @param date The first date to compare.
 @param otherDate The second date to compare.
 @return YES if the two dates are in the same day in the local timezone.
 */
+ (BOOL)isDate:(nonnull NSDate *)date inSameDayAsDate:(nonnull NSDate *)otherDate;

/**
 @param date The first date to compare.
 @param otherDate The second date to compare.
 @return YES if the two dates fall in to the same week in the local timezone.
 */
+ (BOOL)isDate:(nonnull NSDate *)date inSameWeekAsDate:(nonnull NSDate *)otherDate;

/**
 @param date The first date to compare.
 @param otherDate The second date to compare.
 @return YES if the first date is after the second.
 */
+ (BOOL)date:(nonnull NSDate *)date isAfterDate:(nonnull NSDate *)otherDate;

/**
 @param date The first date to compare.
 @param otherDate The second date to compare.
 @return YES if the first date is before the second.
 */
+ (BOOL)date:(nonnull NSDate *)date isBeforeDate:(nonnull NSDate *)otherDate;

/**
 @param date The first date to compare.
 @param otherDate The second date to compare.
 @return The later of the two dates.
 */
+ (nonnull NSDate *)latestDate:(nonnull NSDate *)date otherDate:(nonnull NSDate *)otherDate;

/**
 @param date The first date to compare.
 @param otherDate The second date to compare.
 @return The earlier of the two dates.
 */
+ (nonnull NSDate *)earliestDate:(nonnull NSDate *)date otherDate:(nonnull NSDate *)otherDate;

#pragma mark - Other

/**
 Requests an integer representing the index of the day for the week from 0 to 6, where the first day of the week
 in the current locale corresponds to 0 and the last to 6.

 @param date The reference date.
 @return The index of the day in its week.
 */
+ (NSInteger)indexOfDateInWeek:(nonnull NSDate *)date;

/**
 @example
 For a reference date of Friday Jan 25th, 2019, the days of the week are Sun, Jan 20th 2019 - Sat, Jan 26th 2019
 in a locale where Sunday is the first day of the week.

 @param date The reference date.
 @return All the days in the week for the reference date.
 */
+ (nonnull NSArray<NSDate *> *)daysOfWeekFromDate:(nonnull NSDate *)date;

@end
