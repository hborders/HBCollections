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

@interface NSEnumeratorHBCollectionsFilterEnumeratorTest : GHTestCase {
	BOOL (^testFilterBlock)(id);
	NSArray *testData;
	NSArray *expectedFilteredData;
}

@end

@implementation NSEnumeratorHBCollectionsFilterEnumeratorTest

- (void) setUp {
	[super setUp];
	
	testFilterBlock = ^(id obj) {
		if ([@"0" isEqualToString:obj]) {
			return YES;
		} else if ([@"1" isEqualToString:obj]) {
			return NO;
		} else if ([@"2" isEqualToString:obj]) {
			return YES;
		} else {
			NSString *string = obj;
			int intValue = [string intValue];
			return (BOOL)((intValue != 0) && ((intValue % 2) == 0));
		}
		
		return NO;
	};
	
	testData = @[
    @"0",
    @"1",
    @"2",
    ];
	expectedFilteredData = @[
    @"0",
    @"2",
    ];
}

- (void) test_AllObjects_Are_Enumerated_In_Order_Filtered_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_filterEnumeratorUsingBlock:testFilterBlock];
	
	NSArray *actualFiltered = [testObject allObjects];
	
	GHAssertEqualObjects(actualFiltered, expectedFilteredData, nil);
}

- (void) test_NextObject_Returns_Objects_In_Order_Filtered_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_filterEnumeratorUsingBlock:testFilterBlock];
	
	NSMutableArray *actualFiltered = [NSMutableArray array];
	for (id obj = [testObject nextObject]; obj; obj = [testObject nextObject]) {
		[actualFiltered addObject:obj];
	}
	
	GHAssertEqualObjects(actualFiltered, expectedFilteredData, nil);
}

- (void) test_NextObject_Returns_Objects_In_Order_Filtered_By_Block_When_Multiple_Objects_Are_Consecutively_Filtered {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_filterEnumeratorUsingBlock:^(id obj) {
		return (BOOL)[@"2" isEqual:obj];
	}];
	
	NSMutableArray *actualFiltered = [NSMutableArray array];
	for (id obj = [testObject nextObject]; obj; obj = [testObject nextObject]) {
		[actualFiltered addObject:obj];
	}
	
	GHAssertEqualObjects(actualFiltered, [NSArray arrayWithObject:@"2"], nil);
}

- (void) test_FastEnumeration_Returns_Objects_In_Order_Filtered_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_filterEnumeratorUsingBlock:testFilterBlock];
	
	NSMutableArray *actualFiltered = [NSMutableArray array];
	for (id obj in testObject) {
		[actualFiltered addObject:obj];
	}
	
	GHAssertEqualObjects(actualFiltered, expectedFilteredData, nil);
}

- (void) test_FastEnumeration_Does_Not_Use_NextObject {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_filterEnumeratorUsingBlock:testFilterBlock];
	
	id partialMockTestObject = [OCMockObject partialMockForObject:testObject];
	[[partialMockTestObject reject] nextObject];
	
	NSMutableArray *actualFiltered = [NSMutableArray array];
	for (id obj in testObject) {
		[actualFiltered addObject:obj];
	}
	
	GHAssertEqualObjects(actualFiltered, expectedFilteredData, nil);
}

- (void) test_FastEnumeration_Overwrites_StackBuf_When_StackBuf_Is_ItemsPtr_Leaves_NSFastEnumerationState_Alone {
	HBCollectionsStackBufEnumerator *stackBufferEnumerator =
	[[HBCollectionsStackBufEnumerator alloc] initWithTestCase:self];
	stackBufferEnumerator.elements = testData;
	
	NSEnumerator *testObject = [stackBufferEnumerator hb_filterEnumeratorUsingBlock:testFilterBlock];
	
	NSMutableArray *actualFiltered = [NSMutableArray array];
	for (id obj in testObject) {
		[actualFiltered addObject:obj];
	}
	
	GHAssertEqualObjects(actualFiltered, expectedFilteredData, nil);
}

