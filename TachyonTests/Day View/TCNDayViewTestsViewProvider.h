#import <Foundation/Foundation.h>

#import "TCNDayView.h"

@class TCNEvent;
@protocol LYTViewProvider;

/**
 This class implements LYTViewProvider and TCNDayViewDataSource, and is responsible for providing views compatible with
 the LayoutTest framework.
 */
@interface TCNDayViewTestsViewProvider : NSObject <LYTViewProvider, TCNDayViewDataSource>

@property (nonatomic, strong, class, nonnull, readonly) TCNDayViewTestsViewProvider *sharedInstance;
@property (nonatomic, strong, nonnull, readwrite) NSArray<TCNEvent *> *events;

@end
