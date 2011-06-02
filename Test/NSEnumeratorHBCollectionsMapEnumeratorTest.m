#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import <GHUnit/GHUnit.h>
#import "NSEnumerator+HBCollections.h"
#import "HBCollectionsStackBufEnumerator.h"
#import "HBCollectionsItemsPtrEnumerator.h"

@interface NSEnumeratorHBCollectionsMapEnumeratorTest : GHTestCase {
	id (^testMapBlock)(id);
	NSArray *testData;
	NSArray *expectedMappedData;
}

@end

@implementation NSEnumeratorHBCollectionsMapEnumeratorTest

- (void) setUp {
	[super setUp];
	
	testMapBlock = ^(id obj) {
		if ([@"0" isEqualToString:obj]) {
			return (id) @"zero";
		} else if ([@"1" isEqualToString:obj]) {
			return (id) @"one";
		} else if ([@"2" isEqualToString:obj]) {
			return (id) @"two";
		} else {
			return (id) [NSString stringWithFormat:@"oops: %@", obj];
		}
	};
	
	testData = [NSArray arrayWithObjects:
				@"0",
				@"1",
				@"2",
				nil];
	expectedMappedData = [NSArray arrayWithObjects:
						  @"zero",
						  @"one",
						  @"two",
						  nil];
}

- (void) test_AllObjects_Are_Enumerated_In_Order_Mapped_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testMapBlock];
	
	NSArray *actualMapped = [testObject allObjects];
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_NextObject_Returns_Objects_In_Order_Mapped_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testMapBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj = [testObject nextObject]; obj; obj = [testObject nextObject]) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_FastEnumeration_Returns_Objects_In_Order_Mapped_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testMapBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_FastEnumeration_Does_Not_Use_NextObject {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testMapBlock];
	
	id partialMockTestObject = [OCMockObject partialMockForObject:testObject];
	[[partialMockTestObject reject] nextObject];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_FastEnumeration_Overwrites_StackBuf_When_StackBuf_Is_ItemsPtr_Leaves_NSFastEnumerationState_Alone {
	HBCollectionsStackBufEnumerator *stackBufferEnumerator = 
		[[[HBCollectionsStackBufEnumerator alloc] initWithTestCase:self] autorelease];
	stackBufferEnumerator.elements = testData;
	
	NSEnumerator *testObject = [stackBufferEnumerator hb_mapEnumeratorUsingBlock:testMapBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_FastEnumeration_Uses_StackBuf_When_ItemsPtr_Isnt_StackBuf_But_Replaces_ItemsPtr_On_NSFastEnumerationState_For_Wrapped_Enumerator_And_Only_Delegates_Once_When_ItemsPtr_Count_Is_Less_Than_StackBuf_Len {
	HBCollectionsItemsPtrEnumerator *itemsPtrEnumerator =
		[[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self] autorelease];
	itemsPtrEnumerator.elementsFactoryBlock = ^(NSUInteger stackBufLen) {
		GHAssertGreaterThan(stackBufLen, (NSUInteger) 3, @"stackBuf len too small: %d", stackBufLen);
		
		return testData;
	};
	
	NSEnumerator *testObject = [itemsPtrEnumerator hb_mapEnumeratorUsingBlock:testMapBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
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
	
	NSEnumerator *testObject = [itemsPtrEnumerator hb_mapEnumeratorUsingBlock:testMapBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	NSMutableArray *expandedExpectedMappedData = [expectedMappedData mutableCopy];
	for (NSUInteger i = [testData count]; i < generatedElementLen; i++) {
		NSString *expectedMappedDatum = 
			[@"oops: " stringByAppendingString:[[NSNumber numberWithUnsignedInteger:i] stringValue]];
		[expandedExpectedMappedData addObject:expectedMappedDatum];
	}
	
	GHAssertEqualObjects(actualMapped, expandedExpectedMappedData, nil);
}

- (void) test_FastEnumeration_Works_With_Large_NSArray {
	const NSUInteger largeCount = 10000;
	NSMutableArray *largeMutableArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSMutableArray *expectedMappedArray = [NSMutableArray arrayWithCapacity:largeCount];
	
	for (NSUInteger i = 0; i < largeCount; i++) {
		[largeMutableArray addObject:[[NSNumber numberWithUnsignedInteger:i] stringValue]];
		[expectedMappedArray addObject:[NSNumber numberWithUnsignedInteger:i]];
	}
	
	NSMutableArray *actualMappedArray = [NSMutableArray arrayWithCapacity:largeCount];
	NSEnumerator *testObject = [[largeMutableArray objectEnumerator] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInteger:[string integerValue]];
	}];
	for (NSNumber *number in testObject) {
		[actualMappedArray addObject:number];
	}
	
	GHAssertEqualObjects(actualMappedArray, expectedMappedArray, nil);
}

@end
