/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "HBCollections.h"

void dictionariesFromArray() {
	NSArray *array = @[
    @"0",
    @"1",
    @"2",
    ];
	
	id (^stringToNumberBlock)(id) = ^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	};
	
	NSDictionary *arrayAsKeys =
    [array hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:stringToNumberBlock];
	NSLog(@"arrayAsKeys: %@", arrayAsKeys);
	
	NSDictionary *arrayAsValues =
    [array hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:stringToNumberBlock];
	NSLog(@"arrayAsValues: %@", arrayAsValues);
}

void enumeratorToMutableArray(NSEnumerator *enumerator) {
	NSMutableArray *mutableArray = [enumerator hb_allObjectsAsMutableArray];
	NSLog(@"Mutable array: %@", mutableArray);
}

void enumeratorToSet(NSEnumerator *enumerator) {
	NSSet *set = [enumerator hb_allObjectsAsSet];
	NSLog(@"Set: %@", set);
}

void enumeratorToMutableSet(NSEnumerator *enumerator) {
	NSMutableSet *mutableSet = [enumerator hb_allObjectsAsMutableSet];
	NSLog(@"Mutable set: %@", mutableSet);
}