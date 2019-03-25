#import "TCNDatePickerSelectionIndicatorView.h"
#import "TCNDecorationViewLayoutAttributes.h"
#import "TCNMacros.h"

@interface TCNDatePickerSelectionIndicatorView ()

@property (nonatomic, strong, nonnull) CAShapeLayer *roundedCornerMask;

@end

@implementation TCNDatePickerSelectionIndicatorView

static const int CornerRadius = 2;

+ (nonnull NSString *)reuseIdentifier {
    return NSStringFromClass([TCNDatePickerSelectionIndicatorView class]);
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    _roundedCornerMask = [CAShapeLayer layer];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIBezierPath *const path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:CornerRadius];
    self.roundedCornerMask.path = path.CGPath;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];

    self.layer.mask = self.roundedCornerMask;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];

    TCNDecorationViewLayoutAttributes *const attributes = TCN_CAST_OR_NIL(layoutAttributes, TCNDecorationViewLayoutAttributes);
    if (!attributes) {
        return;
    }
    self.backgroundColor = attributes.backgroundColor;
}

@end
