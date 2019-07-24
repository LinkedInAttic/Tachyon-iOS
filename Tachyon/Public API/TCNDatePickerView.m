#import "TCNDatePickerDataSource.h"
#import "TCNDatePickerView.h"
#import "TCNDateUtil.h"
#import "TCNDateFormatter.h"
#import "TCNDatePickerDayView.h"
#import "TCNDatePickerSelectionIndicatorView.h"
#import "TCNMacros.h"
#import "TCNNumberHelper.h"
#import "TCNDatePickerLayout.h"
#import "TCNViewUtils.h"

@interface TCNDatePickerView () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TCNDatePickerLayoutDelegate>

@property (nonatomic, strong, nonnull, readonly) TCNDatePickerLayout *collectionViewLayout;
@property (nonatomic, strong, nonnull, readonly) TCNDatePickerConfig *config;
@property (nonatomic, strong, nonnull, readonly) TCNDatePickerDataSource *datePickerDataSource;
@property (nonatomic, strong, nonnull, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, nonnull, readonly) UILabel *monthLabel;

/**
 The is used to re-layout the collection view if we detect a width change, and is updated every time @c layoutSubviews is called.
 This helps to handle screen rotation or app resizing.
 */
@property (nonatomic, assign, readwrite) CGFloat collectionViewItemWidth;

/**
 A state variable used to keep track of the last @c contentOffset of @c collectionView.
 Used to give a snapping effect to our @c collectionView
 */
@property (nonatomic, assign, readwrite) CGPoint lastContentOffset;

@end

@implementation TCNDatePickerView

static const CGFloat DayItemHeight = 44.0f;
static const CGFloat DayViewInterItemSpacing = 8.0f;
static const CGFloat DayViewLineSpacing = 8.0f;
static const CGFloat HorizontalInsetDimension = 8.0f;
static const CGFloat VerticalInterItemSpacing = 12.0f;
static const NSInteger DaysInAWeek = 7;

/**
 This adds some padding above and below the text in the title label.
 */
static const CGFloat AdditionalTitleLabelHeight = 1.0f;

#pragma mark - Initialization

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame config:[[TCNDatePickerConfig alloc] init]];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame config:(nonnull TCNDatePickerConfig *)config {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    _collectionViewItemWidth = 0;
    _config = config;
    _monthLabel = [TCNDatePickerView labelWithConfig:config andSuperview:self];
    _collectionViewLayout = [TCNDatePickerView collectionViewLayoutWithConfig:config];
    _datePickerDataSource = [TCNDatePickerView collectionViewDataSourceWithConfig:config];
    _collectionView = [TCNDatePickerView collectionViewWithConfig:config layout:_collectionViewLayout dataSource:_datePickerDataSource superview:self];

    [TCNDatePickerView configureView:self withConfig:config];

    return self;
}

#pragma mark - Class Methods

+ (CGFloat)heightRequiredForConfig:(nonnull TCNDatePickerConfig *)config {
    return (3 * VerticalInterItemSpacing)
    + DayItemHeight
    + config.monthLabelFont.lineHeight + AdditionalTitleLabelHeight;
}

/**
 Returns the width per day item given a bounding width.
 */
+ (CGFloat)collectionViewItemWidthForBoundingWidth:(CGFloat)width {
    const CGFloat unroundedWidth = (width - (2.0f * HorizontalInsetDimension) - ((DaysInAWeek - 1) * DayViewInterItemSpacing)) / 7;
    return [TCNNumberHelper floor:unroundedWidth];
}

/**
 Returns the additional right inset for a given bounding width.
 Additional spacing is created because of item widths being an integer value.
 */
+ (CGFloat)additionalCollectionViewRightInsetSpacingForBoundingWidth:(CGFloat)boundingWidth andItemWidth:(CGFloat)itemWidth {
    return boundingWidth
    - (DaysInAWeek * itemWidth)
    - (2 * HorizontalInsetDimension)
    - ((DaysInAWeek - 1) * DayViewInterItemSpacing);
}

+ (void)configureView:(nonnull UIView *)view withConfig:(nonnull TCNDatePickerConfig *)config {
    view.backgroundColor = config.backgroundColor;
}

