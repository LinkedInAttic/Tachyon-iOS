#import <Foundation/Foundation.h>
#import "TCNDayViewLayout.h"

@interface TCNDayViewLayout (Protected)

/**
 Retrieves the target @c zIndex for an element of the given @c elementKind type.

 @param elementKind A string identifier corresponding to a collection view element type.
 @return An integer representing the zIndex.
 */
- (NSInteger)zIndexForElementKind:(nonnull NSString *)elementKind;

@end
