//  NSMutableArray+Additions.h

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#include <Cocoa/Cocoa.h>
#endif

// This category enhances NSMutableArray by providing additional methods
@interface NSMutableArray (Additions)
// methods to randomly shuffle the elements.
- (void)shuffle;
@end