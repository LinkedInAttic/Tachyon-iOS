#import "TCNDateFormatter.h"

@implementation TCNDateFormatter

+ (nonnull NSDateFormatter *)dayOfWeekFormatter {
    static NSDateFormatter *dayOfWeekFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dayOfWeekFormatter = [[NSDateFormatter alloc] init];
        [dayOfWeekFormatter setLocale:[NSLocale currentLocale]];
        dayOfWeekFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ccccc" options:0 locale:dayOfWeekFormatter.locale];
    });
    return dayOfWeekFormatter;
}

+ (nonnull NSDateFormatter *)dayOfMonthFormatter {
    static NSDateFormatter *dayOfMonthFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dayOfMonthFormatter = [[NSDateFormatter alloc] init];
        [dayOfMonthFormatter setLocale:[NSLocale currentLocale]];
        dayOfMonthFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"d" options:0 locale:dayOfMonthFormatter.locale];
    });
    return dayOfMonthFormatter;
}

+ (nonnull NSDateFormatter *)monthAndYearFormatter {
    static NSDateFormatter *monthAndYearFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        monthAndYearFormatter = [[NSDateFormatter alloc] init];
        [monthAndYearFormatter setLocale:[NSLocale currentLocale]];
        monthAndYearFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMM, yyyy" options:0 locale:monthAndYearFormatter.locale];
    });
    return monthAndYearFormatter;
}

+ (nonnull NSDateFormatter *)sidebarTimeFormatter {
    static NSDateFormatter *sidebarTimeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sidebarTimeFormatter = [[NSDateFormatter alloc] init];
        [sidebarTimeFormatter setLocale:[NSLocale currentLocale]];
        sidebarTimeFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"jj" options:0 locale:sidebarTimeFormatter.locale];
    });
    return sidebarTimeFormatter;
}

+ (nonnull NSDateFormatter *)timeFormatter {
    static NSDateFormatter *timeFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setLocale:[NSLocale currentLocale]];
        timeFormatter.timeStyle = NSDateFormatterShortStyle;
    });
    return timeFormatter;
}

#pragma mark - TESTING

+ (nonnull NSDateFormatter *)testing_monthDayYearFormatter {
    static NSDateFormatter *testing_monthDayYearFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        testing_monthDayYearFormatter = [[NSDateFormatter alloc] init];
        testing_monthDayYearFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"ccc MMM dd, yyyy"
                                                                           options:0
                                                                            locale:[NSLocale localeWithLocaleIdentifier:@"en_us"]];
    });
    return testing_monthDayYearFormatter;
}

@end
