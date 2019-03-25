#import <XCTest/XCTest.h>
#import <LayoutTest/LYTLayoutTestCase.h>
#import <LayoutTestBase/LYTViewProvider.h>

#import "TCNDayView.h"
#import "TCNDayViewTestsViewProvider.h"
#import "TCNDayViewTimeView.h"
#import "TCNDateUtil.h"
#import "TCNEvent.h"
#import "TCNTestUtils.h"

@interface TCNDayView (Testing) <LYTViewProvider>

@property (nonatomic, strong, nonnull, readonly) UICollectionView *collectionView;
@property (nonatomic, strong, nonnull, readonly) UICollectionView *allDayCollectionView;

@end

/**
 This test tests scrollable UICollectionViews. Since LayoutTest does not support scrollable views, we assume that the scrollview
 starts with a content offset of zero. Any events added to test with therefore need to be visible within the first screen,
 unless a programmatic content offset change is triggered.

 @c TCNDayViewTestsViewProvider.sharedInstance is the dataSource of @c TCNDayView instances created through it.
 */
@interface TCNDayViewTests : LYTLayoutTestCase

@end

@implementation TCNDayViewTests

- (void)tearDown {
    [super tearDown];

    TCNDayViewTestsViewProvider.sharedInstance.events = @[];
}

- (void)testEmptyLayout {
    [self runLayoutTestsWithViewProvider:TCNDayViewTestsViewProvider.self
        validation:^(TCNDayView *_Nonnull view, NSDictionary * _Nonnull data, NSArray<TCNEvent *> * context) {
            [self ignoreTopAndBottomTimeViewsOnDayViewCollectionView:view.collectionView];
    }];
}

- (void)testEventLayout {
    NSDate *const startTime = [TCNTestUtils dateWithTime:@"2:00" onDay:[NSDate date]];
    NSDate *const startTime2 = [TCNTestUtils dateWithTime:@"3:00" onDay:[NSDate date]];
    NSDate *const endTime = [TCNTestUtils dateWithTime:@"13:00" onDay:[NSDate date]];
    NSDate *const endTime2 = [TCNTestUtils dateWithTime:@"14:00" onDay:[NSDate date]];
    TCNDayViewTestsViewProvider.sharedInstance.events = @[
                                                          [[TCNEvent alloc] initWithName:@"Hello!"
                                                                           startDateTime:startTime
                                                                             endDateTime:endTime
                                                                                location:nil
                                                                                timezone:nil
                                                                                isAllDay:NO],
                                                          [[TCNEvent alloc] initWithName:@"Hello!"
                                                                           startDateTime:startTime2
                                                                             endDateTime:endTime
                                                                                location:nil
                                                                                timezone:nil
                                                                                isAllDay:NO],
                                                          [[TCNEvent alloc] initWithName:@"Hello!"
                                                                           startDateTime:startTime
                                                                             endDateTime:endTime2
                                                                                location:nil
                                                                                timezone:nil
                                                                                isAllDay:NO]
                                                          ];

    [self runLayoutTestsWithViewProvider:TCNDayViewTestsViewProvider.self
        validation:^(TCNDayView *_Nonnull view, NSDictionary * _Nonnull data, NSArray<TCNEvent *> * context) {
            [view reloadAndResetScrolling:NO];
            [self ignoreTopAndBottomTimeViewsOnDayViewCollectionView:view.collectionView];
        }];
}

- (void)testAllDayEventLayout {
    TCNDayViewTestsViewProvider.sharedInstance.events = @[
                                                          [[TCNEvent alloc] initWithName:@"Hello!"
                                                                           startDateTime:[NSDate date]
                                                                             endDateTime:[NSDate date]
                                                                                location:nil
                                                                                timezone:nil
                                                                                isAllDay:YES],
                                                          [[TCNEvent alloc] initWithName:@"Hello!"
                                                                           startDateTime:[NSDate date]
                                                                             endDateTime:[NSDate date]
                                                                                location:nil
                                                                                timezone:nil
                                                                                isAllDay:YES],
                                                          [[TCNEvent alloc] initWithName:@"Hello!"
                                                                           startDateTime:[NSDate date]
                                                                             endDateTime:[NSDate date]
                                                                                location:nil
                                                                                timezone:nil
                                                                                isAllDay:YES]
                                                          ];

    [self runLayoutTestsWithViewProvider:TCNDayViewTestsViewProvider.self
        validation:^(TCNDayView *_Nonnull view, NSDictionary * _Nonnull data, NSArray<TCNEvent *> * context) {
            [self ignoreAllTimeViewsOnCollectionView:view.allDayCollectionView];
            [self ignoreTopAndBottomTimeViewsOnDayViewCollectionView:view.collectionView];
        }];
}

#pragma mark - Helpers

/**
 The topmost and bottommost @c TCNDayViewTimeView views may extend off-screen. Ignore them.
 */
- (void)ignoreTopAndBottomTimeViewsOnDayViewCollectionView:(nonnull UICollectionView *)collectionView {
    TCNDayViewTimeView *_Nullable topTimeView;
    TCNDayViewTimeView *_Nullable bottomTimeView;
    for (UIView *view in collectionView.subviews) {
        if (![view isKindOfClass:TCNDayViewTimeView.self]) {
            continue;
        }

        if (!topTimeView || topTimeView.frame.origin.y > view.frame.origin.y) {
            topTimeView = (TCNDayViewTimeView *)view;
        }

        if (!bottomTimeView || bottomTimeView.frame.origin.y < view.frame.origin.y) {
            bottomTimeView = (TCNDayViewTimeView *)view;
        }
    }

    if (topTimeView) {
        [self.viewsAllowingOverlap addObject:topTimeView];
    }

    if (bottomTimeView) {
        [self.viewsAllowingOverlap addObject:bottomTimeView];
    }
}

/**
 For all day collection views, the time views will almost always be truncated.

 The all day collection view also renders some time views with a height of 0.
 */
- (void)ignoreAllTimeViewsOnCollectionView:(nonnull UICollectionView *)collectionView {
    for (UIView *view in collectionView.subviews) {
        if ([view isKindOfClass:TCNDayViewTimeView.class]) {
            [self.viewsAllowingOverlap addObject:view];
            [self recursivelyIgnoreOverlappingSubviewsOnView:view];
        }
    }
}

@end
