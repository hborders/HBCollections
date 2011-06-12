/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import "HBMapFilterOrBreakEnumerator.h"

void HBMapFilterOrBreak(id *mapFilterOrBreakBlocksPtr, 
						NSUInteger mapFilterOrBreakBlocksCount,
						id obj,
						id *mappedObjectPtr,
						BOOL *shouldFilterPtr, 
						BOOL *shouldBreakPtr);

@interface HBMapFilterOrBreakEnumerator()

@property (nonatomic, retain) NSEnumerator *mapFilterOrBreakeeEnumerator;
@property (nonatomic, retain) NSArray *mapFilterOrBreakBlocks;
@property (nonatomic) id *mapFilterOrBreakBlocksPtr;
@property (nonatomic) NSUInteger mapFilterOrBreakBlocksCount;

@property (nonatomic) id *mapFilterOrBreakeeItemsPtr;
@property (nonatomic) NSUInteger mapFilterOrBreakeeItemsIndex;
@property (nonatomic) NSUInteger mapFilterOrBreakeeItemsCount;
@property (nonatomic) BOOL mapFilterOrBreakItemsBroken;

- (id) initWithMapFilterOrBreakeeEnumerator: (NSEnumerator *) mapFilterOrBreakeeEnumerator
				  andMapFilterOrBreakBlocks: (NSArray *) mapFilterOrBreakBlocks
					  andAllObjectsSizeHint: (NSUInteger) allObjectsSizeHint;

@end


@implementation HBMapFilterOrBreakEnumerator

@synthesize mapFilterOrBreakeeEnumerator = _mapFilterOrBreakeeEnumerator;
@synthesize mapFilterOrBreakBlocks = _mapFilterOrBreakBlocks;
@synthesize mapFilterOrBreakBlocksPtr = _mapFilterOrBreakBlocksPtr;
@synthesize mapFilterOrBreakBlocksCount = _mapFilterOrBreakBlocksCount;
@synthesize hb_allObjectsSizeHint = _hb_allObjectsSizeHint;

@synthesize mapFilterOrBreakeeItemsPtr = _mapFilterOrBreakeeItemsPtr;
@synthesize mapFilterOrBreakeeItemsIndex = _mapFilterOrBreakeeItemsIndex;
@synthesize mapFilterOrBreakeeItemsCount = _mapFilterOrBreakeeItemsCount;
@synthesize mapFilterOrBreakItemsBroken = _mapFilterOrBreakItemsBroken;

- (id) initWithMapFilterOrBreakeeEnumerator: (NSEnumerator *) mapFilterOrBreakeeEnumerator
				  andMapFilterOrBreakBlocks: (NSArray *) mapFilterOrBreakBlocks {
	return [self initWithMapFilterOrBreakeeEnumerator:mapFilterOrBreakeeEnumerator
							andMapFilterOrBreakBlocks:mapFilterOrBreakBlocks
								andAllObjectsSizeHint:0];
}

- (id) initWithMapFilterOrBreakeeEnumerator: (NSEnumerator *) mapFilterOrBreakeeEnumerator
				  andMapFilterOrBreakBlocks: (NSArray *) mapFilterOrBreakBlocks
					  andAllObjectsSizeHint: (NSUInteger) allObjectsSizeHint {
	self = [super init];
	if (self) {
		_mapFilterOrBreakeeEnumerator = [mapFilterOrBreakeeEnumerator retain];
		_mapFilterOrBreakBlocks = [mapFilterOrBreakBlocks retain];
		_hb_allObjectsSizeHint = allObjectsSizeHint;
		
		_mapFilterOrBreakBlocksCount = [_mapFilterOrBreakBlocks count];
		_mapFilterOrBreakBlocksPtr = malloc(sizeof(id) * _mapFilterOrBreakBlocksCount);
		[_mapFilterOrBreakBlocks getObjects:_mapFilterOrBreakBlocksPtr 
									  range:NSMakeRange(0, _mapFilterOrBreakBlocksCount)];
	}
	
	return self;
}

- (void) dealloc {
	[_mapFilterOrBreakeeEnumerator release];
	[_mapFilterOrBreakBlocks release];
	free(_mapFilterOrBreakBlocksPtr);
	
	[super dealloc];
}

#pragma mark -
#pragma mark public API

