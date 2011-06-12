/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import "NSSet+HBCollections.h"
#import "NSEnumerator+HBCollections.h"
#import "HBMapFilterOrBreakEnumerator.h"

@implementation NSSet(HBCollections)

- (NSEnumerator *) hb_actionEnumeratorUsingBlock:(void (^)(id obj)) block {
	HBMapFilterOrBreakEnumerator *actionMapFilterOrBreakEnumerator =
		(HBMapFilterOrBreakEnumerator *) [[self objectEnumerator] hb_actionEnumeratorUsingBlock:block];
	actionMapFilterOrBreakEnumerator.hb_allObjectsSizeHint = [self count];
	
	return actionMapFilterOrBreakEnumerator;
}

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

- (id) hb_reduceUsingBlock:(id (^)(id previousObj, id obj)) block 
		   andInitialValue:(id) initialValue {
	id previousObj = initialValue;
	for (id obj in self) {
		previousObj = block(previousObj, obj);
	}
	
	return previousObj;
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
