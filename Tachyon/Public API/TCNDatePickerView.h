#import <UIKit/UIKit.h>
#import "TCNDatePickerConfig.h"

@class TCNDatePickerView;

/**
 Classes may implement this protocol to receive updates from a @c TCNDatePickerView instance when a date is selected.
 */
@protocol TCNDatePickerDelegate <NSObject>

/**
 Called when a date is selected.
 */
- (void)datePickerView:(nonnull TCNDatePickerView *)datePickerView didSelectDate:(nonnull NSDate *)date;

@end

/**
 A paging view that displays the month and date, and allows users to select a date.
 */
@interface TCNDatePickerView : UIView

/**
 Delegate object for the date picker.
 */
@property (nonatomic, weak, nullable, readwrite) id<TCNDatePickerDelegate> datePickerDelegate;

/**
 Returns the currently selected date.
 */
@property (nonatomic, strong, nonnull, readonly) NSDate *selectedDate;

/**
 True if the device is using RTL layout.
 */
@property (nonatomic, assign, class, readonly) BOOL isRightToLeftLayout;

/**
 Requests the height required by the date picker given @c config. The date picker should have its height
 set to this value to ensure correct layout.

 @param config A config object for which to calculate a height.
 @return A floating point height value for the picker.
 */
+ (CGFloat)heightRequiredForConfig:(nonnull TCNDatePickerConfig *)config;

/**
 Creates an instance of the date picker using the given config.

 @param frame The initial frame of the view.
 @param config The configuration object for the view.
 @return A @c TCNDatePickerView instance.
 */
- (nonnull instancetype)initWithFrame:(CGRect)frame config:(nonnull TCNDatePickerConfig *)config NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 Sets a new date to be selected by passing in an @c NSDate object. This should be called after the date picker object has been added as a subview.

 @param date The date to select.
 @param animated If YES, the picker will animate to its new selection.
 */
- (void)selectDate:(nonnull NSDate *)date animated:(BOOL)animated;

@end
