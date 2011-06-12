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
	testBlock = [[^(id obj) {
		[givenElements addObject:obj];
	} copy] autorelease];
	
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
