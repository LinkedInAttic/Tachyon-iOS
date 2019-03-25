#import <UIKit/UIKit.h>
#import <LayoutTestBase/LYTViewProvider.h>

#import "TCNDayViewTestsViewProvider.h"
#import "TCNEvent.h"

@implementation TCNDayViewTestsViewProvider

+ (instancetype)sharedInstance {
    static TCNDayViewTestsViewProvider *_provider;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _provider = [[self alloc] init];
    });
    return _provider;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _events = @[];
    return self;
}

#pragma mark - TCNDayViewDataSource

- (nonnull NSDate *)currentDate {
    if (self.events.firstObject) {
        return self.events.firstObject.startDateTime;
    }
    return [NSDate date];
}

- (nonnull NSArray<TCNEvent *> *)dayEvents {
    if (!self.events) {
        return @[];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isAllDay == FALSE"];
    return [self.events filteredArrayUsingPredicate:predicate];
}

- (nonnull NSArray<TCNEvent *> *)allDayEvents {
    if (!self.events) {
        return @[];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isAllDay == TRUE"];
    return [self.events filteredArrayUsingPredicate:predicate];
}

#pragma mark - LYTViewProvider

+ (NSDictionary *)dataSpecForTest {
    return @{};
}

+ (UIView *)viewForData:(NSDictionary *)data reuseView:(UIView *)reuseView size:(LYTViewSize *)size context:(id  _Nullable __autoreleasing *)context {
    TCNDayView *const dayView = [[TCNDayView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    dayView.dataSource = self.sharedInstance;

    // We need to call willMoveToSuperview to set the delegates and dataSources
    [dayView willMoveToSuperview:[[UIView alloc] init]];

    return dayView;
}

@end