+ (nonnull UILabel *)labelWithConfig:(nonnull TCNDatePickerConfig *)config andSuperview:(UIView *)view {
    UILabel *const label = [[UILabel alloc] init];
    label.font = config.monthLabelFont;
    label.textColor = config.textColor;
    label.textAlignment = NSTextAlignmentCenter;
    [view addSubview:label];
    return label;
}

+ (nonnull UICollectionView *)collectionViewWithConfig:(nonnull TCNDatePickerConfig *)config
                                                layout:(nonnull UICollectionViewLayout *)layout
                                            dataSource:(nonnull TCNDatePickerDataSource *)dataSource
                                             superview:(nonnull UIView *)superview {
    UICollectionView *const collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.dataSource = dataSource;
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.allowsMultipleSelection = NO;
    collectionView.backgroundColor = UIColor.clearColor;
    [collectionView registerClass:[TCNDatePickerDayView class] forCellWithReuseIdentifier:TCNDatePickerDayView.reuseIdentifier];
    [superview addSubview:collectionView];

    if (config.datePickerBackgroundProvider) {
        collectionView.backgroundView = config.datePickerBackgroundProvider();
    }

    if (config.customDatePickerViewConfig) {
        config.customDatePickerViewConfig(collectionView);
    }

    return collectionView;
}

+ (nonnull TCNDatePickerLayout *)collectionViewLayoutWithConfig:(nonnull TCNDatePickerConfig *)config {
    TCNDatePickerLayout *const collectionViewLayout = [[TCNDatePickerLayout alloc] initWithConfig:config];
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionViewLayout.minimumLineSpacing = DayViewLineSpacing;
    collectionViewLayout.minimumInteritemSpacing = DayViewInterItemSpacing;
    [collectionViewLayout registerClass:[TCNDatePickerSelectionIndicatorView class]
                forDecorationViewOfKind:TCNDatePickerSelectionIndicatorView.reuseIdentifier];
    return collectionViewLayout;
}

+ (nonnull TCNDatePickerDataSource *)collectionViewDataSourceWithConfig:(nonnull TCNDatePickerConfig *)config {
    TCNDatePickerDataSource *const datePickerDataSource = [[TCNDatePickerDataSource alloc] initWithConfig:config];
    [datePickerDataSource setupWeekDatesWithCurrentlyVisibleDate:datePickerDataSource.selectedDate];
    return datePickerDataSource;
}

#pragma mark - Methods

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    self.collectionViewLayout.delegate = self;
    self.collectionView.delegate = self;

    [self updateMonthLabelWithDate:[TCNDateUtil middleOfWeekForDate:[[NSDate alloc] init]]];
}

- (void)selectDate:(nonnull NSDate *)date animated:(__unused BOOL)animated {
    NSIndexPath *const indexPathOfNewDate = [self.datePickerDataSource indexPathForDate:date];

    if (indexPathOfNewDate && indexPathOfNewDate.section == [TCNDatePickerDataSource datePickerSectionActiveWeek]) {
        // if the new date is in the current active week, then we don't need to do unnecessary reload
        // we can trigger cell selection
        [self triggerSelectInCollectionViewForIndexPath:indexPathOfNewDate];
    } else {
        [self updateDataSourceWithSelectedDate:date];
        [self.collectionView reloadData];

        [self scrollToActiveWeek];
    }
}

- (void)updateDataSourceWithSelectedDate:(nonnull NSDate *)date {
    if (self.selectedDate && [TCNDateUtil isDate:date inSameDayAsDate:self.selectedDate]) {
        return;
    }
    self.datePickerDataSource.selectedDate = date;
    [self.datePickerDataSource setupWeekDatesWithCurrentlyVisibleDate:date];
}

- (void)updateMonthLabelWithDate:(nonnull NSDate *)date {
    self.monthLabel.text = [TCNDateFormatter.monthAndYearFormatter stringFromDate:date];
}

