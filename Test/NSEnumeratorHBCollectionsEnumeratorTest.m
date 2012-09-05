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
#import <OCMock/OCMock.h>
#import "NSEnumerator+HBCollections.h"
#import "HBCollectionsStackBufEnumerator.h"
#import "HBCollectionsItemsPtrEnumerator.h"

@interface NSEnumeratorHBCollectionsEnumeratorTest : GHTestCase {
	void (^testBlock)(id);
	NSArray *testData;
    
	NSMutableArray *givenElements;
}

@end

@implementation NSEnumeratorHBCollectionsEnumeratorTest

- (void) setUp {
	[super setUp];
	
	givenElements = [NSMutableArray array];
	testBlock = [^(id obj) {
		[givenElements addObject:obj];
	} copy];
	
	testData = [NSArray arrayWithObjects:
				@"0",
				@"1",
				@"2",
				nil];
}

- (void) test_AllObjects_Are_Enumerated_In_Order {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_actionEnumeratorUsingBlock:testBlock];
	
	NSArray *actual = [testObject allObjects];
	
	GHAssertEqualObjects(actual, testData, nil);
	GHAssertEqualObjects(givenElements, testData, nil);
}

- (void) test_NextObject_Returns_Objects_In_Order {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_actionEnumeratorUsingBlock:testBlock];
	
	NSMutableArray *actual = [NSMutableArray array];
	for (id obj = [testObject nextObject]; obj; obj = [testObject nextObject]) {
		[actual addObject:obj];
	}
	
	GHAssertEqualObjects(actual, testData, nil);
	GHAssertEqualObjects(givenElements, testData, nil);
}

- (void) test_FastEnumeration_Returns_Objects_In_Order {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_actionEnumeratorUsingBlock:testBlock];
	
	NSMutableArray *actual = [NSMutableArray array];
	for (id obj in testObject) {
		[actual addObject:obj];
	}
	
	GHAssertEqualObjects(actual, testData, nil);
	GHAssertEqualObjects(givenElements, testData, nil);
}

- (void) test_FastEnumeration_Does_Not_Use_NextObject {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_actionEnumeratorUsingBlock:testBlock];
	
	id partialMockTestObject = [OCMockObject partialMockForObject:testObject];
	[[partialMockTestObject reject] nextObject];
	
	NSMutableArray *actual = [NSMutableArray array];
	for (id obj in testObject) {
		[actual addObject:obj];
	}
	
	GHAssertEqualObjects(actual, testData, nil);
	GHAssertEqualObjects(givenElements, testData, nil);
}

- (void) test_FastEnumeration_Works_With_Large_NSArray {
	const NSUInteger largeCount = 10000;
	NSMutableArray *largeMutableArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSMutableArray *expectedArray = [NSMutableArray arrayWithCapacity:largeCount];
	
	for (NSUInteger i = 0; i < largeCount; i++) {
		NSNumber *number = [NSNumber numberWithUnsignedInteger:i];
		[largeMutableArray addObject:number];
		[expectedArray addObject:number];
	}
	
	NSMutableArray *actualArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSEnumerator *testObject = [[largeMutableArray objectEnumerator] hb_actionEnumeratorUsingBlock:testBlock];
	for (NSNumber *number in testObject) {
		[actualArray addObject:number];
	}
	
	GHAssertEqualObjects(actualArray, expectedArray, nil);
	GHAssertEqualObjects(givenElements, expectedArray, nil);
}

@end
