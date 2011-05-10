#import "NSEnumerator+HBCollections.h"

@interface HBMapEnumerator : NSEnumerator {
}

- (id) initWithMapeeEnumerator: (NSEnumerator *) mapeeEnumerator 
					  andBlock: (id (^)(id obj)) block;

@end

@interface HBFilterEnumerator : NSEnumerator {
}

- (id) initWithFiltereeEnumerator: (NSEnumerator *) filtereeEnumerator 
						 andBlock: (BOOL (^)(id obj)) block;

@end

@interface HBBreakEnumerator : NSEnumerator {
}

- (id) initWithBreakeeEnumerator: (NSEnumerator *) breakeeEnumerator
						andBlock: (BOOL (^)(id)) block;

@end

@implementation NSEnumerator(HBCollections)

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block {
	return [[[HBMapEnumerator alloc] initWithMapeeEnumerator:self
													andBlock:block] autorelease];
}

- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	return [[[HBFilterEnumerator alloc] initWithFiltereeEnumerator:self
														  andBlock:block] autorelease];
}

- (NSEnumerator *) hb_breakEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	return [[[HBBreakEnumerator alloc] initWithBreakeeEnumerator:self
														andBlock:block] autorelease];
}

@end

@interface HBMapEnumerator()

@property (nonatomic, retain) NSEnumerator *mapeeEnumerator;
@property (nonatomic, copy) id (^block)(id obj);
@property (nonatomic) id *mapeeItemsPtr;
@property (nonatomic) NSUInteger mapeeItemsIndex;
@property (nonatomic) NSUInteger mapeeItemsCount;

@end


@implementation HBMapEnumerator

@synthesize mapeeEnumerator = _mapeeEnumerator;
@synthesize block = _block;
@synthesize mapeeItemsPtr = _mapeeItemsPtr;
@synthesize mapeeItemsIndex = _mapeeItemsIndex;
@synthesize mapeeItemsCount = _mapeeItemsCount;

#pragma mark -
#pragma mark init/dealloc

- (id) initWithMapeeEnumerator: (NSEnumerator *) mapeeEnumerator 
					  andBlock: (id (^)(id obj)) block {
	if (self = [super init]) {
		_mapeeEnumerator = [mapeeEnumerator retain];
		_block = [block copy];
	}
	
	return self;
}

