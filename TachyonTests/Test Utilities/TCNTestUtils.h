#import <Foundation/Foundation.h>

@interface TCNTestUtils : NSObject

/**
 @param timeString An hour and minute of the form HH:mm, in 24-hour time.
 @param day The base @c NSDate on which you wish to set the time.
 */
+ (nonnull NSDate *)dateWithTime:(nonnull NSString *)timeString onDay:(nonnull NSDate *)day;

/**
 @param timeString An hour and minute of the form HH:mm, in 24-hour time.
 @param day The base @c NSDate on which you wish to set the time.
 @param daysToAdd An integer adjustment representing the number of days you wish to add to @c day.
 */
+ (nonnull NSDate *)dateWithTime:(nonnull NSString *)timeString onDay:(nonnull NSDate *)day daysToAdd:(NSInteger)daysToAdd;

@end
