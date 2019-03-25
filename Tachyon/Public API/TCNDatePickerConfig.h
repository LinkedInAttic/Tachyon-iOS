#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class TCNDatePickerConfig;

/**
 Classes implementing this protocol may adopt and use configuration parameters stored in @c TCNDatePickerConfig.
 */
@protocol TCNDatePickerConfigurable <NSObject>

/**
 Any UI styling of the adopting class using properties stored in @c TCNDatePickerConfig should be done here.

 @param config The configuration object
 @param selected If true, the object is selected and should reference the corresponding selected values on the config object.
 */
- (void)applyStylingFromConfig:(nonnull TCNDatePickerConfig *)config selected:(BOOL)selected;

@end

/**
 The configuration object for @c TCNDatePickerView. This allows consumers of this view to
 modify certain UI properties.
 */
@interface TCNDatePickerConfig : NSObject

/**
 The background color of a typical cell in the date picker.
 Defaults to white.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *backgroundColor;

/**
 The selected color of a cell when the cell is selected.
 Defaults to red.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *selectedColor;

/**
 The primary font, used for setting the date's label.
 Defaults to system font of size 16.
 */
@property (nonatomic, strong, nonnull, readwrite) UIFont *primaryFont;

/**
 The secondary font, used for setting the day of the week's label.
 Defaults to system font of size 12 with medium weight.
 */
@property (nonatomic, strong, nonnull, readwrite) UIFont *secondaryFont;

/**
 The font of the top month label.
 Defaults to system font size 16.
 */
@property (nonatomic, strong, nonnull, readwrite) UIFont *monthLabelFont;

/**
 The text color of a cell in a non-selected state.
 Defaults to black color.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *textColor;

/**
 The text color of a cell when the cell is selected.
 Defaults to white color.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *selectedTextColor;

/**
 The text color for a weekend day.
 Defaults to black.
 */
@property (nonatomic, strong, nonnull, readwrite) UIColor *weekendTextColor;

/**
 Optionally specified to provide a background view for the date picker collection view.
 */
@property (nonatomic, copy, nullable, readwrite) UIView *_Nonnull(^datePickerBackgroundProvider)(void);

/**
 Apply any custom styling to the date picker view here.

 This block runs when the config object is read during the @c TCNDatePicker initialization process.
 */
@property (nonatomic, copy, nullable, readwrite) void(^customDatePickerViewConfig)(UIView *_Nonnull);

/**
 @return An instance of @c TCNDatePickerConfig with the default configuration.
 */
- (nonnull instancetype)init NS_DESIGNATED_INITIALIZER;

@end
