#import "TCNDayViewGridlineView.h"
#import "TCNDecorationViewLayoutAttributes.h"
#import "TCNMacros.h"

@implementation TCNDayViewGridlineView

+ (nonnull NSString *)reuseIdentifier {
    return NSStringFromClass([TCNDayViewGridlineView class]);
}

+ (nonnull NSString *)darkKind {
    return @"TCNDayViewGridlineViewDarkKind";
}

+ (nonnull NSString *)lightKind {
    return @"TCNDayViewGridlineViewLightKind";
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
