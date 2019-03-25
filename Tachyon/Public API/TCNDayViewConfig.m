#import <UIKit/UIKit.h>
#import "TCNDayViewConfig.h"

@implementation TCNDayViewConfig

static NSString *const DefaultNewEventText = @"Available";
static NSString *const DefaultAllDayEventText = @"All Day";

- (nonnull instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _createdEventText = DefaultNewEventText;
    _allDayLabelText = DefaultAllDayEventText;
    _defaultEventLength = TCNEventLengthHalfHour;
    _backgroundColor = [UIColor whiteColor];

    _eventFont = [UIFont systemFontOfSize:12.0f];
    _eventTextColor = [UIColor blackColor];
    _eventColor = [UIColor colorWithRed:225.0f / 255.0f
                                  green:223.0f / 255.0f
                                   blue:238.0f / 255.0f
                                  alpha:1.0f];

    _timeslotFont = [UIFont systemFontOfSize:12.0f];
    _timeslotTextColor = [UIColor blueColor];
    _timeslotColor = [UIColor greenColor];

    _sidebarFont = [UIFont systemFontOfSize:12.0f];
    _sidebarTextColor = [UIColor blackColor];
    _sidebarColor = [UIColor whiteColor];

    _gridlineDarkColor = [UIColor darkGrayColor];
    _gridlineLightColor = [UIColor lightGrayColor];

    _shouldShowCancelButtonOnCreatedEvents = YES;

    _dayViewBackgroundProvider = nil;
    _allDayViewBackgroundProvider = nil;
    _customDayViewConfig = nil;
    _customDayViewConfig = nil;
    _cancelButtonImage = nil;

    return self;
}

@end
