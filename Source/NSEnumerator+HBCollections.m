/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "NSEnumerator+HBCollections.h"
#import "HBMapFilterOrBreakEnumerator.h"

@implementation NSEnumerator(HBCollections)

- (NSEnumerator *) hb_actionEnumeratorUsingBlock:(void (^)(id obj)) block {
	HBMapFilterOrBreakBlock plainMapFilterOrBreakBlock =
    [^(id obj,
       id *mappedObjPtr,
       BOOL *shouldFilterPtr,
       BOOL *shouldBreakPtr) {
        block(obj);
        *mappedObjPtr = obj;
        *shouldFilterPtr = YES;
        *shouldBreakPtr = NO;
    } copy];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:plainMapFilterOrBreakBlock];
	} else {
		return [[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
                                                                andMapFilterOrBreakBlocks:@[
                plainMapFilterOrBreakBlock,
                ]];
	}
}

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block {
	HBMapFilterOrBreakBlock mapMapFilterOrBreakBlock =
    [^(id obj,
       id *mappedObjPtr,
       BOOL *shouldFilterPtr,
       BOOL *shouldBreakPtr) {
        *mappedObjPtr = block(obj);
        *shouldFilterPtr = YES;
        *shouldBreakPtr = NO;
    } copy];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:mapMapFilterOrBreakBlock];
	} else {
		return [[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
                                                                andMapFilterOrBreakBlocks:@[
                mapMapFilterOrBreakBlock,
                ]];
	}
}

- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	HBMapFilterOrBreakBlock filterMapFilterOrBreakBlock =
    [^(id obj,
       id *mappedObjPtr,
       BOOL *shouldFilterPtr,
       BOOL *shouldBreakPtr) {
        *mappedObjPtr = obj;
        *shouldFilterPtr = block(obj);
        *shouldBreakPtr = NO;
    } copy];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:filterMapFilterOrBreakBlock];
	} else {
		return [[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
                                                                andMapFilterOrBreakBlocks:@[
                filterMapFilterOrBreakBlock,
                ]];
	}
}

- (NSEnumerator *) hb_breakEnumeratorUsingBlock:(BOOL (^)(id obj)) block {
	HBMapFilterOrBreakBlock breakMapFilterOrBreakBlock =
    [^(id obj,
       id *mappedObjPtr,
       BOOL *shouldFilterPtr,
       BOOL *shouldBreakPtr) {
        *mappedObjPtr = obj;
        *shouldFilterPtr = YES;
        *shouldBreakPtr = block(obj);
    } copy];
	
	if ([self isKindOfClass:[HBMapFilterOrBreakEnumerator class]]) {
		HBMapFilterOrBreakEnumerator *selfMapFilterOrBreakEnumerator = (HBMapFilterOrBreakEnumerator *) self;
		return [selfMapFilterOrBreakEnumerator hb_addMapFilterOrBreakBlock:breakMapFilterOrBreakBlock];
	} else {
		return [[HBMapFilterOrBreakEnumerator alloc] initWithMapFilterOrBreakeeEnumerator:self
                                                                andMapFilterOrBreakBlocks:@[
                breakMapFilterOrBreakBlock,
                ]];
	}
}

- (id) hb_reduceUsingBlock:(id (^)(id previousObj, id obj)) block
		   andInitialValue:(id) initialValue {
	id previousObj = initialValue;
	for (id obj in self) {
		previousObj = block(previousObj, obj);
	}
	
	return previousObj;
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

