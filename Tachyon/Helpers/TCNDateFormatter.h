#import <Foundation/Foundation.h>

/**
 Provides convenience @c NSDateFormatter instances.
 */
@interface TCNDateFormatter : NSObject

/**
 Ex: M/T/W
 */
@property (nonatomic, strong, nonnull, class, readonly) NSDateFormatter *dayOfWeekFormatter;

/**
 Ex: 1
 */
@property (nonatomic, strong, nonnull, class, readonly) NSDateFormatter *dayOfMonthFormatter;

/**
 Ex: January, 2019
 */
@property (nonatomic, strong, nonnull, class, readonly) NSDateFormatter *monthAndYearFormatter;

/**
 Ex: 1 PM
 */
@property (nonatomic, strong, nonnull, class, readonly) NSDateFormatter *sidebarTimeFormatter;

/**
 Ex: 1:00 PM
 */
@property (nonatomic, strong, nonnull, class, readonly) NSDateFormatter *timeFormatter;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end
