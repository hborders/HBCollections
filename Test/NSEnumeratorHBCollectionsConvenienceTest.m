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
#import "NSEnumerator+HBCollections.h"

@interface NSEnumeratorHBCollectionsConvenienceTest : GHTestCase {
	NSEnumerator *testObject;
	id (^mapBlock)(id obj);
}

@end

@implementation NSEnumeratorHBCollectionsConvenienceTest

- (void) setUp {
	[super setUp];
	
	testObject = [@[
                  @"1",
                  @"1",
                  @"2",
                  @"3",
                  ] objectEnumerator];
	
	mapBlock = [^(id obj) {
		if ([@"1" isEqual:obj]) {
			return (id) @"one";
		} else if ([@"2" isEqual:obj]) {
			return (id) @"two";
		} else if ([@"3" isEqual:obj]) {
			return (id) @"three";
		} else {
			return (id) @"error";
		}
	} copy];
}

- (void) testEnumerateCallsBlockWithEachElementInOrder {
	NSMutableArray *givenElements = [NSMutableArray array];
	[[testObject hb_actionEnumeratorUsingBlock:^(id obj) {
		[givenElements addObject:obj];
	}] hb_enumerate];
	
	NSMutableArray *expected = [NSMutableArray arrayWithObjects:
								@"1",
								@"1",
								@"2",
								@"3",
								nil];
	
	GHAssertEqualObjects(givenElements, expected, nil);
}

- (void) testAllObjectsAsSet {
	NSSet *expected = [NSSet setWithObjects:
					   @"1",
					   @"2",
					   @"3",
					   nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsSet], expected, nil);
}

- (void) testAllObjectsAsMutableSet {
	NSMutableSet *expected = [NSMutableSet setWithObjects:
							  @"1",
							  @"2",
							  @"3",
							  nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableSet], expected, nil);
}

- (void) testAllObjectsAsMutableArray {
	NSMutableArray *expected = [NSMutableArray arrayWithObjects:
								@"1",
								@"1",
								@"2",
								@"3",
								nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableArray], expected, nil);
}

- (void) testAllObjectsAsDictionaryByMappingKeysToValuesWithBlock {
    NSDictionary *expected = @{
    @"1" : @"one",
    @"2" : @"two",
    @"3" : @"three",
    };
	GHAssertEqualObjects([testObject hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock {
    NSDictionary *expected = @{
    @"1" : @"one",
    @"2" : @"two",
    @"3" : @"three",
    };
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsDictionaryByMappingValuesToKeysWithBlock {
    NSDictionary *expected = @{
    @"one" : @"1",
    @"two" : @"2",
    @"three" : @"3",
    };
	GHAssertEqualObjects([testObject hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock {
    NSMutableDictionary *expected = [@{
                                     @"one" : @"1",
                                     @"two" : @"2",
                                     @"three" : @"3",
                                     } mutableCopy];
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock:mapBlock], expected, nil);
}

@end
