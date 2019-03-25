#import "TCNAllDayViewLayout.h"
#import "TCNDateUtil.h"
#import "TCNDayView.h"
#import "TCNDayViewLayout.h"
#import "TCNDayViewGridlineView.h"
#import "TCNDayViewTimeView.h"
#import "TCNMacros.h"
#import "TCNEventCell.h"

@interface TCNDayView ()<UICollectionViewDelegate, UICollectionViewDataSource, TCNDayViewLayoutDelegate>

@property (nonatomic, strong, nonnull, readonly) TCNDayViewLayout *collectionViewLayout;
@property (nonatomic, strong, nonnull, readonly) TCNDayViewLayout *allDayCollectionViewLayout;
@property (nonatomic, strong, nonnull, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, nonnull, readonly) UICollectionView *allDayCollectionView;
@property (nonatomic, strong, nonnull, readonly) TCNDayViewConfig *config;
@property (nonatomic, strong, nonnull, readonly) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation TCNDayView

#pragma mark - Static

static const NSInteger DefaultHour = 8;

#pragma mark - Initialization

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame config:[[TCNDayViewConfig alloc] init]];
}

- (nonnull instancetype)initWithFrame:(CGRect)frame config:(nonnull TCNDayViewConfig *)config {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    _defaultHour = DefaultHour;
    _config = config;
    _collectionViewLayout = [TCNDayView collectionViewLayoutWithConfig:config isAllDay:NO];
    _allDayCollectionViewLayout = [TCNDayView collectionViewLayoutWithConfig:config isAllDay:YES];
    _collectionView = [TCNDayView collectionViewWithConfig:config collectionViewLayout:_collectionViewLayout superview:self isAllDay:NO];
    _allDayCollectionView = [TCNDayView collectionViewWithConfig:config collectionViewLayout:_allDayCollectionViewLayout superview:self isAllDay:YES];
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dayViewTapped:)];
    [_collectionView addGestureRecognizer:_tapGestureRecognizer];

    return self;
}

#pragma mark - Class helpers

+ (nonnull TCNDayViewLayout *)collectionViewLayoutWithConfig:(nonnull TCNDayViewConfig *)config isAllDay:(BOOL)isAllDay {
    TCNDayViewLayout *const collectionViewLayout = isAllDay
        ? [[TCNAllDayViewLayout alloc] initWithConfig:config]
        : [[TCNDayViewLayout alloc] initWithConfig:config];
    [collectionViewLayout registerClass:TCNDayViewGridlineView.class forDecorationViewOfKind:TCNDayViewGridlineView.darkKind];
    [collectionViewLayout registerClass:TCNDayViewGridlineView.class forDecorationViewOfKind:TCNDayViewGridlineView.lightKind];
    return collectionViewLayout;
}

+ (nonnull UICollectionView *)collectionViewWithConfig:(nonnull TCNDayViewConfig *)config
                                  collectionViewLayout:(nonnull TCNDayViewLayout *)layout
                                             superview:(nonnull UIView *)superview
                                              isAllDay:(BOOL)isAllDay {
    UICollectionView *const collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = config.backgroundColor;

    collectionView.directionalLockEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [collectionView registerClass:TCNEventCell.class forCellWithReuseIdentifier:TCNEventCell.reuseIdentifier];
    [collectionView registerClass:TCNDayViewTimeView.class
       forSupplementaryViewOfKind:TCNDayViewTimeView.reuseIdentifier
              withReuseIdentifier:TCNDayViewTimeView.reuseIdentifier];

    [superview addSubview:collectionView];

    if (isAllDay) {
        if (config.allDayViewBackgroundProvider) {
            collectionView.backgroundView = config.allDayViewBackgroundProvider();
        }
        if (config.customAllDayViewConfig) {
            config.customAllDayViewConfig(collectionView);
        }
    } else {
        if (config.dayViewBackgroundProvider) {
            collectionView.backgroundView = config.dayViewBackgroundProvider();
        }
        if (config.customDayViewConfig) {
            config.customDayViewConfig(collectionView);
        }
    }

    return collectionView;
}

