#import "TCNTestUtils.h"
#import "TCNDateUtil.h"

@implementation TCNTestUtils

+ (nonnull NSDateFormatter *)dateFormatter {
    static NSDateFormatter *_dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm";
    });
    return _dateFormatter;
}

+ (nonnull NSDate *)dateWithTime:(nonnull NSString *)timeString onDay:(nonnull NSDate *)day {
    return [self dateWithTime:timeString onDay:day daysToAdd:0];
}

+ (nonnull NSDate *)dateWithTime:(nonnull NSString *)timeString onDay:(nonnull NSDate *)day daysToAdd:(NSInteger)daysToAdd {
    NSDate *const time = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"2019-01-18 %@", timeString]];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *timeComponents = [calendar componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:time];
    NSDate *dayToUse = [TCNDateUtil dateByAddingDays:daysToAdd toDate:day];

    return [calendar dateBySettingHour:timeComponents.hour
                                minute:timeComponents.minute
                                second:timeComponents.second
                                ofDate:dayToUse
                               options:0];
}

@end
