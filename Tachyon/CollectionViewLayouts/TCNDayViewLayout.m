#import "TCNDateUtil.h"
#import "TCNDayViewLayout.h"
#import "TCNDayViewGridlineView.h"
#import "TCNDayViewTimeView.h"
#import "TCNEventCell.h"
#import "TCNDecorationViewLayoutAttributes.h"
#import "TCNNumberHelper.h"

typedef NS_ENUM(NSInteger, TCNDayViewLayoutZIndex) {

    TCNDayViewLayoutZIndexGridline = -1,
    TCNDayViewLayoutZIndexEventItem,
    TCNDayViewLayoutZIndexTimeView

};

@interface TCNDayViewLayout ()

/**
 Attributes cache for different views in the collectionView
 */
@property (nonatomic, strong, nonnull, readwrite) NSArray<UICollectionViewLayoutAttributes *> *allAttributes;
@property (nonatomic, strong, nonnull, readwrite) NSDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *eventCellAttributes;
@property (nonatomic, strong, nonnull, readwrite) NSDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *timeViewAttributes;
@property (nonatomic, strong, nonnull, readwrite) NSDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *darkGridlineAttributes;
@property (nonatomic, strong, nonnull, readwrite) NSDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *lightGridlineAttributes;
@property (nonatomic, strong, nonnull, readonly) TCNDayViewConfig *config;

@end

@implementation TCNDayViewLayout

static const CGFloat HourHeight = 88.0f;
static const CGFloat TimeViewWidth = 56.0f;
static const CGFloat HorizontalGridlineHeight = 1.0f;
static const NSInteger HoursInDay = 24;
static const UIEdgeInsets ContentMargin = {20.0f, 0.0f, 20.0f, 0.0f};
static const CGFloat SectionHeight = HourHeight * HoursInDay;
static const UIEdgeInsets CellMargin = {2.0f, 0.0f, 2.0f, 2.0f};
static const CGFloat EventRightInset = 2.0f;
static const CGFloat MinuteHeight = HourHeight / 60.0f;

#pragma mark - Initialization

- (nonnull instancetype)initWithConfig:(nonnull TCNDayViewConfig *)config {
    self = [super init];
    if (!self) {
        return nil;
    }

    _config = config;
    _allAttributes = [[NSArray alloc] init];
    _eventCellAttributes = [[NSDictionary alloc] init];
    _timeViewAttributes = [[NSDictionary alloc] init];
    _darkGridlineAttributes = [[NSDictionary alloc] init];
    _lightGridlineAttributes = [[NSDictionary alloc] init];

    return self;
}

#pragma mark - Class helpers

+ (CGFloat)topInsetMargin {
    return ContentMargin.top;
}

+ (CGFloat)offsetForIndexPath:(nonnull NSIndexPath *)indexPath minY:(CGFloat)minY {
    return minY + (HourHeight * indexPath.row) - ceilf(HorizontalGridlineHeight / 2.0);
}

+ (nonnull NSDate *)timeForYOffset:(CGFloat)offset {
    const NSInteger hour = (NSInteger)[TCNNumberHelper floor:(offset - ContentMargin.top) / HourHeight];
    const NSInteger minute = (NSInteger)[TCNNumberHelper floor:[TCNNumberHelper mod:(offset - ContentMargin.top) by:HourHeight] / MinuteHeight];
    return [TCNDateUtil dateWithDate:[NSDate date] atHour:hour andMinute:minute];
}

#pragma mark - UICollectionViewLayout

- (void)prepareLayout {
    [super prepareLayout];

    [self invalidateLayoutCache];
    [self prepareSectionLayoutForSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (NSUInteger)self.collectionView.numberOfSections)]];

    NSMutableArray *const allAttributes = [[NSMutableArray alloc] init];
    [allAttributes addObjectsFromArray:[self.timeViewAttributes allValues]];
    [allAttributes addObjectsFromArray:[self.darkGridlineAttributes allValues]];
    [allAttributes addObjectsFromArray:[self.lightGridlineAttributes allValues]];
    [allAttributes addObjectsFromArray:[self.eventCellAttributes allValues]];
    self.allAttributes = allAttributes;
}