- (HBMapFilterOrBreakEnumerator *) hb_addMapFilterOrBreakBlock: (HBMapFilterOrBreakBlock) mapFilterOrBreakBlock {
	NSArray *newMapFilterOrBreakBlocks = [_mapFilterOrBreakBlocks arrayByAddingObject:mapFilterOrBreakBlock];
	return [[[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:_mapFilterOrBreakeeEnumerator
															 andMapFilterOrBreakBlocks:newMapFilterOrBreakBlocks
																 andAllObjectsSizeHint:_hb_allObjectsSizeHint] autorelease];
}

#pragma mark -
#pragma mark NSEnumerator

- (NSArray *) allObjects {
	NSMutableArray *mappedObjects = [NSMutableArray arrayWithCapacity:_hb_allObjectsSizeHint];
	for (id obj in _mapFilterOrBreakeeEnumerator) {
		id mappedObj;
		BOOL shouldFilter;
		BOOL shouldBreak;
		HBMapFilterOrBreak(_mapFilterOrBreakBlocksPtr,
						   _mapFilterOrBreakBlocksCount,
						   obj,
						   &mappedObj,
						   &shouldFilter,
						   &shouldBreak);
		if (shouldBreak) {
			break;
		} else if (shouldFilter) {
			[mappedObjects addObject:mappedObj];
		}
	}
	return mappedObjects;
}

- (id) nextObject {
	id obj;
	while (obj = [_mapFilterOrBreakeeEnumerator nextObject]) {
		id mappedObj;
		BOOL shouldFilter;
		BOOL shouldBreak;
		HBMapFilterOrBreak(_mapFilterOrBreakBlocksPtr,
						   _mapFilterOrBreakBlocksCount,
						   obj,
						   &mappedObj,
						   &shouldFilter,
						   &shouldBreak);
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
	if (_mapFilterOrBreakItemsBroken) {
		return 0;
	} else {
		NSUInteger count = 0;
		NSUInteger filteredItemsCount = 0;
		do {
			if (_mapFilterOrBreakeeItemsPtr && 
				(_mapFilterOrBreakeeItemsIndex < _mapFilterOrBreakeeItemsCount)) {
				count = MIN(len, _mapFilterOrBreakeeItemsCount - _mapFilterOrBreakeeItemsIndex);
				state->itemsPtr = stackbuf;
				for (NSUInteger i = 0; i < count; i++) {
					id obj = _mapFilterOrBreakeeItemsPtr[_mapFilterOrBreakeeItemsIndex + i];
					id mappedObj;
					BOOL shouldFilter;
					BOOL shouldBreak;
					HBMapFilterOrBreak(_mapFilterOrBreakBlocksPtr,
									   _mapFilterOrBreakBlocksCount,
									   obj,
									   &mappedObj,
									   &shouldFilter,
									   &shouldBreak);
					if (shouldBreak) {
						_mapFilterOrBreakItemsBroken = YES;
						break;
					} else if (shouldFilter) {
						stackbuf[filteredItemsCount] = mappedObj;
						filteredItemsCount++;
					}
				}
				_mapFilterOrBreakeeItemsIndex += count;
			} else {
				if (_mapFilterOrBreakeeItemsPtr) {
					state->itemsPtr = _mapFilterOrBreakeeItemsPtr;
					_mapFilterOrBreakeeItemsPtr = NULL;
					_mapFilterOrBreakeeItemsIndex = 0;
					_mapFilterOrBreakeeItemsCount = 0;
				}
				
				count = [_mapFilterOrBreakeeEnumerator countByEnumeratingWithState:state
																		   objects:stackbuf
																			 count:len];
				if (state->itemsPtr == stackbuf) {
					for (NSUInteger i = 0; i < count; i++) {
						id obj = stackbuf[i];
						id mappedObj;
						BOOL shouldFilter;
						BOOL shouldBreak;
						HBMapFilterOrBreak(_mapFilterOrBreakBlocksPtr,
										   _mapFilterOrBreakBlocksCount,
										   obj,
										   &mappedObj,
										   &shouldFilter,
										   &shouldBreak);
						if (shouldBreak) {
							_mapFilterOrBreakItemsBroken = YES;
							break;
						} else if (shouldFilter) {
							stackbuf[filteredItemsCount] = mappedObj;
							filteredItemsCount++;
						}
					}
				} else if (len < count) {
					_mapFilterOrBreakeeItemsPtr = state->itemsPtr;
					_mapFilterOrBreakeeItemsIndex = len;
					_mapFilterOrBreakeeItemsCount = count;
					state->itemsPtr = stackbuf;
					
					for (NSUInteger i=0; i < len; i++) {
						id obj = _mapFilterOrBreakeeItemsPtr[i];
						id mappedObj;
						BOOL shouldFilter;
						BOOL shouldBreak;
						HBMapFilterOrBreak(_mapFilterOrBreakBlocksPtr,
										   _mapFilterOrBreakBlocksCount,
										   obj,
										   &mappedObj,
										   &shouldFilter,
										   &shouldBreak);
						if (shouldBreak) {
							_mapFilterOrBreakItemsBroken = YES;
							break;
						} else if (shouldFilter) {
							stackbuf[filteredItemsCount] = mappedObj;
							filteredItemsCount++;
						}
					}
				} else {
					_mapFilterOrBreakeeItemsPtr = state->itemsPtr;
					_mapFilterOrBreakeeItemsIndex = count;
					_mapFilterOrBreakeeItemsCount = count;
					state->itemsPtr = stackbuf;
					
					for (NSUInteger i = 0; i < count; i++) {
						id obj = _mapFilterOrBreakeeItemsPtr[i];
						id mappedObj;
						BOOL shouldFilter;
						BOOL shouldBreak;
						HBMapFilterOrBreak(_mapFilterOrBreakBlocksPtr,
										   _mapFilterOrBreakBlocksCount,
										   obj,
										   &mappedObj,
										   &shouldFilter,
										   &shouldBreak);
						if (shouldBreak) {
							_mapFilterOrBreakItemsBroken = YES;
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
				 !_mapFilterOrBreakItemsBroken);
		
		return filteredItemsCount;
	}
}

@end

void HBMapFilterOrBreak(id *mapFilterOrBreakBlocksPtr, 
						NSUInteger mapFilterOrBreakBlocksCount,
						id obj,
						id *mappedObjectPtr,
						BOOL *shouldFilterPtr, 
						BOOL *shouldBreakPtr) {
	id mappedObj = obj;
	id nextMappedObj;
	BOOL shouldFilter;
	BOOL shouldBreak;
	
	for (NSUInteger i = 0; i < mapFilterOrBreakBlocksCount; i++) {
		HBMapFilterOrBreakBlock mapFilterOrBreakBlock = mapFilterOrBreakBlocksPtr[i];
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
