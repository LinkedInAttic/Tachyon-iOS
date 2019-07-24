#import "TCNEventCell.h"
#import "TCNViewUtils.h"

@interface TCNEventCell ()

@property (nonatomic, strong, nonnull, readonly) UILabel *titleLabel;
@property (nonatomic, strong, nonnull, readonly) UILabel *timeLabel;
@property (nonatomic, strong, nonnull, readonly) UIButton *cancelButton;
@property (nonatomic, strong, nonnull, readonly) CAShapeLayer *roundedCornerMask;

/**
 If true, this event will display as a single line without a time label.
 Default NO.
 */
@property (nonatomic, assign, readwrite) BOOL useCompactDisplay;

@end

@implementation TCNEventCell

static const CGFloat SidePadding = 8.0f;
static const CGFloat TopPadding = 4.0f;
static const CGFloat CancelButtonDimension = 48.0f;
static const CGFloat CancelButtonImageDimension = 16.0f;
static const NSInteger CornerRadius = 2.0f;

+ (nonnull NSString *)reuseIdentifier {
    return NSStringFromClass([TCNEventCell class]);
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    _useCompactDisplay = NO;
    _titleLabel = [TCNEventCell labelWithSuperview:self];
    _timeLabel = [TCNEventCell labelWithSuperview:self];
    _cancelButton = [TCNEventCell cancelButtonWithSuperview:self];
    [TCNEventCell configureBaseView:self];

    return self;
}

- (void)setUseCompactDisplay:(BOOL)useCompactDisplay {
    _useCompactDisplay = useCompactDisplay;
    self.titleLabel.numberOfLines = useCompactDisplay ? 1 : 0;
    self.timeLabel.numberOfLines = useCompactDisplay ? 1 : 0;
}

#pragma mark - Class helpers

+ (nonnull UILabel *)labelWithSuperview:(nonnull UICollectionViewCell *)superview {
    UILabel *const label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentNatural;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    [superview.contentView addSubview:label];
    return label;
}

+ (nonnull UIButton *)cancelButtonWithSuperview:(nonnull UICollectionViewCell *)superview {
    UIButton *const button = [[UIButton alloc] init];
    [superview.contentView addSubview:button];
    return button;
}

+ (void)configureBaseView:(nonnull UIView *)view {
    view.layer.masksToBounds = YES;
}

#pragma mark - View lifecycle

- (void)layoutSubviews {
    [super layoutSubviews];

    self.layer.cornerRadius = CornerRadius;

    self.titleLabel.frame = CGRectMake(
       SidePadding,
       TopPadding,
       self.bounds.size.width - (2 * SidePadding),
       self.bounds.size.height - (2 * TopPadding));

    if (!self.useCompactDisplay) {
        [self.titleLabel sizeToFit];

        // We can't allow the titleLabel's frame to exceed that of the cell itself, or it will not truncate correctly.
        self.titleLabel.frame = CGRectMake(
            self.titleLabel.frame.origin.x,
            self.titleLabel.frame.origin.y,
            self.titleLabel.frame.size.width,
            MIN(self.frame.size.height, self.titleLabel.frame.size.height));
    }

    if (self.useCompactDisplay) {
        self.timeLabel.frame = CGRectZero;
    } else {
        const CGFloat titleLabelMaxY = TopPadding + self.titleLabel.frame.size.height;
        self.timeLabel.frame = CGRectMake(
            SidePadding,
            titleLabelMaxY,
            self.bounds.size.width - (2 * SidePadding),
            self.timeLabel.font.lineHeight);
    }

    const CGFloat insetDimension = CancelButtonDimension - CancelButtonImageDimension;

    if (self.cancelButton.currentImage) {
        self.cancelButton.frame = CGRectMake(
            self.bounds.size.width - SidePadding - insetDimension,
            (self.bounds.size.height - CancelButtonDimension) / 2,
            CancelButtonDimension,
            CancelButtonDimension);

        self.cancelButton.imageEdgeInsets = UIEdgeInsetsMake(insetDimension, insetDimension, insetDimension, insetDimension);
    }

    [TCNViewUtils layoutSubviewsForRTL:self];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.titleLabel.text = @"";
    self.timeLabel.text = @"";
}

- (void)updateWithEvent:(nonnull TCNEvent *)event {
    self.titleLabel.text = event.name;
    self.timeLabel.text = event.displayTimeString;
    self.useCompactDisplay = event.isAllDay;

    [self setNeedsLayout];
}

#pragma mark - Methods and Property Overrides

- (void)setCancelHandler:(void (^_Nullable)(void))cancelHandler {
    _cancelHandler = cancelHandler;
    if (cancelHandler) {
        [self.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)cancelButtonTapped {
    if (self.cancelHandler) {
        self.cancelHandler();
    }
}

# pragma mark - TCNDayViewConfigurable

- (void)applyStylingFromConfig:(nonnull TCNDayViewConfig *)config selected:(BOOL)selected {
    self.contentView.backgroundColor = selected ? config.selectedEventColor : config.eventColor;
    self.titleLabel.textColor = selected ? config.selectedEventTextColor : config.eventTextColor;
    self.titleLabel.font = config.eventFont;

    self.timeLabel.textColor = selected ? config.selectedEventTextColor : config.eventTextColor;
    self.timeLabel.font = config.eventFont;

    self.cancelButton.tintColor = config.selectedEventTextColor;

    self.timeLabel.hidden = !selected;
    self.cancelButton.hidden = !(selected && config.shouldShowCancelButtonOnCreatedEvents);

    UIImage *const image = [config.cancelButtonImage imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
    if (image) {
        [self.cancelButton setImage:image forState:UIControlStateNormal];
    }
}

@end
