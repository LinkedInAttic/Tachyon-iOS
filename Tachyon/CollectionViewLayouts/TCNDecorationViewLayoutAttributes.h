#import <UIKit/UIKit.h>

/**
 A subclass of @c UICollectionViewLayoutAttributes that holds custom attributes for decoration views.
 */
@interface TCNDecorationViewLayoutAttributes : UICollectionViewLayoutAttributes

/**
 The background color for a decoration view.
 */
@property (nonatomic, strong, nullable, readwrite) UIColor *backgroundColor;

@end
