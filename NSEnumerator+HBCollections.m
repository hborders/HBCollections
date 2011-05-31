#import "NSEnumerator+HBCollections.h"
#import "HBMapFilterOrBreakEnumerator.h"

@implementation NSEnumerator(HBCollections)

- (NSEnumerator *) hb_enumeratorUsingBlock:(void (^)(id obj)) block {	
	HBMapFilterOrBreakBlock plainMapFilterOrBreakBlock =
		[[^(id obj, 
			id *mappedObjPtr,
			BOOL *shouldFilterPtr, 
			BOOL *shouldBreakPtr) {
			block(obj);
			*mappedObjPtr = obj;
			*shouldFilterPtr = YES;
			*shouldBreakPtr = NO;
		} copy] autorelease];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:plainMapFilterOrBreakBlock];
	} else {
		return [[[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
																 andMapFilterOrBreakBlocks:[NSArray arrayWithObjects:
																							plainMapFilterOrBreakBlock,
																							nil]] autorelease];
	}
}

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block {
	HBMapFilterOrBreakBlock mapMapFilterOrBreakBlock =
		[[^(id obj, 
			id *mappedObjPtr,
			BOOL *shouldFilterPtr, 
			BOOL *shouldBreakPtr) {
			*mappedObjPtr = block(obj);
			*shouldFilterPtr = YES;
			*shouldBreakPtr = NO;
		} copy] autorelease];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:mapMapFilterOrBreakBlock];
	} else {
		return [[[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
																 andMapFilterOrBreakBlocks:[NSArray arrayWithObjects:
																							mapMapFilterOrBreakBlock,
																							nil]] autorelease];
	}
}

- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	HBMapFilterOrBreakBlock filterMapFilterOrBreakBlock =
		[[^(id obj, 
			id *mappedObjPtr,
			BOOL *shouldFilterPtr, 
			BOOL *shouldBreakPtr) {
			*mappedObjPtr = obj;
			*shouldFilterPtr = block(obj);
			*shouldBreakPtr = NO;
		} copy] autorelease];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:filterMapFilterOrBreakBlock];
	} else {
		return [[[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
																 andMapFilterOrBreakBlocks:[NSArray arrayWithObjects:
																							filterMapFilterOrBreakBlock,
																							nil]] autorelease];
	}
}

- (NSEnumerator *) hb_breakEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	HBMapFilterOrBreakBlock breakMapFilterOrBreakBlock =
		[[^(id obj, 
			id *mappedObjPtr,
			BOOL *shouldFilterPtr, 
			BOOL *shouldBreakPtr) {
			*mappedObjPtr = obj;
			*shouldFilterPtr = YES;
			*shouldBreakPtr = block(obj);
		} copy] autorelease];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:breakMapFilterOrBreakBlock];
	} else {
		return [[[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
																 andMapFilterOrBreakBlocks:[NSArray arrayWithObjects:
																							breakMapFilterOrBreakBlock,
																							nil]] autorelease];
	}
}

- (void) hb_enumerate {
	for (id obj in self);
}

- (NSSet *) hb_allObjectsAsSet {
	return [self hb_allObjectsAsMutableSet];
}

- (NSMutableSet *) hb_allObjectsAsMutableSet {
	NSMutableSet *allObjects;
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		allObjects = [NSMutableSet setWithCapacity:selfMapFilterOrBreakEnumerator.hb_allObjectsSizeHint];
	} else {
		allObjects = [NSMutableSet set];
	}
	
	for (id obj in self) {
		[allObjects addObject:obj];
	}
	
	return allObjects;
}

- (NSMutableArray *) hb_allObjectsAsMutableArray {
	NSMutableArray *allObjects;
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		allObjects = [NSMutableArray arrayWithCapacity:selfMapFilterOrBreakEnumerator.hb_allObjectsSizeHint];
	} else {
		allObjects = [NSMutableArray array];
	}
	
	for (id obj in self) {
		[allObjects addObject:obj];
	}
	
	return allObjects;
}

- (NSDictionary *) hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block {
	return [self hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:block];	
}

- (NSMutableDictionary *) hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block {
	NSMutableDictionary *allObjects;
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		allObjects = [NSMutableDictionary dictionaryWithCapacity:selfMapFilterOrBreakEnumerator.hb_allObjectsSizeHint];
	} else {
		allObjects = [NSMutableDictionary dictionary];
	}
	
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
	NSMutableDictionary *allObjects;
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		allObjects = [NSMutableDictionary dictionaryWithCapacity:selfMapFilterOrBreakEnumerator.hb_allObjectsSizeHint];
	} else {
		allObjects = [NSMutableDictionary dictionary];
	}
	
	for (id obj in self) {
		[allObjects setObject:obj
					   forKey:block(obj)];
	}
	
	return allObjects;
}

@end

