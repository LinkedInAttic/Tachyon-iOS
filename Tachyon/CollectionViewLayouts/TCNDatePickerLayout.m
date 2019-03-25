#import "TCNDatePickerLayout.h"
#import "TCNDecorationViewLayoutAttributes.h"
#import "TCNMacros.h"
#import "TCNDatePickerSelectionIndicatorView.h"

@interface TCNDatePickerLayout ()

@property (nonatomic, strong, nonnull, readonly) TCNDatePickerConfig *config;
@property (nonatomic, strong, nullable, readwrite) UICollectionViewLayoutAttributes *selectedItemAttributesCache;

@end

@implementation TCNDatePickerLayout

- (instancetype)initWithConfig:(nonnull TCNDatePickerConfig *)config {
    self = [super init];
    if (!self) {
        return nil;
    }

    _config = config;
    _selectedItemAttributesCache = nil;

    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    [self invalidateLayoutCache];

    [self prepareSelectedDayDecorationViewAttributes];
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<UICollectionViewLayoutAttributes *> *const baseLayoutAttributes = [super layoutAttributesForElementsInRect:rect];
    if (!baseLayoutAttributes) {
        return nil;
    }

    if (self.selectedItemAttributesCache && CGRectIntersectsRect(self.selectedItemAttributesCache.frame, rect)) {
        UICollectionViewLayoutAttributes *const decorationLayoutAttributes = self.selectedItemAttributesCache;
        return [baseLayoutAttributes arrayByAddingObject:decorationLayoutAttributes];
    }

    return baseLayoutAttributes;
}

- (void)prepareSelectedDayDecorationViewAttributes {
    NSIndexPath *const indexPath = [self.delegate selectedDateIndexPath];
    if (!indexPath) {
        return;
    }

    TCNDecorationViewLayoutAttributes *const decorationAttributes =
    [TCNDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:TCNDatePickerSelectionIndicatorView.reuseIdentifier
                                                                 withIndexPath:indexPath];
    decorationAttributes.frame = CGRectZero;
    UICollectionViewLayoutAttributes *const itemAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    if (itemAttributes) {
        decorationAttributes.frame = itemAttributes.frame;
    }
    // the selection decoration view should always appear under the cell, so the zIndex should be lower than corresponding cell's zIndex
    decorationAttributes.zIndex = itemAttributes.zIndex - 1;
    decorationAttributes.backgroundColor = self.config.selectedColor;

    self.selectedItemAttributesCache = decorationAttributes;
}

- (void)invalidateLayoutCache {
    self.selectedItemAttributesCache = nil;
}

@end
