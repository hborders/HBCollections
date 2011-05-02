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
		[mappedObjects addObject:_block(obj)];
	}
	return mappedObjects;
}

- (id) nextObject {
	id nextObject = [self.mapeeEnumerator nextObject];
	if (nextObject) {
		return _block(nextObject);
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
			for (NSUInteger i = 0; i < count; i++) {
				stackbuf[i] = self.block(state->itemsPtr[i]);
			}
			state->itemsPtr = stackbuf;
			
			return count;
		}
	}
}

@end



@implementation NSEnumerator(HBCollections)

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block {
	return [[[HBMapEnumerator alloc] initWithMapeeEnumerator:self
													andBlock:block] autorelease];
}

- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj, BOOL *stop)) block {
	return nil;
}

@end
