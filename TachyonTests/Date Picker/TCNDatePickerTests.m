#import <XCTest/XCTest.h>
#import <LayoutTest/LYTLayoutTestCase.h>
#import <LayoutTestBase/LYTViewProvider.h>

#import "TCNDatePickerView.h"
#import "TCNDatePickerDayView.h"
#import "TCNDateUtil.h"
#import "TCNDatePickerSelectionIndicatorView.h"

@interface TCNDatePickerView (Testing) <LYTViewProvider>

@property (nonatomic, strong, nonnull, readonly) UICollectionView *collectionView;

@end

@interface TCNDatePickerTests : LYTLayoutTestCase <LYTViewProvider>

@end

@implementation TCNDatePickerTests

- (void)testLayout {
    [self runLayoutTestsWithViewProvider:[self class]
        validation:^(TCNDatePickerView *_Nonnull view, NSDictionary * _Nonnull data, id  _Nullable context) {
            [self ignoreSelectionIndicatorViewOnCollectionView:view.collectionView];
            [self ignoreNonActiveCellsOnDatePicker:view];
        }];
}

- (void)testDateSelection {
    UIViewController *const viewController = [[UIViewController alloc] init];
    CGRect datePickerFrame = CGRectMake(0, 0, viewController.view.frame.size.width, 50);
    TCNDatePickerView *const datePicker = [[TCNDatePickerView alloc] initWithFrame:datePickerFrame];
    [viewController.view addSubview:datePicker];

    NSDateFormatter *const formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *const date = [formatter dateFromString:@"2019-01-25 13:30:23"];
    [datePicker selectDate:date animated:NO];

    XCTAssertTrue([TCNDateUtil isDate:date inSameDayAsDate:datePicker.selectedDate]);
}

#pragma mark - LYTViewProvider

+ (NSDictionary *)dataSpecForTest {
    return @{};
}

+ (UIView *)viewForData:(NSDictionary *)data reuseView:(UIView *)reuseView size:(LYTViewSize *)size context:(id  _Nullable __autoreleasing *)context {
    CGRect datePickerFrame = CGRectMake(
        0,
        0,
        UIScreen.mainScreen.bounds.size.width,
        [TCNDatePickerView heightRequiredForConfig:[[TCNDatePickerConfig alloc] init]]);
    TCNDatePickerView *const datePicker = [[TCNDatePickerView alloc] initWithFrame:datePickerFrame];

    // We need to call willMoveToSuperview to set the delegate and dataSource of TCNDatePickerView.
    [datePicker willMoveToSuperview:[[UIView alloc] init]];
    [datePicker selectDate:[NSDate date] animated:NO];

    return datePicker;
}

#pragma mark - Helpers

- (void)ignoreSelectionIndicatorViewOnCollectionView:(nonnull UICollectionView *)collectionView {
    for (UIView *view in collectionView.subviews) {
        if ([view isKindOfClass:[TCNDatePickerSelectionIndicatorView class]]) {
            [[self viewsAllowingOverlap] addObject:view];
        }
    }
}

/**
 Ignores subviews for all cells not in the active week for the given date picker,
 and ignores the cells themselves since layout calculation does not work with UICollectionViews.
 */
- (void)ignoreNonActiveCellsOnDatePicker:(nonnull TCNDatePickerView *)datePicker {
    NSArray<NSDate *> *const activeWeekDates = [TCNDateUtil daysOfWeekFromDate:datePicker.selectedDate];
    for (UIView *view in datePicker.collectionView.subviews) {
        if ([view isKindOfClass:[TCNDatePickerDayView class]]) {
            TCNDatePickerDayView *const cell = ((TCNDatePickerDayView *)view);
            if (![activeWeekDates containsObject:cell.date]) {
                [self recursivelyIgnoreOverlappingSubviewsOnView:cell];
            }
            [[self viewsAllowingOverlap] addObject:cell];
        }
    }
}

@end