- (nonnull NSDate *)selectedDate {
    return self.datePickerDataSource.selectedDate;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // The monthLabel will adhere to a bounding width. The collectionView also adheres to this width
    // but this logic will be handled by its contentInset.
    const CGFloat layoutBoundingWidth = self.frame.size.width - (2.0f * HorizontalInsetDimension);
    self.monthLabel.frame = CGRectMake(
        HorizontalInsetDimension,
        VerticalInterItemSpacing,
        layoutBoundingWidth,
        self.config.monthLabelFont.lineHeight + AdditionalTitleLabelHeight);

    const CGFloat itemWidth = [TCNDatePickerView collectionViewItemWidthForBoundingWidth:self.frame.size.width];
    const CGFloat additionalRightSpacing = [TCNDatePickerView additionalCollectionViewRightInsetSpacingForBoundingWidth:self.frame.size.width
                                                                                                                  andItemWidth:itemWidth];
    self.collectionView.frame = CGRectMake(
       0,
       self.monthLabel.frame.origin.y + self.monthLabel.frame.size.height + VerticalInterItemSpacing,
       self.frame.size.width,
       DayItemHeight);
    self.collectionView.contentInset = UIEdgeInsetsMake(
        0,
        HorizontalInsetDimension,
        0,
        HorizontalInsetDimension + additionalRightSpacing);
    self.collectionViewItemWidth = itemWidth;
    self.collectionViewLayout.sectionInset = self.collectionView.contentInset;

    [self.collectionView.collectionViewLayout invalidateLayout];
    [self scrollToActiveWeek];
}

- (void)scrollToActiveWeek {
    const UICollectionViewScrollPosition scrollPosition = [TCNViewUtils isLayoutDirectionRTL]
    ? UICollectionViewScrollPositionRight
    : UICollectionViewScrollPositionLeft;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[TCNDatePickerDataSource datePickerSectionActiveWeek]]
                                atScrollPosition:scrollPosition
                                        animated:NO];
    self.lastContentOffset = self.collectionView.contentOffset;
}

- (void)triggerSelectInCollectionViewForIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Given the indexPath, find the date object
    NSDate *const newSelectedDate = [self.datePickerDataSource dateForItemAtIndexPath:indexPath];
    if (!newSelectedDate) {
        NSAssert(NO, @"newSelectedDate is nil for indexPath in didSelectItemAtIndexPath");
        return;
    }

    // find the old indexPath so we can reload its cell along with the new indexPath
    NSIndexPath *const oldSelectedIndexPath = [self.datePickerDataSource indexPathForDate:self.selectedDate];
    NSMutableArray<NSIndexPath *> *const indexPathsToReload = [[NSMutableArray alloc] initWithObjects:indexPath, nil];
    if (oldSelectedIndexPath) {
        [indexPathsToReload addObject:oldSelectedIndexPath];
    }

    // select the new date
    [self updateDataSourceWithSelectedDate:newSelectedDate];
    [self.collectionViewLayout invalidateLayout];

    // If the new selection is a different indexPath,
    // we need to reload the old cells and new cell in performWithoutAnimation block to avoid screen flickering.
    if (indexPath != oldSelectedIndexPath) {
        [UIView performWithoutAnimation:^{
            [collectionView reloadItemsAtIndexPaths:indexPathsToReload];
        }];
    }

    [self.datePickerDelegate datePickerView:self didSelectDate:newSelectedDate];
}

- (void)scrollViewDidEndDecelerating:(__unused UIScrollView *)scrollView {
    NSDate *newDate;

    // If there is enough change in the last content offset, then we'll swipe
    if (self.collectionView.contentOffset.x - self.lastContentOffset.x > ceil(self.collectionView.frame.size.width / 3.0f)) {
        //the user scrolled to the left moving to the next week

        newDate = [self.datePickerDataSource.nextWeekDates objectAtIndex:0];
    } else if (self.lastContentOffset.x - self.collectionView.contentOffset.x > ceil(self.collectionView.frame.size.width / 3.0f)) {
        //the user scrolled to the right moving to the previous week

        newDate = [self.datePickerDataSource.previousWeekDates objectAtIndex:0];
    } else {
        return;
    }

    [self updateMonthLabelWithDate:[TCNDateUtil middleOfWeekForDate:newDate]];

    [self.datePickerDataSource setupWeekDatesWithCurrentlyVisibleDate:newDate];
    [self.collectionView reloadData];

    [self scrollToActiveWeek];
}

# pragma mark - TCNDatePickerLayoutDelegate

- (nullable NSIndexPath *)selectedDateIndexPath {
    return [self.datePickerDataSource indexPathForDate:self.selectedDate];
}

- (CGSize)collectionView:(__unused UICollectionView *)collectionView
                  layout:(__unused UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(__unused NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionViewItemWidth, DayItemHeight);
}

@end
