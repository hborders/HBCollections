#import <Foundation/Foundation.h>

@interface NSEnumerator(HBCollections)

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block;
- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj, BOOL *stop)) block;

@end
