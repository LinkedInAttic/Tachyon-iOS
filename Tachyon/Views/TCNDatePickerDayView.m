#import "TCNDatePickerDayView.h"
#import "TCNDateFormatter.h"
#import "TCNMacros.h"

@interface TCNDatePickerDayView ()

@property (nonatomic, strong, nonnull) UILabel *dayOfWeekLabel;
@property (nonatomic, strong, nonnull) UILabel *dateLabel;

@end

@implementation TCNDatePickerDayView

#pragma mark - Properties

+ (nonnull NSString *)reuseIdentifier {
    return NSStringFromClass([TCNDatePickerDayView class]);
}

#pragma mark - Initialization

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    _dayOfWeekLabel = [TCNDatePickerDayView labelWithDayView:self];
    _dateLabel = [TCNDatePickerDayView labelWithDayView:self];

    return self;
}

#pragma mark - Class methods

+ (nonnull UILabel *)labelWithDayView:(nonnull TCNDatePickerDayView *)dayView {
    UILabel *const label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    [dayView.contentView addSubview:label];
    return label;
}

#pragma mark - View lifecycle

- (void)prepareForReuse {
    [super prepareForReuse];

    self.dayOfWeekLabel.text = @"";
    self.dateLabel.text = @"";
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;

    self.dayOfWeekLabel.frame = CGRectMake(0, 4, width, 15);

    CGFloat dayOfWeekBottom = self.dayOfWeekLabel.frame.size.height + self.dayOfWeekLabel.frame.origin.y;
    self.dateLabel.frame = CGRectMake(0, dayOfWeekBottom, width, height - dayOfWeekBottom);
}

- (void)setDate:(NSDate *)date {
    _date = date;
    self.dayOfWeekLabel.text = [TCNDateFormatter.dayOfWeekFormatter stringFromDate:self.date];

    NSString *const dateString = [TCNDateFormatter.dayOfMonthFormatter stringFromDate:self.date];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", dateString];
}

# pragma mark - LIDatePickerConfigurable

- (void)applyStylingFromConfig:(TCNDatePickerConfig *)config selected:(BOOL)selected {
    self.dayOfWeekLabel.font = config.secondaryFont;
    self.dateLabel.font = config.primaryFont;

    UIColor *const unselectedColor = [[NSCalendar currentCalendar] isDateInWeekend:self.date] ? config.weekendTextColor : config.textColor;

    self.dayOfWeekLabel.textColor = selected ? config.selectedTextColor : unselectedColor;
    self.dateLabel.textColor = selected ? config.selectedTextColor : unselectedColor;
}

@end