/**
 Returns a calendar event with the selected date, with a default length of one hour.
 The start time is determined by rounding the given date to the nearest interval, based off @c TCNDayViewConfig.defaultEventLength.

 @param date The date tapped on the day view.
 @param name The name of the event to be created.
 @param length The length of the event to be created, in minutes.
 */
+ (nonnull TCNEvent *)calendarEventWithSelectedDate:(nonnull NSDate *)date eventName:(nonnull NSString *)name eventLength:(TCNEventLength)length {
    NSDateComponents *const components = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:date];
    const NSInteger secondsInSelectedTime = (components.hour * 3600) + (components.minute * 60);

    const NSInteger secondsPerChunk = ((NSInteger)length) * 60;
    const double chunks = secondsInSelectedTime / secondsPerChunk;
    const NSInteger roundedSeconds = ((NSInteger)round(chunks)) * secondsPerChunk;
    const NSInteger newHour = roundedSeconds / 3600;
    const NSInteger newMinute = (roundedSeconds - (newHour * 3600)) / 60;
    NSDate *const newDate = [TCNDateUtil dateWithDate:date
                                               atHour:newHour
                                            andMinute:newMinute];

    NSDate *const endDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitMinute
                                                                     value:length
                                                                    toDate:newDate
                                                                   options:0];
    TCNEvent *const event = [[TCNEvent alloc] initWithName:name
                                             startDateTime:newDate
                                               endDateTime:endDate
                                                  location:nil
                                                  timezone:[NSTimeZone localTimeZone]
                                                  isAllDay:NO];
    event.isSelected = YES;
    return event;
}

#pragma mark - Methods

- (void)reloadAndResetScrolling:(BOOL)resetScrolling {
    [self.collectionView reloadData];
    [self.allDayCollectionView reloadData];
    [self setNeedsLayout];

    if (!resetScrolling) {
        return;
    }

    // We are able to scroll without forcing a layout because the UICollectionView will calculate indexes and offsets before
    // returning from reloadData.
    NSIndexPath *const indexPathForDefaultHour = [NSIndexPath indexPathForRow:self.defaultHour inSection:0];
    const CGFloat yOffsetForDefaultHour = [TCNDayViewLayout offsetForIndexPath:indexPathForDefaultHour
                                                                          minY:TCNDayViewLayout.topInsetMargin];
    // The offset to scroll to is calculated as the hour offset + the collection view's height - the default top inset, so that the
    // hour is displayed at the top of the screen.
    const CGFloat yOffsetToScrollTo = yOffsetForDefaultHour + self.collectionView.frame.size.height - TCNDayViewLayout.topInsetMargin;
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self.collectionView scrollRectToVisible:CGRectMake(0, yOffsetToScrollTo, 1, 1) animated:NO];
}

- (nonnull NSArray<TCNEvent *> *)dayEvents {
    return self.dataSource.dayEvents ?: @[];
}

- (nonnull NSArray<TCNEvent *> *)allDayEvents {
    return self.dataSource.allDayEvents ?: @[];
}

- (void)dayViewTapped:(nonnull UITapGestureRecognizer *)recognizer {
    NSDate *const currentDate = self.dataSource.currentDate;
    if (!currentDate) {
        return;
    }
    const CGPoint location = [recognizer locationInView:self.collectionView];
    NSDateComponents *const tappedComponents = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone localTimeZone]
                                                                                         fromDate:[TCNDayViewLayout timeForYOffset:location.y]];
    NSDate *const selectedDate = [TCNDateUtil dateWithDate:TCN_FORCE_UNWRAP(currentDate)
                                                    atHour:tappedComponents.hour
                                                 andMinute:tappedComponents.minute];

    [self.delegate dayView:self didSelectAvailabilityWithEvent:[TCNDayView calendarEventWithSelectedDate:selectedDate
                                                                                               eventName:self.config.createdEventText
                                                                                             eventLength:self.config.defaultEventLength]];
}

