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
