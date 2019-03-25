#import <XCTest/XCTest.h>

#import "TCNDateUtil.h"
#import "TCNDateFormatter+Testing.h"

@interface TCNDateUtilTests : XCTestCase

@end

/**
 This file must be run in en_US locale.
 */
@implementation TCNDateUtilTests

/**
 If this fails, we are not in en_US locale.
 */
- (void)testLocale {
    XCTAssert([[NSLocale currentLocale].localeIdentifier isEqualToString:@"en_US"]);
}

- (void)testDateByAddingDays {
    NSDate *const today = [self dateFromString:@"Fri Jan 25, 2019"];
    NSDate *fiveDaysFromToday = [TCNDateUtil dateByAddingDays:5 toDate:today];

    XCTAssertTrue([[self stringFromDate:fiveDaysFromToday] isEqualToString:@"Wed, Jan 30, 2019"]);
}

- (void)testIndexOfDateInWeek {
    NSDate *const today = [self dateFromString:@"Fri Jan 25, 2019"];
    NSInteger todayIndex = [TCNDateUtil indexOfDateInWeek:today];
    XCTAssertEqual(todayIndex, 5);

    NSDate *const tomorrow = [self dateFromString:@"Sat Jan 26, 2019"];
    NSInteger tomorrowIndex = [TCNDateUtil indexOfDateInWeek:tomorrow];
    XCTAssertEqual(tomorrowIndex, 6);

    NSDate *const dayAfterTomorrow = [self dateFromString:@"Sat Jan 27, 2019"];
    NSInteger dayAfterTomorrowIndex = [TCNDateUtil indexOfDateInWeek:dayAfterTomorrow];
    XCTAssertEqual(dayAfterTomorrowIndex, 0);
}

- (void)testDaysOfWeekFromDate {
    NSDate *const today = [self dateFromString:@"Fri Jan 25, 2019"];
    NSArray<NSDate *> *const daysOfWeek = [TCNDateUtil daysOfWeekFromDate:today];

    NSArray<NSString *> *const expectedDaysOfWeek = @[
                                                      @"Sun, Jan 20, 2019",
                                                      @"Mon, Jan 21, 2019",
                                                      @"Tue, Jan 22, 2019",
                                                      @"Wed, Jan 23, 2019",
                                                      @"Thu, Jan 24, 2019",
                                                      @"Fri, Jan 25, 2019",
                                                      @"Sat, Jan 26, 2019",
                                                      ];

    [daysOfWeek enumerateObjectsUsingBlock:^(NSDate * _Nonnull date, NSUInteger idx, __unused BOOL * _Nonnull stop) {
        NSString *dateString = [self stringFromDate:date];
        XCTAssertTrue([dateString isEqualToString:expectedDaysOfWeek[idx]]);
    }];
}

# pragma mark - Helpers

- (nullable NSDate *)dateFromString:(nonnull NSString *)string {
    NSDateFormatter *const formatter = TCNDateFormatter.testing_monthDayYearFormatter;
    return [formatter dateFromString:string];
}

- (nullable NSString *)stringFromDate:(nonnull NSDate *)date {
    NSDateFormatter *const formatter = TCNDateFormatter.testing_monthDayYearFormatter;
    return [formatter stringFromDate:date];
}

@end
