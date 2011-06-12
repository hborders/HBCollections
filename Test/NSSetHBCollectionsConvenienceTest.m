/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import <GHUnit/GHUnit.h>
#import "NSSet+HBCollections.h"

@interface NSSetHBCollectionsConvenienceTest : GHTestCase {
	NSSet *testObject;
	id (^mapBlock)(id obj);
}

@end

@implementation NSSetHBCollectionsConvenienceTest

- (void) setUp {
	[super setUp];
	
	testObject = [NSSet setWithObjects:
				  @"1",
				  @"2",
				  @"3",
				  nil];
	
	mapBlock = [[^(id obj) {
		if ([@"1" isEqual:obj]) {
			return (id) @"one";					
		} else if ([@"2" isEqual:obj]) {
			return (id) @"two";			
		} else if ([@"3" isEqual:obj]) {
			return (id) @"three";
		} else {
			return (id) @"error";
		}
	} copy] autorelease];
}

- (void) testAllObjectsAsDictionaryByMappingKeysToValuesWithBlock {
	NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"one", @"1",
							  @"two", @"2",
							  @"three", @"3",
							  nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock {
	NSMutableDictionary *expected = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 @"one", @"1",
									 @"two", @"2",
									 @"three", @"3",
									 nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsDictionaryByMappingValuesToKeysWithBlock {
	NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"1", @"one",
							  @"2", @"two",
							  @"3", @"three",
							  nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock {
	NSMutableDictionary *expected = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 @"1", @"one",
									 @"2", @"two",
									 @"3", @"three",
									 nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock:mapBlock], expected, nil);
}

@end