#pragma mark - View Lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];

    const NSInteger numberOfAllDayItems = [self.allDayCollectionView numberOfItemsInSection:0];
    if (numberOfAllDayItems) {
        [self.allDayCollectionView scrollRectToVisible:CGRectZero animated:false];
        const CGFloat allDayViewHeight = [TCNAllDayViewLayout allDayViewHeightForEventCount:numberOfAllDayItems];
        self.collectionView.frame = CGRectMake(0, allDayViewHeight, self.bounds.size.width, self.bounds.size.height - allDayViewHeight);
        self.allDayCollectionView.frame = CGRectMake(0, 0, self.bounds.size.width, allDayViewHeight);
    } else {
        self.collectionView.frame = self.bounds;
        self.allDayCollectionView.frame = CGRectZero;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];

    self.collectionViewLayout.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.allDayCollectionViewLayout.delegate = self;
    self.allDayCollectionView.dataSource = self;
    self.allDayCollectionView.delegate = self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(__unused UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(__unused NSInteger)section {
    if (collectionView == self.collectionView) {
        return (NSInteger)self.dayEvents.count;
    } else {
        return (NSInteger)self.allDayEvents.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<TCNEvent *> *const events = collectionView == self.collectionView ? self.dayEvents : self.allDayEvents;
    UICollectionViewCell *const collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:TCNEventCell.reuseIdentifier
                                                                                               forIndexPath:indexPath];
    TCNEventCell *const eventCell = TCN_CAST_OR_NIL(collectionViewCell, TCNEventCell);
    if (!eventCell) {
        return collectionViewCell;
    }
    TCNEvent *const event = events[(NSUInteger)indexPath.row];
    __weak typeof(self) weakSelf = self;
    eventCell.cancelHandler = ^{
        typeof(self) strongSelf = weakSelf;
        id<TCNDayViewDelegate> strongDelegate = strongSelf.delegate;
        if (!strongSelf || !strongDelegate) {
            return;
        }
        if ([strongDelegate respondsToSelector:@selector(dayView:didCancelEvent:)]) {
            [strongDelegate dayView:strongSelf didCancelEvent:event];
        }
    };
    [eventCell updateWithEvent:event];
    [eventCell applyStylingFromConfig:self.config selected:event.isSelected];
    return eventCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *const reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                      withReuseIdentifier:TCNDayViewTimeView.reuseIdentifier
                                                                                             forIndexPath:indexPath];
    if (![kind isEqualToString:TCNDayViewTimeView.reuseIdentifier] || (collectionView == self.allDayCollectionView && indexPath.row > 0)) {
        return reusableView;
    }

    TCNDayViewTimeView *const timeView = TCN_CAST_OR_NIL(reusableView, TCNDayViewTimeView);
    if (!timeView) {
        NSAssert(NO, @"Unable to cast UICollectionReusableView to TCNDayViewTimeView");
        return nil;
    }
    [timeView applyStylingFromConfig:self.config selected:NO];
    NSDate *const time = [self timeForTimeViewAtIndexPath:indexPath];
    if (collectionView == self.collectionView) {
        timeView.time = time;
    } else {
        [timeView updateAllDayEventText];
    }

    return timeView;
}

- (nonnull NSDate *)timeForTimeViewAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDateComponents *const dateComponents = [[NSDateComponents alloc] init];
    dateComponents.hour = indexPath.item;

    NSDate *const date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    if (!date) {
        TCN_ASSERT_FAILURE(@"No date created in dateForTimeViewAtIndexPath");
        // we'll just return current date if we fail to calculate a date
        return [NSDate date];
    }

    return date;
}