- (void)prepareSectionLayoutForSections:(nonnull NSIndexSet *)sectionIndexes {
    if (self.collectionView.numberOfSections == 0) {
        return;
    }

    NSMutableDictionary *const timeViewAttributesCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *const darkGridlineViewAttributesCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *const lightGridlineViewAttributesCache = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *const eventCellAttributeCache = [[NSMutableDictionary alloc] init];

    [sectionIndexes enumerateIndexesUsingBlock:^(NSUInteger index, __unused BOOL *stop) {
        const NSInteger section = (NSInteger)index;

        const CGFloat calendarGridMinY = ContentMargin.top;
        const CGFloat eventMaxX = [self sectionWidth] - EventRightInset;
        const CGFloat sectionMinX =  [self stackedSectionWidthUpToSection:section];
        const CGFloat calendarGridMinX = sectionMinX + TimeViewWidth + ContentMargin.left;
        const CGFloat calendarGridWidth = [self sectionWidth] - TimeViewWidth - ContentMargin.right - ContentMargin.left;

        for (NSInteger hour = 0; hour <= HoursInDay; hour++) {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForItem:hour inSection:section];
            UICollectionViewLayoutAttributes *const timeViewAttributes = [self prepareLayoutForTimeViewWithIndexPath:indexPath
                                                                                                         sectionMinX:sectionMinX
                                                                                                    calendarGridMinY:calendarGridMinY];
            if (timeViewAttributes) {
                timeViewAttributesCache[indexPath] = timeViewAttributes;
            }

            darkGridlineViewAttributesCache[indexPath] = [self prepareLayoutForDarkGridlineWithIndexPath:indexPath
                                                                                       calendarGridWidth:calendarGridWidth
                                                                                        calendarGridMinX:calendarGridMinX
                                                                                        calendarGridMinY:calendarGridMinY];

            if (hour == HoursInDay) {
                // we don't need to show the lighter gridline on the last hour
                break;
            }
            lightGridlineViewAttributesCache[indexPath] = [self prepareLayoutForLightGridlineWithIndexPath:indexPath
                                                                                         calendarGridWidth:calendarGridWidth
                                                                                          calendarGridMinX:calendarGridMinX
                                                                                          calendarGridMinY:calendarGridMinY];
        }

        const NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];

        // We add items into another set if they need overlap adjustment. This allows us to
        // enforce a stable layout ordering on these items during overlap adjustment, whether or not any
        // non-adjusting items are added to the day view.
        NSMutableArray *const itemsToAdjust = [[NSMutableArray alloc] init];
        for (NSInteger item = 0; item < numberOfItemsInSection; item++) {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *const attributes = [self prepareLayoutForEventItemsAtIndexPath:indexPath
                                                                                            calendarGridMinX:calendarGridMinX
                                                                                            calendarGridMinY:calendarGridMinY
                                                                                            calendarGridMaxX:eventMaxX];
            eventCellAttributeCache[indexPath] = attributes;
            if ([self.delegate collectionView:self.collectionView layout:self shouldAdjustLayoutForItemAtIndexPath:indexPath]) {
                [itemsToAdjust addObject:attributes];
            } else {
                attributes.zIndex = NSIntegerMax;
            }
        }

        [self adjustItemsForOverlap:itemsToAdjust
                          inSection:section
                        sectionMinX:sectionMinX
                   calendarGridMinX:calendarGridMinX
                   calendarGridMaxX:eventMaxX];
    }];

    self.timeViewAttributes = timeViewAttributesCache;
    self.darkGridlineAttributes = darkGridlineViewAttributesCache;
    self.lightGridlineAttributes = lightGridlineViewAttributesCache;
    self.eventCellAttributes = eventCellAttributeCache;
}

- (nonnull UICollectionViewLayoutAttributes *)prepareLayoutForDarkGridlineWithIndexPath:(nonnull NSIndexPath *)indexPath
                                                                      calendarGridWidth:(CGFloat)calendarGridWidth
                                                                       calendarGridMinX:(CGFloat)calendarGridMinX
                                                                       calendarGridMinY:(CGFloat)calendarGridMinY {
    // Dark Grid Line
    TCNDecorationViewLayoutAttributes *const horizontalGridlineAttributes =
    [TCNDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:TCNDayViewGridlineView.darkKind
                                                                 withIndexPath:indexPath];

    const CGFloat horizontalGridlineMinY = [TCNDayViewLayout offsetForIndexPath:indexPath minY:calendarGridMinY];
    horizontalGridlineAttributes.frame = CGRectMake(calendarGridMinX, horizontalGridlineMinY, calendarGridWidth, HorizontalGridlineHeight);
    horizontalGridlineAttributes.zIndex = [self zIndexForElementKind:TCNDayViewGridlineView.darkKind];
    horizontalGridlineAttributes.backgroundColor = self.config.gridlineDarkColor;
    return horizontalGridlineAttributes;
}

