#import <XCTest/XCTest.h>
#import <LayoutTest/LYTLayoutTestCase.h>

#import "TCNEventCell.h"


@interface TCNEventCellTests : LYTLayoutTestCase <LYTViewProvider>

@end

@implementation TCNEventCellTests

- (void)testUnselectedDisplay {
    [self runLayoutTestsWithViewProvider:[self class] validation:^(TCNEventCell *_Nonnull eventCell, NSDictionary * _Nonnull data, id  _Nullable context) {
        [eventCell applyStylingFromConfig:[[TCNDayViewConfig alloc] init] selected:NO];
        [eventCell updateWithEvent:[[TCNEvent alloc] initWithName:@"Test" startDateTime:[NSDate date]]];
        [eventCell layoutSubviews];
    }];
}

- (void)testSelectedDisplay {
    [self runLayoutTestsWithViewProvider:[self class] validation:^(TCNEventCell *_Nonnull eventCell, NSDictionary * _Nonnull data, id  _Nullable context) {
        [eventCell applyStylingFromConfig:[[TCNDayViewConfig alloc] init] selected:YES];
        [eventCell updateWithEvent:[[TCNEvent alloc] initWithName:@"Test" startDateTime:[NSDate date]]];
        [eventCell layoutSubviews];

        [self ignoreAccessibilityCheckForEventCell:eventCell];
    }];
}

- (void)testCompactDisplay {
    [self runLayoutTestsWithViewProvider:[self class] validation:^(TCNEventCell *_Nonnull eventCell, NSDictionary * _Nonnull data, id  _Nullable context) {
        TCNEvent *const event = [[TCNEvent alloc] initWithName:@"Test"
                                                  startDateTime:[NSDate date]
                                                    endDateTime:[NSDate date]
                                                       location:nil
                                                       timezone:nil
                                                       isAllDay:YES];
        [eventCell applyStylingFromConfig:[[TCNDayViewConfig alloc] init] selected:NO];
        [eventCell updateWithEvent:event];
        [eventCell layoutSubviews];
    }];
}

- (void)ignoreAccessibilityCheckForEventCell:(nonnull TCNEventCell *)eventCell {
    for (UIView *view in eventCell.contentView.subviews) {
        if ([view isKindOfClass:UIButton.self]) {
            [self.viewsAllowingAccessibilityErrors addObject:view];
        }
    }
}

# pragma mark - LYTViewProvider

+ (NSDictionary *)dataSpecForTest {
    return @{};
}

+ (UIView *)viewForData:(NSDictionary *)data reuseView:(UIView *)reuseView size:(LYTViewSize *)size context:(id  _Nullable __autoreleasing *)context {
    TCNEventCell *const eventCell = [[TCNEventCell alloc] initWithFrame:UIScreen.mainScreen.bounds];

    return eventCell;
}

@end