#pragma mark - TCNDayViewLayoutDelegate

/**
 This method will calculate the appropriate start time to display.

 - If the event does not occur at all on this day, return the beginning of this day.
 - Else, if the event is all day, this will just return the beginning of this day view's day.
 - Else, we return the later time of either the event's start time or the beginning of the day view's day.
   This accounts for the possibility that this is a multi-day event.
 */
- (nonnull NSDate *)collectionView:(nullable UICollectionView *)collectionView
                            layout:(nonnull __unused TCNDayViewLayout *)collectionViewLayout
       startTimeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *const currentDate = self.dataSource.currentDate;
    if (!currentDate || !collectionView) {
        return [NSDate date];
    }

    TCNEvent *const event = [self eventForIndexPath:indexPath collectionView:TCN_FORCE_UNWRAP(collectionView)];
    if (!event) {
        return [NSDate new];
    }
    NSDate *const startOfThisDay = [[NSCalendar currentCalendar] startOfDayForDate:TCN_FORCE_UNWRAP(currentDate)];
    if (!startOfThisDay) {
        return [NSDate date];
    }

    if (![event occursOnDay:currentDate]) {
        return startOfThisDay;
    } else if (event.isAllDay) {
        return startOfThisDay;
    } else {
        return [TCNDateUtil latestDate:event.startDateTime otherDate:startOfThisDay];
    }
}

/**
 This method will calculate the appropriate end time to display.

 - If the event does not occur on this day, return the beginning of this day.
 - Else, if the event is all day, this will just return the end of this day view's day.
 - Else, we return the earlier time of either the event's end time or the end of the day view's day.
   This accounts for the possibility that this is a multi-day event.
 */
- (nonnull NSDate *)collectionView:(nullable UICollectionView *)collectionView
                            layout:(nonnull __unused TCNDayViewLayout *)collectionViewLayout
         endTimeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSDate *const currentDateOrNil = self.dataSource.currentDate;
    if (!currentDateOrNil || !collectionView) {
        return [NSDate date];
    }
    NSDate *const currentDate = TCN_FORCE_UNWRAP(currentDateOrNil);

    TCNEvent *const event = [self eventForIndexPath:indexPath collectionView:TCN_FORCE_UNWRAP(collectionView)];
    if (!event) {
        return [NSDate new];
    }
    NSDate *const startOfThisDay = [[NSCalendar currentCalendar] startOfDayForDate:currentDate];
    NSDate *const endOfThisDay = [TCNDateUtil endOfDayForDate:currentDate];
    if (!startOfThisDay) {
        return [NSDate date];
    }

    if (![event occursOnDay:currentDate]) {
        return startOfThisDay;
    } else if (event.isAllDay) {
        return startOfThisDay;
    } else {
        return [TCNDateUtil earliestDate:event.endDateTime otherDate:endOfThisDay];
    }
}

/**
 Returns true if we don't want to adjust frames for the given item, and instead allow it to display over unselected items.
 */
- (BOOL)collectionView:(nullable __unused UICollectionView *)collectionView
                                layout:(nonnull __unused TCNDayViewLayout *)collectionViewLayout
  shouldAdjustLayoutForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (!collectionView) {
        return NO;
    }
    return ![self eventForIndexPath:indexPath collectionView:TCN_FORCE_UNWRAP(collectionView)].isSelected;
}

- (nullable TCNEvent *)eventForIndexPath:(nonnull NSIndexPath *)indexPath collectionView:(nonnull UICollectionView *)collectionView {
    NSArray<TCNEvent *> *const events = [(collectionView == self.collectionView ? self.dayEvents : self.allDayEvents) copy];
    NSUInteger index = (NSUInteger)indexPath.row;
    if (events.count <= index) {
        TCN_ASSERT_FAILURE(@"Index out of bounds for calendar data source");
        return nil;
    }
    return events[index];
}

@end