- (void) dealloc {
	[_mapeeEnumerator release];
	[_block release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSEnumerator

- (NSArray *) allObjects {
	NSArray *allObjects = [_mapeeEnumerator allObjects];
	NSMutableArray *mappedObjects = [NSMutableArray arrayWithCapacity:[allObjects count]];
	for (id obj in allObjects) {
		[mappedObjects addObject:_block(obj)];
	}
	return mappedObjects;
}

- (id) nextObject {
	id nextObject = [_mapeeEnumerator nextObject];
	if (nextObject) {
		return _block(nextObject);
	} else {
		return nil;
	}
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	if (_mapeeItemsIndex < _mapeeItemsCount) {
		const NSUInteger count = MIN(len, _mapeeItemsCount - _mapeeItemsIndex);
		state->itemsPtr = stackbuf;
		for (NSUInteger i = 0; i < count; i++) {
			stackbuf[i] = _block(_mapeeItemsPtr[_mapeeItemsIndex + i]);
		}
		_mapeeItemsIndex += count;
		
		return count;
	} else {
		if (_mapeeItemsPtr) {
			state->itemsPtr = _mapeeItemsPtr;
			_mapeeItemsPtr = NULL;
			_mapeeItemsIndex = 0;
			_mapeeItemsCount = 0;
		}
		
		NSUInteger count = [_mapeeEnumerator countByEnumeratingWithState:state
																 objects:stackbuf
																   count:len];
		if (state->itemsPtr == stackbuf) {
			for (NSUInteger i = 0; i < count; i++) {
				stackbuf[i] = _block(stackbuf[i]);
			}
			
			return count;
		} else if (len < count) {
			_mapeeItemsPtr = state->itemsPtr;
			_mapeeItemsIndex = len;
			_mapeeItemsCount = count;
			state->itemsPtr = stackbuf;
			
			for (NSUInteger i=0; i < len; i++) {
				stackbuf[i] = _block(_mapeeItemsPtr[i]);
			}
			
			return len;
		} else {
			_mapeeItemsPtr = state->itemsPtr;
			_mapeeItemsIndex = count;
			_mapeeItemsCount = count;
			state->itemsPtr = stackbuf;
			
			for (NSUInteger i = 0; i < count; i++) {
				stackbuf[i] = _block(_mapeeItemsPtr[i]);
			}
			
			return count;
		}
	}
}

@end

@interface HBFilterEnumerator()

@property (nonatomic, retain) NSEnumerator *filtereeEnumerator;
@property (nonatomic, copy) BOOL (^block)(id);
@property (nonatomic) id *filtereeItemsPtr;
@property (nonatomic) NSUInteger filtereeItemsIndex;
@property (nonatomic) NSUInteger filtereeItemsCount;

@end


@implementation HBFilterEnumerator

@synthesize filtereeEnumerator = _filtereeEnumerator;
@synthesize block = _block;
@synthesize filtereeItemsPtr = _filtereeItemsPtr;
@synthesize filtereeItemsIndex = _filtereeItemsIndex;
@synthesize filtereeItemsCount = _filtereeItemsCount;

#pragma mark -
#pragma mark init/dealloc

- (id) initWithFiltereeEnumerator: (NSEnumerator *) filtereeEnumerator 
						 andBlock: (BOOL (^)(id obj)) block {
	if (self = [super init]) {
		_filtereeEnumerator = [filtereeEnumerator retain];
		_block = [block copy];
	}
	
	return self;
}

- (void) dealloc {
	[_filtereeEnumerator release];
	[_block release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSEnumerator

- (NSArray *) allObjects {
	NSArray *allObjects = [_filtereeEnumerator allObjects];
	NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[allObjects count]];
	for (id obj in allObjects) {
		if (_block(obj)) {
			[filteredObjects addObject:obj];	
		}
	}
	return filteredObjects;
}

- (id) nextObject {
	id nextObject;
	while (nextObject = [_filtereeEnumerator nextObject]) {
		if (_block(nextObject)) {
			return nextObject;	
		}
	}
	return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	NSUInteger count = 0;
	NSUInteger filteredItemsCount = 0;
	do {
		if (_filtereeItemsPtr && (_filtereeItemsIndex < _filtereeItemsCount)) {
			count = MIN(len, _filtereeItemsCount - _filtereeItemsIndex);
			state->itemsPtr = stackbuf;
			for (NSUInteger i = 0; i < count; i++) {
				if (_block(_filtereeItemsPtr[_filtereeItemsIndex + i])) {
					stackbuf[filteredItemsCount] = _filtereeItemsPtr[_filtereeItemsIndex + i];
					filteredItemsCount++;
				}
			}
			_filtereeItemsIndex += count;
		} else {
			if (_filtereeItemsPtr) {
				state->itemsPtr = _filtereeItemsPtr;
				_filtereeItemsPtr = NULL;
				_filtereeItemsIndex = 0;
				_filtereeItemsCount = 0;
			}
			
			count = [_filtereeEnumerator countByEnumeratingWithState:state
															 objects:stackbuf
															   count:len];
			if (state->itemsPtr == stackbuf) {
				for (NSUInteger i = 0; i < count; i++) {
					if (_block(stackbuf[i])) {
						stackbuf[filteredItemsCount] = stackbuf[i];
						filteredItemsCount++;
					}
				}
			} else if (len < count) {
				_filtereeItemsPtr = state->itemsPtr;
				_filtereeItemsIndex = len;
				_filtereeItemsCount = count;
				state->itemsPtr = stackbuf;
				
				for (NSUInteger i=0; i < len; i++) {
					if (_block(_filtereeItemsPtr[i])) {
						stackbuf[filteredItemsCount] = _filtereeItemsPtr[i];
						filteredItemsCount++;
					}
				}
			} else {
				_filtereeItemsPtr = state->itemsPtr;
				_filtereeItemsIndex = count;
				_filtereeItemsCount = count;
				state->itemsPtr = stackbuf;
				
				for (NSUInteger i = 0; i < count; i++) {
					if (_block(_filtereeItemsPtr[i])) {
						stackbuf[filteredItemsCount] = _filtereeItemsPtr[i];
						filteredItemsCount++;
					}
				}
			}
		}
	} while ((filteredItemsCount == 0) && (count != 0));
	
	return filteredItemsCount;
}

@end

@interface HBBreakEnumerator()

@property (nonatomic, retain) NSEnumerator *breakeeEnumerator;
@property (nonatomic, copy) BOOL (^block)(id);

@end

@implementation HBBreakEnumerator

@synthesize breakeeEnumerator = _breakeeEnumerator;
@synthesize block = _block;

- (id) initWithBreakeeEnumerator: (NSEnumerator *) breakeeEnumerator
						andBlock: (BOOL (^)(id)) block {
	if (self = [super init]) {
		_breakeeEnumerator = [breakeeEnumerator retain];
		_block = [block copy];
	}
	
	return self;
}

- (void) dealloc {
	[_breakeeEnumerator release];
	[_block release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSEnumerator

- (NSArray *) allObjects {
	NSArray *allObjects = [_breakeeEnumerator allObjects];
	NSMutableArray *breakedObjects = [NSMutableArray arrayWithCapacity:[allObjects count]];
	for (id obj in allObjects) {
		if (_block(obj)) {
			break;
		} else {
			[breakedObjects addObject:obj];	
		}
	}
	return breakedObjects;
}

- (id) nextObject {
	id nextObject = [_breakeeEnumerator nextObject];
	
	if (_block(nextObject)) {
		return nil;
	} else {
		return nextObject;
	}
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	NSUInteger breakeeCount = [_breakeeEnumerator countByEnumeratingWithState:state
																	  objects:stackbuf
																		count:len];
	NSUInteger count = 0;
	
	while (count < breakeeCount) {
		if (_block(state->itemsPtr[count])) {
			break;
		} else {
			count++;
		}
	}
	
	return count;
}

@end
