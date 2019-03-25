#import "TCNDateUtil.h"
#import "TCNDateFormatter.h"
#import "TCNMacros.h"

@implementation TCNDateUtil

#pragma mark - Date manipulation

+ (nonnull NSDate *)dateWithDate:(nonnull NSDate *)date atHour:(NSInteger)hour {
    NSDate *const newDate = [[NSCalendar currentCalendar] dateBySettingHour:hour minute:0 second:0 ofDate:date options:0];
    if (!newDate) {
        return date;
    }
    return newDate;
}

+ (nonnull NSDate *)dateWithDate:(nonnull NSDate *)date atHour:(NSInteger)hour andMinute:(NSInteger)minute {
    NSDate *const newDate = [[NSCalendar currentCalendar] dateBySettingHour:hour
                                                                     minute:minute
                                                                     second:0
                                                                     ofDate:date
                                                                    options:0];
    if (!newDate) {
        return date;
    }
    return newDate;
}

+ (nonnull NSDate *)dateByAddingDays:(NSInteger)days toDate:(nonnull NSDate *)date {
    NSDateComponents *const dateComponent = [[NSDateComponents alloc] init];
    [dateComponent setDay:days];
    NSCalendar *const calendar = [NSCalendar currentCalendar];
    NSDate *const newDate = [calendar dateByAddingComponents:dateComponent toDate:date options:0];
    if (!newDate) {
        TCN_ASSERT_FAILURE(@"no new date found after adding days to the date");
        return date;
    }
    return newDate;
}

+ (nonnull NSDate *)dateByAddingWeeks:(NSInteger)weeks toDate:(nonnull NSDate *)date {
    NSCalendar *const calendar = [NSCalendar currentCalendar];
    NSDateComponents *const components = [[NSDateComponents alloc] init];
    components.weekOfYear = weeks;
    NSDate *const newDate = [calendar dateByAddingComponents:components toDate:date options:0];
    if (!newDate) {
        TCN_ASSERT_FAILURE(@"no new date found after adding days to the date");
        return date;
    }
    return newDate;
}

+ (nonnull NSDate *)middleOfWeekForDate:(nonnull NSDate *)date {
    NSDate* newDate = [[NSCalendar currentCalendar] dateBySettingUnit:NSCalendarUnitWeekday value:4 ofDate:date options:0];
    if (!newDate) {
        return [NSDate date];
    }
    return newDate;
}

+ (nonnull NSDate *)endOfDayForDate:(nonnull NSDate *)date {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    components.second = -1;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:components toDate:[calendar startOfDayForDate:date] options:0];
    if (!newDate) {
        return [NSDate date];
    }
    return newDate;
}

#pragma mark - Date comparison

+ (BOOL)isDate:(nonnull NSDate *)date inSameDayAsDate:(nonnull NSDate *)otherDate {
    return [[NSCalendar currentCalendar] isDate:date inSameDayAsDate:otherDate];
}

+ (BOOL)isDate:(nonnull NSDate *)date inSameWeekAsDate:(nonnull NSDate *)otherDate {
    return [[NSCalendar currentCalendar] isDate:date equalToDate:otherDate toUnitGranularity:NSCalendarUnitWeekOfYear];
}

+ (BOOL)date:(nonnull NSDate *)date isAfterDate:(nonnull NSDate *)otherDate {
    return [date compare:otherDate] == NSOrderedDescending;
}

+ (BOOL)date:(nonnull NSDate *)date isBeforeDate:(nonnull NSDate *)otherDate {
    return [date compare:otherDate] == NSOrderedAscending;
}

+ (nonnull NSDate *)latestDate:(nonnull NSDate *)date otherDate:(nonnull NSDate *)otherDate {
    return [TCNDateUtil date:date isAfterDate:otherDate] ? date : otherDate;
}

+ (nonnull NSDate *)earliestDate:(nonnull NSDate *)date otherDate:(nonnull NSDate *)otherDate {
    return [TCNDateUtil date:date isBeforeDate:otherDate] ? date : otherDate;
}

#pragma mark - Other

+ (NSInteger)indexOfDateInWeek:(nonnull NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger weekdayToAdd = (NSInteger)calendar.firstWeekday - 1;
    return [calendar component:NSCalendarUnitWeekday fromDate:date] - 1 - weekdayToAdd;
}

+ (nonnull NSArray<NSDate *> *)daysOfWeekFromDate:(nonnull NSDate *)date {
    NSCalendar *const calendar = [NSCalendar currentCalendar];
    [calendar setLocale:[NSLocale currentLocale]];
    NSDateComponents *const components = [calendar components:(NSCalendarUnitYear |
                                                               NSCalendarUnitMonth |
                                                               NSCalendarUnitWeekOfYear |
                                                               NSCalendarUnitWeekday |
                                                               NSCalendarUnitHour |
                                                               NSCalendarUnitMinute)
                                                     fromDate:date];
    NSMutableArray<NSDate *> *const daysOfWeekDates = [[NSMutableArray alloc] init];

    // We need to account for areas where firstWeekday == 2 (i.e. the week begins on Monday).
    NSUInteger weekdayToAdd = calendar.firstWeekday - 1;
    for (NSUInteger index = 1; index <= 7; index++) {
        [components setWeekday:(index + weekdayToAdd) % 7];
        NSDate *const dateFromComponent = [calendar dateFromComponents:components];
        if (dateFromComponent != nil) {
            [daysOfWeekDates addObject:dateFromComponent];
        }
    }
    return daysOfWeekDates;
}

@end