- (nonnull UICollectionViewLayoutAttributes *)prepareLayoutForLightGridlineWithIndexPath:(nonnull NSIndexPath *)indexPath
                                                                       calendarGridWidth:(CGFloat)calendarGridWidth
                                                                        calendarGridMinX:(CGFloat)calendarGridMinX
                                                                        calendarGridMinY:(CGFloat)calendarGridMinY {
    // Light Grid line
    TCNDecorationViewLayoutAttributes *const horizontalLightGridlineAttributes =
    [TCNDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:TCNDayViewGridlineView.lightKind
                                                                 withIndexPath:indexPath];

    const CGFloat horizontalLightGridlineMinY = [TCNDayViewLayout offsetForIndexPath:indexPath minY:calendarGridMinY] + (HourHeight / 2);
    horizontalLightGridlineAttributes.frame = CGRectMake(calendarGridMinX, horizontalLightGridlineMinY, calendarGridWidth, HorizontalGridlineHeight);
    horizontalLightGridlineAttributes.zIndex = [self zIndexForElementKind:TCNDayViewGridlineView.lightKind];
    horizontalLightGridlineAttributes.backgroundColor = self.config.gridlineLightColor;
    return horizontalLightGridlineAttributes;
}

- (nullable UICollectionViewLayoutAttributes *)prepareLayoutForTimeViewWithIndexPath:(nonnull NSIndexPath *)indexPath
                                                                        sectionMinX:(CGFloat)sectionMinX
                                                                   calendarGridMinY:(CGFloat)calendarGridMinY {
    // Time Views
    UICollectionViewLayoutAttributes *const timeViewAttributes =
    [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:TCNDayViewTimeView.reuseIdentifier
                                                                   withIndexPath:indexPath];

    const CGFloat titleViewMinY = calendarGridMinY + (HourHeight * indexPath.row) - ceilf(HourHeight / 2.0);
    timeViewAttributes.frame = CGRectMake(sectionMinX, titleViewMinY, TimeViewWidth, HourHeight);

    timeViewAttributes.zIndex = [self zIndexForElementKind:TCNDayViewTimeView.reuseIdentifier];
    return timeViewAttributes;
}

- (nonnull UICollectionViewLayoutAttributes *)prepareLayoutForEventItemsAtIndexPath:(nonnull NSIndexPath *)indexPath
                                                                   calendarGridMinX:(CGFloat)calendarGridMinX
                                                                   calendarGridMinY:(CGFloat)calendarGridMinY
                                                                   calendarGridMaxX:(CGFloat)calendarGridMaxX {
    UICollectionViewLayoutAttributes *const itemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    NSDateComponents *const itemStartTime = [self startTimeForIndexPath:indexPath];
    NSDateComponents *const itemEndTime = [self endTimeForIndexPath:indexPath];
    if (!itemStartTime || !itemEndTime) {
        return itemAttributes;
    }

    // Don't lay out something that has the same start and end time.
    if ([itemStartTime isEqual:itemEndTime]) {
        itemAttributes.frame = CGRectZero;
        return itemAttributes;
    }

    const CGFloat startHourY = itemStartTime.hour * HourHeight;
    const CGFloat startMinuteY = itemStartTime.minute * MinuteHeight;

    const CGFloat endHourY = itemEndTime.hour * HourHeight;
    const CGFloat endMinuteY = itemEndTime.minute * MinuteHeight;

    const CGFloat itemMinY = [TCNNumberHelper ceil:(startHourY + startMinuteY + calendarGridMinY + CellMargin.top)];
    const CGFloat itemMaxY = [TCNNumberHelper ceil:(endHourY + endMinuteY + calendarGridMinY - CellMargin.bottom)];
    const CGFloat itemMinX = [TCNNumberHelper ceil:(calendarGridMinX + CellMargin.left)];
    const CGFloat itemMaxX = [TCNNumberHelper ceil:(calendarGridMaxX - CellMargin.right)];

    itemAttributes.frame = CGRectMake(itemMinX, itemMinY, (itemMaxX - itemMinX), (itemMaxY - itemMinY));
    itemAttributes.zIndex = [self zIndexForElementKind:TCNEventCell.reuseIdentifier];
    return itemAttributes;
}