- (void) test_FastEnumeration_Uses_StackBuf_When_ItemsPtr_Isnt_StackBuf_But_Replaces_ItemsPtr_On_NSFastEnumerationState_For_Wrapped_Enumerator_And_Only_Delegates_Once_When_ItemsPtr_Count_Is_Less_Than_StackBuf_Len {
	HBCollectionsItemsPtrEnumerator *itemsPtrEnumerator =
	[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self];
	itemsPtrEnumerator.elementsFactoryBlock = ^(NSUInteger stackBufLen) {
		GHAssertGreaterThan(stackBufLen, (NSUInteger) 3, @"stackBuf len too small: %d", stackBufLen);
		
		return testData;
	};
	
	NSEnumerator *testObject = [itemsPtrEnumerator hb_filterEnumeratorUsingBlock:testFilterBlock];
	
	NSMutableArray *actualFiltered = [NSMutableArray array];
	for (id obj in testObject) {
		[actualFiltered addObject:obj];
	}
	
	GHAssertEqualObjects(actualFiltered, expectedFilteredData, nil);
}

- (void) test_FastEnumeration_Uses_StackBuf_When_ItemsPtr_Isnt_StackBuf_But_Replaces_ItemsPtr_On_NSFastEnumerationState_For_Wrapped_Enumerator_And_Only_Delegates_Once_When_ItemsPtr_Count_Is_Greater_Than_StackBuf_Len {
	const NSUInteger minimumStackBufLen = [testData count];
	HBCollectionsItemsPtrEnumerator *itemsPtrEnumerator =
	[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self];
	__block NSUInteger generatedElementLen = 0;
	itemsPtrEnumerator.elementsFactoryBlock = ^(NSUInteger stackBufLen) {
		GHAssertGreaterThan(stackBufLen, (NSUInteger) 3, @"stackBuf len too small: %d", stackBufLen);
		
		generatedElementLen = (2 * stackBufLen) + 1;
		NSMutableArray *generatedElements = [testData mutableCopy];
		for (NSUInteger i = minimumStackBufLen; i < generatedElementLen; i++) {
			[generatedElements addObject:[[NSNumber numberWithUnsignedInteger:i] stringValue]];
		}
		
		return (NSArray *) generatedElements;
	};
	
	NSEnumerator *testObject = [itemsPtrEnumerator hb_filterEnumeratorUsingBlock:testFilterBlock];
	
	NSMutableArray *actualFiltered = [NSMutableArray array];
	for (id obj in testObject) {
		[actualFiltered addObject:obj];
	}
	
	NSMutableArray *expandedExpectedFilteredData = [expectedFilteredData mutableCopy];
	for (NSUInteger i = [testData count]; i < generatedElementLen; i++) {
		if ((i % 2) == 0) {
			[expandedExpectedFilteredData addObject:[[NSNumber numberWithUnsignedInteger:i] stringValue]];
		}
	}
	
	GHAssertEqualObjects(actualFiltered, expandedExpectedFilteredData, nil);
}

- (void) test_FastEnumeration_Works_With_Large_NSArray {
	const NSUInteger largeCount = 10000;
	NSMutableArray *largeMutableArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSMutableArray *expectedFilteredArray = [NSMutableArray arrayWithCapacity:largeCount];
	
	for (NSUInteger i = 0; i < largeCount; i++) {
		NSString *string = [[NSNumber numberWithUnsignedInteger:i] stringValue];
		[largeMutableArray addObject:string];
		if ((i % 2) == 1) {
			[expectedFilteredArray addObject:string];
		}
	}
	
	NSMutableArray *actualFilteredArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSEnumerator *testObject = [[largeMutableArray objectEnumerator] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL)(([string intValue] % 2) == 1);
	}];
	for (NSNumber *number in testObject) {
		[actualFilteredArray addObject:number];
	}
	
	GHAssertEqualObjects(actualFilteredArray, expectedFilteredArray, nil);
}

@end
