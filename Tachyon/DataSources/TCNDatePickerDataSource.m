#import "TCNDatePickerDataSource.h"
#import "TCNDatePickerDayView.h"
#import "TCNMacros.h"
#import "TCNDateUtil.h"
#import "TCNViewUtils.h"

@interface TCNDatePickerDataSource ()

@property (nonatomic, strong, nonnull, readwrite) NSArray<NSDate *> *previousWeekDates;
@property (nonatomic, strong, nonnull, readwrite) NSArray<NSDate *> *activeWeekDates;
@property (nonatomic, strong, nonnull, readwrite) NSArray<NSDate *> *nextWeekDates;

@property (nonatomic, strong, nonnull, readonly) TCNDatePickerConfig *config;

@end

@implementation TCNDatePickerDataSource

static const int DaysInAWeek = 7;

#pragma mark - Initialization

- (nonnull instancetype)initWithConfig:(nonnull TCNDatePickerConfig *)config {
    self = [super init];
    if (!self) {
        return nil;
    }

    _config = config;
    _selectedDate = [NSDate date];
    _activeWeekDates = @[];
    _nextWeekDates = @[];
    _previousWeekDates = @[];
    return self;
}

#pragma mark - Static Helpers

+ (NSInteger)datePickerSectionPreviousWeek {
    return [TCNViewUtils isLayoutDirectionRTL] ? 2 : 0;
}

+ (NSInteger)datePickerSectionActiveWeek {
    return 1;
}

+ (NSInteger)datePickerSectionNextWeek {
    return [TCNViewUtils isLayoutDirectionRTL] ? 0 : 2;
}

#pragma mark - Methods

- (void)setupWeekDatesWithCurrentlyVisibleDate:(nonnull NSDate *)date {
    NSDate *const activeWeekDate = [TCNDateUtil dateByAddingWeeks:0 toDate:date];
    self.activeWeekDates = [TCNDateUtil daysOfWeekFromDate:activeWeekDate];

    NSDate *const nextWeekDate = [TCNDateUtil dateByAddingWeeks:1 toDate:date];
    self.nextWeekDates = [TCNDateUtil daysOfWeekFromDate:nextWeekDate];

    NSDate *const previousWeekDate = [TCNDateUtil dateByAddingWeeks:-1 toDate:date];
    self.previousWeekDates = [TCNDateUtil daysOfWeekFromDate:previousWeekDate];
}

- (nullable NSIndexPath *)indexPathForDate:(nonnull NSDate *)date {
    if (self.previousWeekDates.count != DaysInAWeek || self.activeWeekDates.count != DaysInAWeek || self.nextWeekDates.count != DaysInAWeek) {
        TCN_ASSERT_FAILURE(@"selectedDateIndexPath is called before dates are setup for past, active and next week");
        return nil;
    }

    NSInteger row = [TCNDateUtil indexOfDateInWeek:date];

    // figure out where the selectedDate is currently relative to our past/active/next week
    NSInteger section;

    if ([TCNDateUtil isDate:date inSameWeekAsDate:self.previousWeekDates[0]]) {
        section = TCNDatePickerDataSource.datePickerSectionPreviousWeek;
    } else if ([TCNDateUtil isDate:date inSameWeekAsDate:self.activeWeekDates[0]]) {
        section = TCNDatePickerDataSource.datePickerSectionActiveWeek;
    } else if ([TCNDateUtil isDate:date inSameWeekAsDate:self.nextWeekDates[0]]) {
        section = TCNDatePickerDataSource.datePickerSectionNextWeek;
    } else {
        section = NSNotFound;
    }

    // we haven't found the selected date among past/active/next week dates, so we don't know the index
    if (section == NSNotFound) {
        return nil;
    }

    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (nullable NSDate *)dateForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == TCNDatePickerDataSource.datePickerSectionPreviousWeek) {
        return [self.previousWeekDates objectAtIndex:(NSUInteger)indexPath.row];
    } else if (indexPath.section == TCNDatePickerDataSource.datePickerSectionActiveWeek) {
        return [self.activeWeekDates objectAtIndex:(NSUInteger)indexPath.row];
    } else if (indexPath.section == TCNDatePickerDataSource.datePickerSectionNextWeek) {
        return [self.nextWeekDates objectAtIndex:(NSUInteger)indexPath.row];
    } else {
        TCN_ASSERT_FAILURE(@"%ld is not a valid section - only 0, 1, or 2 are valid.", (long)indexPath.section);
        return nil;
    }
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *const collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:TCNDatePickerDayView.reuseIdentifier
                                                                                               forIndexPath:indexPath];
    TCNDatePickerDayView *const dayViewCell = TCN_CAST_OR_NIL(collectionViewCell, TCNDatePickerDayView);
    if (!dayViewCell) {
        TCN_ASSERT_FAILURE(@"Unable to cast collectionViewCell to expected type of TCNDatePickerDayView");
        return nil;
    }

    NSDate *const date = [self dateForItemAtIndexPath:indexPath];
    if (!date) {
        TCN_ASSERT_FAILURE(@"No date found for current indexPath");
        return nil;
    }
    dayViewCell.date = date;
    if ([TCNDateUtil isDate:dayViewCell.date inSameDayAsDate:self.selectedDate]) {
        [dayViewCell applyStylingFromConfig:self.config selected:YES];
        dayViewCell.selected = YES;
    } else {
        [dayViewCell applyStylingFromConfig:self.config selected:NO];
        dayViewCell.selected = NO;
    }

    return dayViewCell;
}

- (NSInteger)numberOfSectionsInCollectionView:(__unused UICollectionView *)collectionView {
    // Returns 3 for TCNDatePickerSectionPreviousWeek, TCNDatePickerSectionCurrentWeek, and TCNDatePickerSectionNextWeek
    return 3;
}

- (NSInteger)collectionView:(__unused UICollectionView *)collectionView numberOfItemsInSection:(__unused NSInteger)section {
    return DaysInAWeek;
}

@end