- (nullable NSDateComponents *)startTimeForIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDate *const date = [self.delegate collectionView:self.collectionView layout:self startTimeForItemAtIndexPath:indexPath];
    if (!date) {
        return nil;
    }
    NSDateComponents *const itemStartTimeDateComponents =
    [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone localTimeZone]
                                              fromDate:date];
    return itemStartTimeDateComponents;
}

- (nullable NSDateComponents *)endTimeForIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDate *const date = [self.delegate collectionView:self.collectionView layout:self endTimeForItemAtIndexPath:indexPath];
    if (!date) {
        return nil;
    }

    NSDateComponents *const itemEndTimeComponents =
    [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:date];
    return itemEndTimeComponents;
}

- (void)adjustItemsForOverlap:(nonnull NSArray<UICollectionViewLayoutAttributes *> *)sectionItemAttributes
                    inSection:(__unused NSInteger)section
                  sectionMinX:(__unused CGFloat)sectionMinX
             calendarGridMinX:(CGFloat)calendarGridMinX
             calendarGridMaxX:(CGFloat)calendarGridMaxX {
    NSMutableSet<UICollectionViewLayoutAttributes *> *const adjustedAttributes = [[NSMutableSet alloc] init];
    NSInteger sectionZ = TCNDayViewLayoutZIndexEventItem;

    for (UICollectionViewLayoutAttributes *itemAttributes in sectionItemAttributes) {
        // If an item's already been adjusted, move on to the next one
        if ([adjustedAttributes containsObject:itemAttributes]) {
            continue;
        }

        // Find the other items that overlap with this item
        NSMutableArray<UICollectionViewLayoutAttributes *> *const overlappingItems = [[NSMutableArray alloc] init];
        const CGRect itemFrame = itemAttributes.frame;

        NSPredicate *const predicate =
        [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, __unused NSDictionary *bindings) {
            return ([self.delegate collectionView:self.collectionView layout:self shouldAdjustLayoutForItemAtIndexPath:layoutAttributes.indexPath]
                    && layoutAttributes != itemAttributes)
            ? CGRectIntersectsRect(itemFrame, layoutAttributes.frame)
            : NO;
        }];
        NSArray<UICollectionViewLayoutAttributes *> *const filteredItemAttributes = [sectionItemAttributes filteredArrayUsingPredicate:predicate];
        [overlappingItems addObjectsFromArray:filteredItemAttributes];

        // If there are items overlapping, we need to adjust them
        if (!overlappingItems.count) {
            continue;
        }

        // Add the item we're adjusting to the overlap set
        [overlappingItems insertObject:itemAttributes atIndex:0];

        // Find the minY and maxY of the set
        CGFloat minY = CGFLOAT_MAX;
        CGFloat maxY = CGFLOAT_MIN;
        for (UICollectionViewLayoutAttributes *overlappingItemAttributes in overlappingItems) {
            minY = MIN(CGRectGetMinY(overlappingItemAttributes.frame), minY);
            maxY = MAX(CGRectGetMaxY(overlappingItemAttributes.frame), maxY);
        }

        // Determine the number of divisions needed (maximum number of currently overlapping items)
        NSInteger divisions = 1;
        for (NSInteger currentY = lround(minY); currentY <= maxY; currentY ++) {
            NSInteger numberItemsForCurrentY = 0;
            for (UICollectionViewLayoutAttributes *overlappingItemAttributes in overlappingItems) {
                if ((currentY >= CGRectGetMinY(overlappingItemAttributes.frame)) && (currentY < CGRectGetMaxY(overlappingItemAttributes.frame))) {
                    numberItemsForCurrentY++;
                }
            }
            divisions = MAX(numberItemsForCurrentY, divisions);
        }

        // Adjust the items to have a width of the section size divided by the number of divisions needed
        const CGFloat divisionWidth = (calendarGridMaxX - calendarGridMinX) / divisions;

        NSMutableArray *const dividedAttributes = [[NSMutableArray alloc] init];
        for (UICollectionViewLayoutAttributes *divisionAttributes in overlappingItems) {
            const CGFloat itemWidth = (divisionWidth - CellMargin.left - CellMargin.right);

            // It it hasn't yet been adjusted, perform adjustment
            if (![adjustedAttributes containsObject:divisionAttributes]) {
                CGRect divisionAttributesFrame = divisionAttributes.frame;
                divisionAttributesFrame.origin.x = (calendarGridMinX + CellMargin.left);
                divisionAttributesFrame.size.width = itemWidth;

                // Horizontal Layout
                NSInteger adjustments = 1;
                for (UICollectionViewLayoutAttributes *dividedItemAttributes in dividedAttributes) {
                    if (CGRectIntersectsRect(dividedItemAttributes.frame, divisionAttributesFrame)) {
                        divisionAttributesFrame.origin.x = calendarGridMinX + ((divisionWidth * adjustments) + CellMargin.left);
                        adjustments++;
                    }
                }

                // Stacking (lower items stack above higher items, since the title is at the top)
                divisionAttributes.zIndex = sectionZ;
                sectionZ++;

                divisionAttributes.frame = divisionAttributesFrame;
                [dividedAttributes addObject:divisionAttributes];
                [adjustedAttributes addObject:divisionAttributes];
            }
        }
    }
}

