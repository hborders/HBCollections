#import "NSSet+HBCollections.h"
#import "NSEnumerator+HBCollections.h"
#import "HBMapFilterOrBreakEnumerator.h"

@implementation NSSet(HBCollections)

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block {
	HBMapFilterOrBreakEnumerator *mapMapFilterOrBreakEnumerator =
		(HBMapFilterOrBreakEnumerator *) [[self objectEnumerator] hb_mapEnumeratorUsingBlock:block];
	mapMapFilterOrBreakEnumerator.hb_allObjectsSizeHint = [self count];
	
	return mapMapFilterOrBreakEnumerator;
}

- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	HBMapFilterOrBreakEnumerator *filterMapFilterOrBreakEnumerator =
		(HBMapFilterOrBreakEnumerator *) [[self objectEnumerator] hb_filterEnumeratorUsingBlock:block];
	filterMapFilterOrBreakEnumerator.hb_allObjectsSizeHint = [self count];
	
	return filterMapFilterOrBreakEnumerator;
}

- (NSEnumerator *) hb_breakEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	HBMapFilterOrBreakEnumerator *breakMapFilterOrBreakEnumerator =
		(HBMapFilterOrBreakEnumerator *) [[self objectEnumerator] hb_breakEnumeratorUsingBlock:block];
	breakMapFilterOrBreakEnumerator.hb_allObjectsSizeHint = [self count];
	
	return breakMapFilterOrBreakEnumerator;
}

- (NSDictionary *) hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block {
	return [self hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:block];	
}

- (NSMutableDictionary *) hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block {
	NSMutableDictionary *allObjects = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	
	for (id obj in self) {
		[allObjects setObject:block(obj) 
					   forKey:obj];
	}
	
	return allObjects;
}

- (NSDictionary *) hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:(id (^)(id valueObj)) block {
	return [self hb_allObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock:block];	
}

- (NSMutableDictionary *) hb_allObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock:(id (^)(id valueObj)) block {
	NSMutableDictionary *allObjects = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	
	for (id obj in self) {
		[allObjects setObject:obj
					   forKey:block(obj)];
	}
	
	return allObjects;
}

@end
