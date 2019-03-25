#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TCNReusableView.h"

@class TCNDayViewConfig;

/**
 Classes implementing this protocol may adopt and use configuration parameters stored in @c TCNDayViewConfig.
 */
@protocol TCNDayViewConfigurable <NSObject, TCNReusableView>

/**
 Any UI styling of the adopting class using properties stored in @c TCNDayViewConfig should be done here.

 @param config The configuration object
 @param selected If true, the object is selected and should reference the corresponding selected values on the config object.
 */
- (void)applyStylingFromConfig:(nonnull TCNDayViewConfig *)config selected:(BOOL)selected;

@end

/**
 An integer enum representing the supported event lengths.
 */
typedef NS_ENUM(NSInteger, TCNEventLength) {

    TCNEventLengthHalfHour = 30,
    TCNEventLengthHour = 60

};

/**
 The configuration object for @c TCNDayView. This allows consumers of this view to
 modify certain UI properties.
 */
@interface TCNDayViewConfig : NSObject

/**
 The displayed text for any new events created on the day view.
 Defaults to "Available".
 */
@property (nonatomic, copy, nonnull, readwrite) NSString *createdEventText;

/**
 The text for the all day event label.
 Defaults to "All Day".
 */
@property (nonatomic, copy, nonnull, readwrite) NSString *allDayLabelText;

/**
 The length of a newly created event, in minutes.
 Defaults to 30.
 */
@property (nonatomic, assign, readwrite) TCNEventLength defaultEventLength;

/**
 The background color of the collection view.
 Defaults to white.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *backgroundColor;

/**
 The font of an event cell.
 Defaults to system font of size 12.
 */
@property (nonatomic, strong, nonnull, readwrite) UIFont *eventFont;

/**
 The text color of an event cell.
 Defaults to black.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *eventTextColor;

/**
 The background color of an event cell.
 Defaults to light gray.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *eventColor;

/**
 The text color of a selected event cell.
 Defaults to white.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *selectedEventTextColor;

/**
 The background color of a selected event cell.
 Defaults to light gray.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *selectedEventColor;

/**
 The font of a timeslot cell.
 Defaults to system font of size 12.
 */
@property (nonatomic, strong, nonnull, readwrite) UIFont *timeslotFont;

/**
 The text color of an timeslot cell.
 Defaults to blue.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *timeslotTextColor;

/**
 The background color of a timeslot cell.
 Defaults to green.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *timeslotColor;

/**
 The font of a sidebar cell.
 Defaults to system font of size 12.
 */
@property (nonatomic, strong, nonnull, readwrite) UIFont *sidebarFont;

/**
 The text color of a sidebar.
 Defaults to black.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *sidebarTextColor;

/**
 The background color of sidebar.
 Defaults to white.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *sidebarColor;

/**
 The background color of an hour mark gridline view.
 Defaults to dark gray.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *gridlineDarkColor;

/**
 The background color of a 30 mins mark gridline view.
 Defaults to light gray.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *gridlineLightColor;

/**
 @c YES if a cancel button should be shown on created event cells.
 Default @c YES.
 */
@property (nonatomic, assign, readwrite) BOOL shouldShowCancelButtonOnCreatedEvents;

/**
 The image to be shown for event cells' cancel button.
 Optional.
 */
@property (nonatomic, strong, nullable, readwrite) UIImage *cancelButtonImage;

/**
 Provides a background view for the day collection view.
 Optional.
 */
@property (nonatomic, copy, nullable, readwrite) UIView *_Nonnull(^dayViewBackgroundProvider)(void);

/**
 Provides a background view for the all day collection view.
 Optional.
 */
@property (nonatomic, copy, nullable, readwrite) UIView *_Nonnull(^allDayViewBackgroundProvider)(void);

/**
 Applies custom styling to the day event view.
 Optional.

 This block runs when the config object is read during the @c TCNDayView initialization process.
 */
@property (nonatomic, copy, nullable, readwrite) void(^customDayViewConfig)(UIView *_Nonnull);

/**
 Applies custom styling to the all-day event view.
 Optional.

 This block runs when the config object is read during the @c TCNDayView initialization process.
 */
@property (nonatomic, copy, nullable, readwrite) void(^customAllDayViewConfig)(UIView *_Nonnull);

- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

@end
