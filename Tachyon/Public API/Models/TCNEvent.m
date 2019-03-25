#import "TCNEvent.h"
#import "TCNDateFormatter.h"
#import "TCNDateUtil.h"
#import "TCNMacros.h"

@implementation TCNEvent

#pragma mark - Initialization

- (nullable instancetype)initWithName:(nonnull NSString *)name
                        startDateTime:(nonnull NSDate *)startDateTime
                          endDateTime:(nonnull NSDate *)endDateTime
                             location:(nullable NSString *)location
                             timezone:(nullable NSTimeZone *)timezone
                             isAllDay:(BOOL)isAllDay {
    self = [super init];
    if (!self) {
        return self;
    }
    if ([startDateTime compare:endDateTime] == NSOrderedDescending) {
        return nil;
    }
    _name = name;
    _startDateTime = startDateTime;
    _endDateTime = endDateTime;
    _location = location;
    _timezone = timezone ?: [NSTimeZone localTimeZone];
    _isAllDay = isAllDay;
    return self;
}

- (nonnull instancetype)initWithName:(nonnull NSString *)name
                       startDateTime:(nonnull NSDate *)startDateTime {
    self = [super init];
    if (!self) {
        return self;
    }
    _name = name;
    _startDateTime = startDateTime;
    _endDateTime = [startDateTime dateByAddingTimeInterval:3600];
    _timezone = [NSTimeZone localTimeZone];
    _isAllDay = false;
    return self;
}

#pragma mark - Methods

- (nonnull NSString *)displayTimeString {
    NSDateFormatter *const formatter = TCNDateFormatter.timeFormatter;
    return [NSString stringWithFormat:@"%@ - %@",
            [formatter stringFromDate:self.startDateTime],
            [formatter stringFromDate:self.endDateTime]];
}

- (BOOL)occursOnDay:(nonnull NSDate *)date {
    return [TCNDateUtil isDate:date inSameDayAsDate:self.startDateTime]
    || [TCNDateUtil isDate:date inSameDayAsDate:self.endDateTime]
    || ([TCNDateUtil date:date isAfterDate:self.startDateTime] && [TCNDateUtil date:date isBeforeDate:self.endDateTime]);
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"TCNEvent {\nname: %@\nstartTime: %@\nendTime: %@\nisAllDay: %d\nisSelected: %d\n}",
            self.name,
            self.startDateTime,
            self.endDateTime,
            self.isAllDay,
            self.isSelected];
}

#pragma mark - Static Methods

+ (nonnull NSArray<TCNEvent *> *)mergedEventsForEvents:(nonnull NSArray<TCNEvent *> *)events {
    NSMutableArray<TCNEvent *> *const mergedEvents = [[NSMutableArray alloc] init];
    NSArray<TCNEvent *> *const sortedEvents = [events sortedArrayUsingComparator:^NSComparisonResult(TCNEvent *_Nonnull obj1, TCNEvent *_Nonnull obj2) {
        return [obj1.startDateTime compare:obj2.startDateTime];
    }];

    NSUInteger eventIndex = 0;
    while (eventIndex < sortedEvents.count) {
        TCNEvent *const event = sortedEvents[eventIndex];
        if (event.isAllDay) {
            [mergedEvents addObject:event];
            eventIndex += 1;
            continue;
        }
        NSDate *newEndDateTime = event.endDateTime;

        while (eventIndex < sortedEvents.count - 1) {
            NSDate *const nextStartTime = sortedEvents[eventIndex + 1].startDateTime;
            NSDate *const nextEndTime = sortedEvents[eventIndex + 1].endDateTime;
            if (![TCNDateUtil date:nextStartTime isAfterDate:newEndDateTime]) {
                newEndDateTime = [TCNDateUtil latestDate:newEndDateTime otherDate:nextEndTime];
                eventIndex += 1;
            } else {
                break;
            }
        }

        TCNEvent *const newEvent = [[TCNEvent alloc] initWithName:event.name
                                                                  startDateTime:event.startDateTime
                                                                    endDateTime:newEndDateTime
                                                                       location:event.location
                                                                       timezone:event.timezone
                                                                       isAllDay:event.isAllDay];
        if (!newEvent) {
            TCN_ASSERT_FAILURE(@"Failed to construct merged calendar event.");
            eventIndex += 1;
            continue;
        }

        [mergedEvents addObject:newEvent];
        eventIndex += 1;
    }

    return mergedEvents;
}

@end
