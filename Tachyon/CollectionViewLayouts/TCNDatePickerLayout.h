#import <UIKit/UIKit.h>
#import "TCNDatePickerConfig.h"

#pragma mark - TCNDatePickerLayoutDelegate

/**
 Classes implementing this protocol are responsible for providing information about the currently selected date to @c TCNDatePickerLayout.
 */
@protocol TCNDatePickerLayoutDelegate <UICollectionViewDelegate>

/**
 The index path of the currently selected date, if any.
 */
@property (nonatomic, strong, nullable, readonly) NSIndexPath *selectedDateIndexPath;

@end

#pragma mark - TCNDatePickerLayout

/**
 The default implementation for collection view layout in @c TCNDatePickerView.

 This class also provides caching for layout attributes.
 */
@interface TCNDatePickerLayout : UICollectionViewFlowLayout

/**
 The delegate for this @c TCNDatePickerLayout.
 */
@property (nonatomic, weak, nullable, readwrite) id<TCNDatePickerLayoutDelegate> delegate;

/**
 A new date picker layout with the specified @c TCNDatePickerConfig.

 @param config A configuration object.
 @return A @c TCNDatePickerLayout instance.
 */
- (nonnull instancetype)initWithConfig:(nonnull TCNDatePickerConfig *)config NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder NS_UNAVAILABLE;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end
