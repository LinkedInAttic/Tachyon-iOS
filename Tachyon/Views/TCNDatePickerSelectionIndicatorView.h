#import <UIKit/UIKit.h>

#import "TCNReusableView.h"

/**
 A colored view indicating that a @c TCNDatePickerDayView is selected.
 */
@interface TCNDatePickerSelectionIndicatorView: UICollectionReusableView <TCNReusableView>

/**
 The reuse identifier for this collectionview view.
 */
@property (nonatomic, copy, nonnull, class, readonly) NSString *reuseIdentifier;

@end
