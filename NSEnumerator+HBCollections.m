#import "NSEnumerator+HBCollections.h"

@interface HBMapEnumerator : NSEnumerator

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
		self.mapeeEnumerator = mapeeEnumerator;
		self.block = block;
	}
	
	return self;
}

- (void) dealloc {
	self.mapeeEnumerator = nil;
	self.block = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSEnumerator

- (NSArray *) allObjects {
	NSArray *allObjects = [self.mapeeEnumerator allObjects];
	NSMutableArray *mappedObjects = [NSMutableArray arrayWithCapacity:[allObjects count]];
	for (id obj in allObjects) {
		[mappedObjects addObject:self.block(obj)];
	}
	return mappedObjects;
}

- (id) nextObject {
	id nextObject = [self.mapeeEnumerator nextObject];
	if (nextObject) {
		return self.block(nextObject);
	} else {
		return nil;
	}
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	if (self.mapeeItemsIndex < self.mapeeItemsCount) {
		const NSUInteger count = MIN(len, self.mapeeItemsCount - self.mapeeItemsIndex);
		state->itemsPtr = stackbuf;
		for (NSUInteger i = 0; i < count; i++) {
			stackbuf[i] = self.block(self.mapeeItemsPtr[self.mapeeItemsIndex + i]);
		}
		self.mapeeItemsIndex += count;
		
		return count;
	} else {
		if (self.mapeeItemsPtr) {
			state->itemsPtr = self.mapeeItemsPtr;
			self.mapeeItemsPtr = NULL;
			self.mapeeItemsIndex = 0;
			self.mapeeItemsCount = 0;
		}
		
		NSUInteger count = [self.mapeeEnumerator countByEnumeratingWithState:state
																	 objects:stackbuf
																	   count:len];
		if (state->itemsPtr == stackbuf) {
			for (NSUInteger i = 0; i < count; i++) {
				stackbuf[i] = self.block(stackbuf[i]);
			}
			
			return count;
		} else if (len < count) {
			self.mapeeItemsPtr = state->itemsPtr;
			self.mapeeItemsIndex = len;
			self.mapeeItemsCount = count;
			state->itemsPtr = stackbuf;
			
			for (NSUInteger i=0; i < len; i++) {
				stackbuf[i] = self.block(self.mapeeItemsPtr[i]);
			}
			
			return len;
		} else {
			self.mapeeItemsPtr = state->itemsPtr;
			self.mapeeItemsIndex = count;
			self.mapeeItemsCount = count;
			state->itemsPtr = stackbuf;
			
			for (NSUInteger i = 0; i < count; i++) {
				stackbuf[i] = self.block(self.mapeeItemsPtr[i]);
			}
			
			return count;
		}
	}
}

@end

@interface HBFilterEnumerator : NSEnumerator

@end

@interface HBFilterEnumerator()

@property (nonatomic, retain) NSEnumerator *filtereeEnumerator;
@property (nonatomic, copy) BOOL (^block)(id obj, BOOL *);
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
						 andBlock: (BOOL (^)(id, BOOL *)) block {
	if (self = [super init]) {
		self.filtereeEnumerator = filtereeEnumerator;
		self.block = block;
	}
	
	return self;
}

- (void) dealloc {
	self.filtereeEnumerator = nil;
	self.block = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSEnumerator

- (NSArray *) allObjects {
	NSArray *allObjects = [self.filtereeEnumerator allObjects];
	NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[allObjects count]];
	for (id obj in allObjects) {
		BOOL stop = NO;
		if (self.block(obj, &stop)) {
			[filteredObjects addObject:obj];	
		}
	}
	return filteredObjects;
}

- (id) nextObject {
	id nextObject;
	while (nextObject = [self.filtereeEnumerator nextObject]) {
		BOOL stop = NO;
		if (self.block(nextObject, &stop)) {
			return nextObject;	
		}
	}
	return nil;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	// breaking tests are caused by not continuing to iterate when all of the items in the filtereeEnumerator are filtered.
	NSUInteger count = 0;
	NSUInteger filteredItemsCount = 0;
	do {
		if (self.filtereeItemsIndex < self.filtereeItemsCount) {
			count = MIN(len, self.filtereeItemsCount - self.filtereeItemsIndex);
			state->itemsPtr = stackbuf;
			for (NSUInteger i = 0; i < count; i++) {
				BOOL stop = NO;
				if (self.block(self.filtereeItemsPtr[self.filtereeItemsIndex + i], &stop)) {
					stackbuf[filteredItemsCount] = self.filtereeItemsPtr[self.filtereeItemsIndex + i];
					filteredItemsCount++;
				}
			}
			self.filtereeItemsIndex += count;
		} else {
			if (self.filtereeItemsPtr) {
				state->itemsPtr = self.filtereeItemsPtr;
				self.filtereeItemsPtr = NULL;
				self.filtereeItemsIndex = 0;
				self.filtereeItemsCount = 0;
			}
			
			count = [self.filtereeEnumerator countByEnumeratingWithState:state
																 objects:stackbuf
																   count:len];
			if (state->itemsPtr == stackbuf) {
				for (NSUInteger i = 0; i < count; i++) {
					BOOL stop = NO;
					if (self.block(stackbuf[i], &stop)) {
						stackbuf[filteredItemsCount] = stackbuf[i];
						filteredItemsCount++;
					}
				}
			} else if (len < count) {
				self.filtereeItemsPtr = state->itemsPtr;
				self.filtereeItemsIndex = len;
				self.filtereeItemsCount = count;
				state->itemsPtr = stackbuf;
				
				for (NSUInteger i=0; i < len; i++) {
					BOOL stop = NO;
					if (self.block(self.filtereeItemsPtr[i], &stop)) {
						stackbuf[filteredItemsCount] = self.filtereeItemsPtr[i];
						filteredItemsCount++;
					}
				}
			} else {
				self.filtereeItemsPtr = state->itemsPtr;
				self.filtereeItemsIndex = count;
				self.filtereeItemsCount = count;
				state->itemsPtr = stackbuf;
				
				for (NSUInteger i = 0; i < count; i++) {
					BOOL stop = NO;
					if (self.block(self.filtereeItemsPtr[i], &stop)) {
						stackbuf[filteredItemsCount] = self.filtereeItemsPtr[i];
						filteredItemsCount++;
					}
				}
			}
		}
	} while ((filteredItemsCount == 0) && (count != 0));
	
	return filteredItemsCount;
}

@end

@implementation NSEnumerator(HBCollections)

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block {
	return [[[HBMapEnumerator alloc] initWithMapeeEnumerator:self
													andBlock:block] autorelease];
}

- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj, BOOL *stop)) block {
	return [[[HBFilterEnumerator alloc] initWithFiltereeEnumerator:self
														  andBlock:block] autorelease];
}

@end
