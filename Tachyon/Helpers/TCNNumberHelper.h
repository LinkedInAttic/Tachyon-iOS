#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Static helpers for number operations involving CGFloat, which differs between 32-bit and 64-bit architectures.
 */
@interface TCNNumberHelper : NSObject

+ (CGFloat)ceil:(CGFloat)value;

+ (CGFloat)floor:(CGFloat)value;

+ (CGFloat)mod:(CGFloat)valueOne by:(CGFloat)valueTwo;

@end
