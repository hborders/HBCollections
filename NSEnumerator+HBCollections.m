#import "NSEnumerator+HBCollections.h"

typedef void (^HBMapFilterOrBreakBlock)(id obj, 
										id *mappedObjPtr,
										BOOL *shouldFilterPtr, 
										BOOL *shouldBreakPtr);

@interface HBMapFilterOrBreakEnumerator : NSEnumerator {
}

- (id) initWithMapFilterOrBreakeeEnumerator: (NSEnumerator *) mapFilterOrBreakeeEnumerator
				  andMapFilterOrBreakBlocks: (NSArray *) mapFilterOrBreakBlocks;

- (HBMapFilterOrBreakEnumerator *) hb_addMapFilterOrBreakBlock: (HBMapFilterOrBreakBlock) mapFilterOrBreakBlock;

@end


@implementation NSEnumerator(HBCollections)

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

@end

@interface NSArray(HBMapFilterOrBreakBlock)

- (void) hb_map: (id *) mappedObjectPtr
		 filter: (BOOL *) shouldFilterPtr
		orBreak: (BOOL *) shouldBreakPtr
		 object: (id) obj;

@end


@interface HBMapFilterOrBreakEnumerator()

@property (nonatomic, retain) NSEnumerator *mapFilterOrBreakeeEnumerator;
@property (nonatomic, retain) NSArray *mapFilterOrBreakBlocks;

@property (nonatomic) id *mapFilterOrBreakeeItemsPtr;
@property (nonatomic) NSUInteger mapFilterOrBreakeeItemsIndex;
@property (nonatomic) NSUInteger mapFilterOrBreakeeItemsCount;
@property (nonatomic) BOOL mapFilterOrBreakItemsBroken;

@end


@implementation HBMapFilterOrBreakEnumerator

@synthesize mapFilterOrBreakeeEnumerator = _mapFilterOrBreakeeEnumerator;
@synthesize mapFilterOrBreakBlocks = _mapFilterOrBreakBlocks;

@synthesize mapFilterOrBreakeeItemsPtr = _mapFilterOrBreakeeItemsPtr;
@synthesize mapFilterOrBreakeeItemsIndex = _mapFilterOrBreakeeItemsIndex;
@synthesize mapFilterOrBreakeeItemsCount = _mapFilterOrBreakeeItemsCount;
@synthesize mapFilterOrBreakItemsBroken = _mapFilterOrBreakItemsBroken;


- (id) initWithMapFilterOrBreakeeEnumerator: (NSEnumerator *) mapFilterOrBreakeeEnumerator
				  andMapFilterOrBreakBlocks: (NSArray *) mapFilterOrBreakBlocks {
	self = [super init];
	if (self) {
		self.mapFilterOrBreakeeEnumerator = mapFilterOrBreakeeEnumerator;
		self.mapFilterOrBreakBlocks = mapFilterOrBreakBlocks;
	}
	
	return self;
}

