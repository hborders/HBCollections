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
#import "NSArray+HBCollections.h"
#import "NSSet+HBCollections.h"

@interface NSEnumeratorHBCollectionsReduceTest : GHTestCase {
	id (^testBlock)(id, id);
	NSArray *testData;
	
	NSMutableArray *givenElements;
}

@end

@implementation NSEnumeratorHBCollectionsReduceTest

- (void) setUp {
	[super setUp];
	
	givenElements = [NSMutableArray array];
	testBlock = [[^(id previousObj, id obj) {
		[givenElements addObject:previousObj];
		[givenElements addObject:obj];
		NSString *previousString = previousObj;
		NSString *string = obj;
		return (id) [previousString stringByAppendingString:string];
	} copy] autorelease];
	
	testData = [NSArray arrayWithObjects:
				@"1",
				@"2",
				@"3",
				nil];
}

- (void) test_Reduce_Enumerates_Enumerator_In_Order_With_InitialValue_As_First_PreviousObj {
	NSEnumerator *testObject = [testData objectEnumerator];
	
	NSString *actual = [testObject hb_reduceUsingBlock:testBlock
									   andInitialValue:@"0"];
	
	GHAssertEqualObjects(actual, @"0123", nil);
	
	NSArray *expectedGivenElements = [NSArray arrayWithObjects:
									  @"0",
									  @"1",
									  @"01",
									  @"2",
									  @"012",
									  @"3",
									  nil];
	GHAssertEqualObjects(givenElements, expectedGivenElements, nil);
}

- (void) test_Reduce_Enumerates_Array_In_Order_With_InitialValue_As_First_PreviousObj {
	NSArray *testObject = testData;
	
	NSString *actual = [testObject hb_reduceUsingBlock:testBlock
									   andInitialValue:@"0"];
	
	GHAssertEqualObjects(actual, @"0123", nil);
	
	NSArray *expectedGivenElements = [NSArray arrayWithObjects:
									  @"0",
									  @"1",
									  @"01",
									  @"2",
									  @"012",
									  @"3",
									  nil];
	GHAssertEqualObjects(givenElements, expectedGivenElements, nil);
}

- (void) test_ReduceRight_Enumerates_Array_In_Reverse_Order_With_InitialValue_As_First_PreviousObj {
	NSArray *testObject = testData;
	
	NSString *actual = [testObject hb_reduceRightUsingBlock:testBlock
											andInitialValue:@"0"];
	
	GHAssertEqualObjects(actual, @"0321", nil);
	
	NSArray *expectedGivenElements = [NSArray arrayWithObjects:
									  @"0",
									  @"3",
									  @"03",
									  @"2",
									  @"032",
									  @"1",
									  nil];
	GHAssertEqualObjects(givenElements, expectedGivenElements, nil);
}

- (void) test_Reduce_Enumerates_Set_With_InitialValue_As_First_PreviousObj {
	NSSet *testObject = [NSSet setWithArray:testData];
	
	__block id firstPreviousObj;
	NSNumber *actual = [testObject hb_reduceUsingBlock:^(id previousObj, id obj) {
		if (!firstPreviousObj) {
			firstPreviousObj = previousObj;
		}
		
		NSNumber *previousNumber = previousObj;
		NSString *string = obj;
		return (id) [NSNumber numberWithInteger:([previousNumber integerValue] + [string integerValue])];
	}
									   andInitialValue:[NSNumber numberWithInteger:4]];
	
	GHAssertEqualObjects(actual, [NSNumber numberWithInteger:10], nil);
	GHAssertEqualObjects(firstPreviousObj, [NSNumber numberWithInteger:4], nil);
}

- (void) test_Reduce_Returns_InitialValue_For_Empty_Enumerator {
	NSEnumerator *testObject = [[NSArray array] objectEnumerator];
	NSString *actual = [testObject hb_reduceUsingBlock:^(id previousObj, id obj) {
		return (id) nil;
	} 
									   andInitialValue:@"foo"];
	
	GHAssertEqualObjects(actual, @"foo", nil);
}
   
- (void) test_Reduce_Returns_InitialValue_For_Empty_Array {
	NSArray *testObject = [NSArray array];
	NSString *actual = [testObject hb_reduceUsingBlock:^(id previousObj, id obj) {
		return (id) nil;
	} 
									   andInitialValue:@"foo"];
	
	GHAssertEqualObjects(actual, @"foo", nil);
}

- (void) test_ReduceRight_Returns_InitialValue_For_Empty_Array {
	NSArray *testObject = [NSArray array];
	NSString *actual = [testObject hb_reduceRightUsingBlock:^(id previousObj, id obj) {
		return (id) nil;
	} 
											andInitialValue:@"foo"];
	
	GHAssertEqualObjects(actual, @"foo", nil);
}

- (void) test_Reduce_Returns_InitialValue_For_Empty_Set {
	NSSet *testObject = [NSSet set];
	NSString *actual = [testObject hb_reduceUsingBlock:^(id previousObj, id obj) {
		return (id) nil;
	} 
									   andInitialValue:@"foo"];
	
	GHAssertEqualObjects(actual, @"foo", nil);
}

@end