- (CGSize)collectionViewContentSize {
    const CGFloat height = SectionHeight + ContentMargin.top + ContentMargin.bottom;
    const CGFloat width = [self stackedSectionWidth];
    return CGSizeMake(width, height);
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.eventCellAttributes[indexPath];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (![kind isEqualToString:TCNDayViewTimeView.reuseIdentifier]) {
        return nil;
    }
    return self.timeViewAttributes[indexPath];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath {
    if ([decorationViewKind isEqualToString:TCNDayViewGridlineView.darkKind]) {
        return self.darkGridlineAttributes[indexPath];
    } else if ([decorationViewKind isEqualToString:TCNDayViewGridlineView.lightKind]) {
        return self.lightGridlineAttributes[indexPath];
    }
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    // Return the visible attributes (rect intersection)
    NSPredicate *const predicate =
    [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, __unused NSDictionary *bindings) {
        return CGRectIntersectsRect(rect, layoutAttributes.frame);
    }];
    return [self.allAttributes filteredArrayUsingPredicate:predicate];
}

- (void)invalidateLayoutCache {
    // Invalidate cached item attributes
    self.allAttributes = [[NSArray alloc] init];
    self.eventCellAttributes = [[NSDictionary alloc] init];
    self.timeViewAttributes = [[NSDictionary alloc] init];
    self.darkGridlineAttributes = [[NSDictionary alloc] init];
    self.lightGridlineAttributes = [[NSDictionary alloc] init];
}

- (NSInteger)zIndexForElementKind:(nonnull NSString *)elementKind {
    if ([elementKind isEqualToString:TCNDayViewTimeView.reuseIdentifier]) {
        // Time Row Header
        return TCNDayViewLayoutZIndexTimeView;
    } else if ([elementKind isEqualToString:TCNDayViewGridlineView.darkKind] || [elementKind isEqualToString:TCNDayViewGridlineView.lightKind]) {
        // Horizontal Gridline
        return TCNDayViewLayoutZIndexGridline;
    }

    return TCNDayViewLayoutZIndexEventItem;
}

#pragma mark Section Sizing

/**
 Returns the width of a particular section. In this case it will be the bound of the collectionView as a section takes up entire screen
 */
- (CGFloat)sectionWidth {
    return CGRectGetWidth(self.collectionView.bounds);
}

/**
 Returns the sum of the widths of all sections combined together
 */
- (CGFloat)stackedSectionWidth {
    return [self stackedSectionWidthUpToSection:self.collectionView.numberOfSections];
}

/*
 Returns the sum of widths of sections upto the section specified
 */
- (CGFloat)stackedSectionWidthUpToSection:(NSInteger)upToSection {
    return [self sectionWidth] * upToSection;
}

@end
