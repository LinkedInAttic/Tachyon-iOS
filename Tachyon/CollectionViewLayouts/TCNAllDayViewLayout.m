#import "TCNAllDayViewLayout.h"
#import "TCNDayViewLayout+Protected.h"
#import "TCNNumberHelper.h"
#import "TCNDayViewTimeView.h"
#import "TCNDecorationViewLayoutAttributes.h"
#import "TCNDayViewGridlineView.h"
#import "TCNEventCell.h"

@implementation TCNAllDayViewLayout

static const CGFloat TimeViewWidth = 56.0f;
static const CGFloat AllDayViewMaximumHeight = 62.0f;
static const CGFloat AllDayViewCellHeight = 22.0f;
static const CGFloat AllDayViewVerticalPadding = 2.0f;
static const UIEdgeInsets AllDayViewCellMargin = {2.0f, 0.0f, 2.0f, 2.0f};

#pragma mark - Class helpers

+ (CGFloat)allDayViewHeightForEventCount:(NSInteger)eventCount {
    CGFloat contentHeight = [self requiredAllDayViewContentHeightForEventCount:eventCount];
    return MIN(contentHeight, AllDayViewMaximumHeight);
}

+ (CGFloat)requiredAllDayViewContentHeightForEventCount:(NSInteger)eventCount {
    return (2 * AllDayViewVerticalPadding) + [self heightForNumberOfAllDayEvents:eventCount];
}

+ (CGFloat)heightForNumberOfAllDayEvents:(NSInteger)eventCount {
    const NSInteger numberOfVerticalEvents = (NSInteger)[TCNNumberHelper ceil:((CGFloat)eventCount) / 2];
    return numberOfVerticalEvents * (AllDayViewCellHeight + AllDayViewCellMargin.top + AllDayViewCellMargin.bottom);
}

#pragma mark - UICollectionViewLayout

- (nonnull UICollectionViewLayoutAttributes *)prepareLayoutForDarkGridlineWithIndexPath:(nonnull NSIndexPath *)indexPath
                                                                      calendarGridWidth:(__unused CGFloat)calendarGridWidth
                                                                       calendarGridMinX:(__unused CGFloat)calendarGridMinX
                                                                       calendarGridMinY:(__unused CGFloat)calendarGridMinY {
    TCNDecorationViewLayoutAttributes *const horizontalGridlineAttributes =
    [TCNDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:TCNDayViewGridlineView.darkKind
                                                                 withIndexPath:indexPath];
    horizontalGridlineAttributes.frame = CGRectZero;
    return horizontalGridlineAttributes;
}

- (nonnull UICollectionViewLayoutAttributes *)prepareLayoutForLightGridlineWithIndexPath:(nonnull NSIndexPath *__unused)indexPath
                                                                       calendarGridWidth:(__unused CGFloat)calendarGridWidth
                                                                        calendarGridMinX:(__unused CGFloat)calendarGridMinX
                                                                        calendarGridMinY:(__unused CGFloat)calendarGridMinY {
    TCNDecorationViewLayoutAttributes *const horizontalLightGridlineAttributes =
    [TCNDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:TCNDayViewGridlineView.lightKind
                                                                 withIndexPath:indexPath];
    horizontalLightGridlineAttributes.frame = CGRectZero;
    return horizontalLightGridlineAttributes;
}

- (nullable UICollectionViewLayoutAttributes *)prepareLayoutForTimeViewWithIndexPath:(nonnull NSIndexPath *)indexPath
                                                                         sectionMinX:(CGFloat)sectionMinX
                                                                    calendarGridMinY:(__unused CGFloat)calendarGridMinY {
    UICollectionViewLayoutAttributes *const timeViewAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:TCNDayViewTimeView.reuseIdentifier
                                                                   withIndexPath:indexPath];
    if (indexPath.row == 0) {
        timeViewAttributes.frame = CGRectMake(sectionMinX, AllDayViewVerticalPadding + AllDayViewCellMargin.top, TimeViewWidth, AllDayViewCellHeight);
        return timeViewAttributes;
    } else {
        return timeViewAttributes;
    }
}

- (nonnull UICollectionViewLayoutAttributes *)prepareLayoutForEventItemsAtIndexPath:(nonnull NSIndexPath *)indexPath
                                                                   calendarGridMinX:(CGFloat)calendarGridMinX
                                                                   calendarGridMinY:(__unused CGFloat)calendarGridMinY
                                                                   calendarGridMaxX:(CGFloat)calendarGridMaxX  {
    UICollectionViewLayoutAttributes *const itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    const CGFloat heightOfPreviousRow = [TCNAllDayViewLayout heightForNumberOfAllDayEvents:MAX(0, indexPath.row - 1)];
    const CGFloat itemMinY = AllDayViewVerticalPadding + heightOfPreviousRow + AllDayViewCellMargin.top;
    const CGFloat itemMinX = calendarGridMinX + AllDayViewCellMargin.left;
    const CGFloat itemWidth = calendarGridMaxX - calendarGridMinX - AllDayViewCellMargin.left - AllDayViewCellMargin.right;
    itemAttributes.frame = CGRectMake(itemMinX, itemMinY, itemWidth, AllDayViewCellHeight);
    itemAttributes.zIndex = [self zIndexForElementKind:TCNEventCell.reuseIdentifier];

    return itemAttributes;
}

- (CGSize)collectionViewContentSize {
    const NSInteger eventCount = [self.collectionView numberOfItemsInSection:0];
    const CGFloat height = [TCNAllDayViewLayout requiredAllDayViewContentHeightForEventCount:eventCount];
    return CGSizeMake(self.collectionView.frame.size.width, height);
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > 0) {
        return nil;
    }
    return [super layoutAttributesForSupplementaryViewOfKind:elementKind atIndexPath:indexPath];
}

@end
