#import "TCNDateFormatter.h"

@interface TCNDateFormatter (Testing)

/**
 This is for TESTING ONLY, and does not return a localized date.
 Ex: Mon Jan 1, 2019
 */
@property (nonatomic, strong, nonnull, class, readonly) NSDateFormatter *testing_monthDayYearFormatter;

@end
