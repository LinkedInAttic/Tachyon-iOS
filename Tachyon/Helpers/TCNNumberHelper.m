#import "TCNNumberHelper.h"

@implementation TCNNumberHelper

+ (CGFloat)ceil:(CGFloat)value {
#ifdef __LP64__
    return ceil(value);
#else
    return ceilf(value);
#endif
}

+ (CGFloat)floor:(CGFloat)value {
#ifdef __LP64__
    return floor(value);
#else
    return floorf(value);
#endif
}

+ (CGFloat)mod:(CGFloat)valueOne by:(CGFloat)valueTwo {
#ifdef __LP64__
    return fmod(valueOne, valueTwo);
#else
    return fmodf(valueOne, valueTwo);
#endif
}

@end
