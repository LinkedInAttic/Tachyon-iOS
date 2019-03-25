#import <UIKit/UIKit.h>

#import "TCNDatePickerConfig.h"
#import "TCNReusableView.h"

/**
 Represents a single day on a @c TCNDatePickerView instance.
 */
@interface TCNDatePickerDayView : UICollectionViewCell <TCNDatePickerConfigurable, TCNReusableView>

/**
 The date which this object represents.

 Setting this property automatically updates the collectionView's labels appropriately.
 */
@property (nonatomic, strong, nonnull, readwrite) NSDate *date;

@end
