#import <Foundation/Foundation.h>
#import "HBCollection.h"

@interface NSEnumerator(HBCollections)<HBCollection>

- (NSSet *) hb_allObjectsAsSet;
- (NSMutableSet *) hb_allObjectsAsMutableSet;

- (NSMutableArray *) hb_allObjectsAsMutableArray;

@end
