#import "TCNDatePickerConfig.h"
#import "TCNMacros.h"

@implementation TCNDatePickerConfig

- (nonnull instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    // default implementation

    _backgroundColor = [UIColor whiteColor];
    _selectedColor = [UIColor redColor];
    _primaryFont = [UIFont systemFontOfSize:16.0f];
    _secondaryFont = [UIFont systemFontOfSize:12.0f weight:UIFontWeightMedium];
    _monthLabelFont = [UIFont systemFontOfSize:16.0f];
    _textColor = [UIColor blackColor];
    _selectedTextColor = [UIColor whiteColor];
    _weekendTextColor = [UIColor blackColor];
    _datePickerBackgroundProvider = nil;
    _customDatePickerViewConfig = nil;

    return self;
}

@end
