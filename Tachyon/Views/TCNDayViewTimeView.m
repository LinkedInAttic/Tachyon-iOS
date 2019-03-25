#import "TCNDayViewTimeView.h"
#import "TCNDateFormatter.h"

@interface TCNDayViewTimeView ()

@property (nonatomic, strong, nonnull) UILabel *titleLabel;
@property (nonatomic, copy, nullable) NSString *allDayText;

@end

@implementation TCNDayViewTimeView

static const UIEdgeInsets Padding = {0.0f, 10.0f, 0.0f, 10.0f};

+ (nonnull NSString *)reuseIdentifier {
    return NSStringFromClass([TCNDayViewTimeView class]);
}

#pragma mark - Initialization

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    _titleLabel = [TCNDayViewTimeView labelWithSuperview:self];
    _time = [NSDate date];
    return self;
}

#pragma mark - Class helpers

+ (nonnull UILabel *)labelWithSuperview:(nonnull UIView *)superview {
    UILabel *const label = [[UILabel alloc] init];
    label.adjustsFontSizeToFitWidth = YES;
    label.textAlignment = NSTextAlignmentRight;
    [superview addSubview:label];
    return label;
}

#pragma mark - View lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect bounds = self.bounds;
    CGRect titleFrame = CGRectMake(Padding.left, 0, bounds.size.width - Padding.right - Padding.left, bounds.size.height);
    self.titleLabel.frame = titleFrame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = @"";
}

- (void)setTime:(nonnull NSDate *)time {
    _time = time;

    self.titleLabel.text = [TCNDateFormatter.sidebarTimeFormatter stringFromDate:time];
}

- (void)updateAllDayEventText {
    self.titleLabel.text = self.allDayText;
}

# pragma mark - TCNDayViewConfigurable

- (void)applyStylingFromConfig:(TCNDayViewConfig *)config selected:(__unused BOOL)selected {
    self.backgroundColor = config.sidebarColor;
    self.titleLabel.textColor = config.sidebarTextColor;
    self.titleLabel.font = config.sidebarFont;
    self.allDayText = config.allDayLabelText;
}

@end
