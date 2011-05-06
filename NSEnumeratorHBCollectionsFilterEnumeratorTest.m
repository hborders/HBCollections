#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>
#import "NSEnumerator+HBCollections.h"
#import "HBCollectionsStackBufEnumerator.h"
#import "HBCollectionsItemsPtrEnumerator.h"

@interface NSEnumeratorHBCollectionsFilterEnumeratorTest : GHTestCase {
	BOOL (^testFilterBlock)(id, BOOL *);
	NSArray *testData;
	NSArray *expectedFilteredData;
}

@end

@implementation NSEnumeratorHBCollectionsFilterEnumeratorTest

- (void) setUp {
	[super setUp];
	
	testFilterBlock = ^(id obj, BOOL *stop) {
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
	
	testData = [NSArray arrayWithObjects:
				@"0",
				@"1",
				@"2",
				nil];
	expectedFilteredData = [NSArray arrayWithObjects:
							@"0",
							@"2",
							nil];
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
	NSEnumerator *testObject = [[testData objectEnumerator] hb_filterEnumeratorUsingBlock:^(id obj, BOOL *stop) {
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
	[[[HBCollectionsStackBufEnumerator alloc] initWithTestCase:self] autorelease];
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
	[[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self] autorelease];
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
	[[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self] autorelease];
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
	NSEnumerator *testObject = [[largeMutableArray objectEnumerator] hb_filterEnumeratorUsingBlock:^(id obj, BOOL *stop) {
		NSString *string = obj;
		return (BOOL)(([string intValue] % 2) == 1);
	}];
	for (NSNumber *number in testObject) {
		[actualFilteredArray addObject:number];
	}
	
	GHAssertEqualObjects(actualFilteredArray, expectedFilteredArray, nil);
}

@end
