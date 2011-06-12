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

@interface NSEnumeratorHBCollectionsBreakEnumeratorTest : GHTestCase {
	BOOL (^testBreakBlock)(id);
	NSArray *testData;
	NSArray *expectedData;
}

@end

@implementation NSEnumeratorHBCollectionsBreakEnumeratorTest

- (void) setUp {
	[super setUp];
	
	testBreakBlock = ^(id obj) {
		if ([@"0" isEqualToString:obj]) {
			return NO;
		} else if ([@"1" isEqualToString:obj]) {
			return NO;
		} else {
			return YES;
		}
	};
	
	testData = [NSArray arrayWithObjects:
				@"0",
				@"1",
				@"2",
				nil];
	expectedData = [NSArray arrayWithObjects:
					@"0",
					@"1",
					nil];
}

- (void) test_AllObjects_Are_Enumerated_In_Order_And_Stopped_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_breakEnumeratorUsingBlock:testBreakBlock];
	
	NSArray *actual = [testObject allObjects];
	
	GHAssertEqualObjects(actual, expectedData, nil);
}

- (void) test_NextObject_Returns_Objects_In_Order_Then_Nil_When_Block_Returns_YES {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_breakEnumeratorUsingBlock:testBreakBlock];
	
	NSMutableArray *actual = [NSMutableArray array];
	for (id obj = [testObject nextObject]; obj; obj = [testObject nextObject]) {
		[actual addObject:obj];
	}
	
	GHAssertEqualObjects(actual, expectedData, nil);
}

- (void) test_NextObject_Returns_Nil_When_Block_Immediately_Returns_YES {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}];
	
	NSMutableArray *actual = [NSMutableArray array];
	for (id obj = [testObject nextObject]; obj; obj = [testObject nextObject]) {
		[actual addObject:obj];
	}
	
	GHAssertEqualObjects(actual, [NSArray array], nil);
}

- (void) test_FastEnumeration_Returns_Objects_In_Order_Then_Nil_When_Block_Returns_YES {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_breakEnumeratorUsingBlock:testBreakBlock];
	
	NSMutableArray *actual = [NSMutableArray array];
	for (id obj in testObject) {
		[actual addObject:obj];
	}
	
	GHAssertEqualObjects(actual, expectedData, nil);
}

- (void) test_FastEnumeration_Does_Not_Use_NextObject {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_breakEnumeratorUsingBlock:testBreakBlock];
	
	id partialMockTestObject = [OCMockObject partialMockForObject:testObject];
	[[partialMockTestObject reject] nextObject];
	
	NSMutableArray *actual = [NSMutableArray array];
	for (id obj in testObject) {
		[actual addObject:obj];
	}
	
	GHAssertEqualObjects(actual, expectedData, nil);
}

- (void) test_FastEnumeration_Works_With_Large_NSArray_When_Never_Breaked {
	const NSUInteger largeCount = 10000;
	NSMutableArray *largeMutableArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSMutableArray *expectedArray = [NSMutableArray arrayWithCapacity:largeCount];
	
	for (NSUInteger i = 0; i < largeCount; i++) {
		NSNumber *number = [NSNumber numberWithUnsignedInteger:i];
		[largeMutableArray addObject:number];
		[expectedArray addObject:number];	
	}
	
	NSMutableArray *actualArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSEnumerator *testObject = [[largeMutableArray objectEnumerator] hb_breakEnumeratorUsingBlock:^(id obj) {
		return NO;
	}];
	for (NSNumber *number in testObject) {
		[actualArray addObject:number];
	}
	
	GHAssertEqualObjects(actualArray, expectedArray, nil);
}

@end