- (void) dealloc {
	self.mapFilterOrBreakeeEnumerator = nil;
	self.mapFilterOrBreakBlocks = nil;
	
	self.mapFilterOrBreakeeItemsPtr = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark public API

- (HBMapFilterOrBreakEnumerator *) hb_addMapFilterOrBreakBlock: (HBMapFilterOrBreakBlock) mapFilterOrBreakBlock {
	NSArray *newMapFilterOrBreakBlocks = [self.mapFilterOrBreakBlocks arrayByAddingObject:mapFilterOrBreakBlock];
	return [[[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self.mapFilterOrBreakeeEnumerator
															 andMapFilterOrBreakBlocks:newMapFilterOrBreakBlocks] autorelease];
}

#pragma mark -
#pragma mark NSEnumerator

- (NSArray *) allObjects {
	NSArray *allObjects = [self.mapFilterOrBreakeeEnumerator allObjects];
	NSMutableArray *mappedObjects = [NSMutableArray arrayWithCapacity:[allObjects count]];
	for (id obj in allObjects) {
		id mappedObj;
		BOOL shouldFilter;
		BOOL shouldBreak;
		[self.mapFilterOrBreakBlocks hb_map:&mappedObj
									 filter:&shouldFilter
									orBreak:&shouldBreak
									 object:obj];
		if (shouldBreak) {
			break;
		} else if (shouldFilter) {
			[mappedObjects addObject:mappedObj];
		}
	}
	return mappedObjects;
}

- (id) nextObject {
	id nextObject;
	while (nextObject = [self.mapFilterOrBreakeeEnumerator nextObject]) {
		id mappedObj;
		BOOL shouldFilter;
		BOOL shouldBreak;
		[self.mapFilterOrBreakBlocks hb_map:&mappedObj
									 filter:&shouldFilter
									orBreak:&shouldBreak
									 object:nextObject];
		if (shouldBreak) {
			return nil;
		} else if (shouldFilter) {
			return mappedObj;
		}
	}
	return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	if (self.mapFilterOrBreakItemsBroken) {
		return 0;
	} else {
		NSUInteger count = 0;
		NSUInteger filteredItemsCount = 0;
		do {
			if (self.mapFilterOrBreakeeItemsPtr && 
				(self.mapFilterOrBreakeeItemsIndex < self.mapFilterOrBreakeeItemsCount)) {
				count = MIN(len, self.mapFilterOrBreakeeItemsCount - self.mapFilterOrBreakeeItemsIndex);
				state->itemsPtr = stackbuf;
				for (NSUInteger i = 0; i < count; i++) {
					id obj = self.mapFilterOrBreakeeItemsPtr[self.mapFilterOrBreakeeItemsIndex + i];
					id mappedObj;
					BOOL shouldFilter;
					BOOL shouldBreak;
					[self.mapFilterOrBreakBlocks hb_map:&mappedObj
												 filter:&shouldFilter
												orBreak:&shouldBreak
												 object:obj];
					if (shouldBreak) {
						self.mapFilterOrBreakItemsBroken = YES;
						break;
					} else if (shouldFilter) {
						stackbuf[filteredItemsCount] = mappedObj;
						filteredItemsCount++;
					}
				}
				self.mapFilterOrBreakeeItemsIndex += count;
			} else {
				if (self.mapFilterOrBreakeeItemsPtr) {
					state->itemsPtr = self.mapFilterOrBreakeeItemsPtr;
					self.mapFilterOrBreakeeItemsPtr = NULL;
					self.mapFilterOrBreakeeItemsIndex = 0;
					self.mapFilterOrBreakeeItemsCount = 0;
				}
				
				count = [self.mapFilterOrBreakeeEnumerator countByEnumeratingWithState:state
																			   objects:stackbuf
																				 count:len];
				if (state->itemsPtr == stackbuf) {
					for (NSUInteger i = 0; i < count; i++) {
						id obj = stackbuf[i];
						id mappedObj;
						BOOL shouldFilter;
						BOOL shouldBreak;
						[self.mapFilterOrBreakBlocks hb_map:&mappedObj
													 filter:&shouldFilter
													orBreak:&shouldBreak
													 object:obj];
						if (shouldBreak) {
							self.mapFilterOrBreakItemsBroken = YES;
							break;
						} else if (shouldFilter) {
							stackbuf[filteredItemsCount] = mappedObj;
							filteredItemsCount++;
						}
					}
				} else if (len < count) {
					self.mapFilterOrBreakeeItemsPtr = state->itemsPtr;
					self.mapFilterOrBreakeeItemsIndex = len;
					self.mapFilterOrBreakeeItemsCount = count;
					state->itemsPtr = stackbuf;
					
					for (NSUInteger i=0; i < len; i++) {
						id obj = self.mapFilterOrBreakeeItemsPtr[i];
						id mappedObj;
						BOOL shouldFilter;
						BOOL shouldBreak;
						[self.mapFilterOrBreakBlocks hb_map:&mappedObj
													 filter:&shouldFilter
													orBreak:&shouldBreak
													 object:obj];
						if (shouldBreak) {
							self.mapFilterOrBreakItemsBroken = YES;
							break;
						} else if (shouldFilter) {
							stackbuf[filteredItemsCount] = mappedObj;
							filteredItemsCount++;
						}
					}
				} else {
					self.mapFilterOrBreakeeItemsPtr = state->itemsPtr;
					self.mapFilterOrBreakeeItemsIndex = count;
					self.mapFilterOrBreakeeItemsCount = count;
					state->itemsPtr = stackbuf;
					
					for (NSUInteger i = 0; i < count; i++) {
						id obj = self.mapFilterOrBreakeeItemsPtr[i];
						id mappedObj;
						BOOL shouldFilter;
						BOOL shouldBreak;
						[self.mapFilterOrBreakBlocks hb_map:&mappedObj
													 filter:&shouldFilter
													orBreak:&shouldBreak
													 object:obj];
						if (shouldBreak) {
							self.mapFilterOrBreakItemsBroken = YES;
							break;
						} else if (shouldFilter) {
							stackbuf[filteredItemsCount] = mappedObj;
							filteredItemsCount++;
						}
					}
				}
			}
		} while ((filteredItemsCount == 0) && 
				 (count != 0) &&
				 !self.mapFilterOrBreakItemsBroken);
		
		return filteredItemsCount;
	}
}

@end

@implementation NSArray(HBMapFilterOrBreakBlock)

- (void) hb_map: (id *) mappedObjectPtr
		 filter: (BOOL *) shouldFilterPtr
		orBreak: (BOOL *) shouldBreakPtr
		 object: (id) obj {
	id mappedObj = obj;
	id nextMappedObj;
	BOOL shouldFilter;
	BOOL shouldBreak;
	for (HBMapFilterOrBreakBlock mapFilterOrBreakBlock in self) {
		mapFilterOrBreakBlock(mappedObj, &nextMappedObj, &shouldFilter, &shouldBreak);
		if (shouldFilter && !shouldBreak) {
			mappedObj = nextMappedObj;
		} else {
			mappedObj = nil;
			break;
		}
	}
	*mappedObjectPtr = mappedObj;
	*shouldFilterPtr = shouldFilter;
	*shouldBreakPtr = shouldBreak;
}

@end