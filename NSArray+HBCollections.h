#import <Foundation/Foundation.h>
#import "HBCollection.h"

@interface NSArray(HBCollections)<HBCollection>

- (id) hb_reduceRightUsingBlock:(id (^)(id previousObj, id obj)) block 
				andInitialValue:(id) initialValue;

@end
