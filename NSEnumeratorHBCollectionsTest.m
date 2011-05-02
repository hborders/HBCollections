#import <Foundation/Foundation.h>
#import <OCMock/OCMock.h>
#import <GHUnit/GHUnit.h>
#import "NSEnumerator+HBCollections.h"

@interface HBCollectionsTestCaseEnumerator : NSEnumerator {
	
}

@property (nonatomic, retain) GHTestCase *testCase;

- (id) initWithTestCase: (GHTestCase *) testCase;

- (void)failWithException:(NSException*)exception;

@end

@implementation HBCollectionsTestCaseEnumerator

@synthesize testCase = _testCase;

- (id) init {
	return [self initWithTestCase:nil];
}

- (id) initWithTestCase: (GHTestCase *) testCase {
	if (self = [super init]) {
		self.testCase = testCase;
	}
	
	return self;
}

- (void) dealloc {
	self.testCase = nil;
	
	[super dealloc];
}

- (void)failWithException:(NSException*)exception {
	[self.testCase failWithException:exception];
}

@end



@interface HBCollectionsStackBufEnumerator : HBCollectionsTestCaseEnumerator {
	
}

@property (nonatomic, retain) NSArray *elements;

@property (nonatomic) NSFastEnumerationState lastFastEnumerationState;

@end

@implementation HBCollectionsStackBufEnumerator

@synthesize elements = _elements;
@synthesize lastFastEnumerationState = _lastFastEnumerationState;

- (void) dealloc {
	self.elements = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	static unsigned long mutationsPtr = 0;
	switch (state->state) {
		case 0: {
			GHAssertTrue([self.elements count] <= len, @"len should be %d or larger", [self.elements count]);
			
			NSFastEnumerationState lastFastEnumerationState = { 0 };
			state->state = lastFastEnumerationState.state = 1;
			state->itemsPtr = lastFastEnumerationState.itemsPtr = stackbuf;
			state->mutationsPtr = lastFastEnumerationState.mutationsPtr = &mutationsPtr;
			state->extra[0] = lastFastEnumerationState.extra[0] = 10;
			state->extra[1] = lastFastEnumerationState.extra[1] = 11;
			state->extra[2] = lastFastEnumerationState.extra[2] = 12;
			state->extra[3] = lastFastEnumerationState.extra[3] = 13;
			state->extra[4] = lastFastEnumerationState.extra[4] = 14;
			
			[self.elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				stackbuf[idx] = obj;
			}];
			
			self.lastFastEnumerationState = lastFastEnumerationState;
			
			return [self.elements count];
		}
		case 1:
			GHAssertEquals(state->state, self.lastFastEnumerationState.state, nil);
			GHAssertEquals(state->itemsPtr, self.lastFastEnumerationState.itemsPtr, nil);
			GHAssertEquals(state->mutationsPtr, self.lastFastEnumerationState.mutationsPtr, nil);
			GHAssertEquals(state->extra[0], self.lastFastEnumerationState.extra[0], nil);
			GHAssertEquals(state->extra[1], self.lastFastEnumerationState.extra[1], nil);
			GHAssertEquals(state->extra[2], self.lastFastEnumerationState.extra[2], nil);
			GHAssertEquals(state->extra[3], self.lastFastEnumerationState.extra[3], nil);
			GHAssertEquals(state->extra[4], self.lastFastEnumerationState.extra[4], nil);
			
			state->state = 2;
			
			return 0;
		default:
			GHFail(@"Invalid state: %d", state->state);
			return 0;
	}
}

@end

@interface HBCollectionsItemsPtrEnumerator : HBCollectionsTestCaseEnumerator {
}

@property (nonatomic, copy) NSArray *(^elementsFactoryBlock)(NSUInteger stackBufLen);

@property (nonatomic) NSFastEnumerationState lastFastEnumerationState;
@property (nonatomic) id *elementsItemsPtr;


@end

@implementation HBCollectionsItemsPtrEnumerator

@synthesize elementsFactoryBlock = _elementsFactoryBlock;

@synthesize lastFastEnumerationState = _lastFastEnumerationState;
@synthesize elementsItemsPtr = _elementsItemsPtr;

- (void) dealloc {
	self.elementsFactoryBlock = nil;
	if (self.elementsItemsPtr) {
		free(self.elementsItemsPtr);
		self.elementsItemsPtr = NULL;
	}
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
									count:(NSUInteger)len {
	static unsigned long mutationsPtr = 0;
	switch (state->state) {
		case 0: {
			NSArray *elements = self.elementsFactoryBlock(len);
			self.elementsItemsPtr = (id *) malloc(sizeof(id) * [elements count]);
			[elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				self.elementsItemsPtr[idx] = obj;
			}];
			
			NSFastEnumerationState lastFastEnumerationState = { 0 };
			state->state = lastFastEnumerationState.state = 1;
			state->itemsPtr = lastFastEnumerationState.itemsPtr = self.elementsItemsPtr;
			state->mutationsPtr = lastFastEnumerationState.mutationsPtr = &mutationsPtr;
			state->extra[0] = lastFastEnumerationState.extra[0] = 10;
			state->extra[1] = lastFastEnumerationState.extra[1] = 11;
			state->extra[2] = lastFastEnumerationState.extra[2] = 12;
			state->extra[3] = lastFastEnumerationState.extra[3] = 13;
			state->extra[4] = lastFastEnumerationState.extra[4] = 14;
			
			self.lastFastEnumerationState = lastFastEnumerationState;
			
			return [elements count];
		}
		case 1:
			GHAssertEquals(state->state, self.lastFastEnumerationState.state, nil);
			GHAssertEquals(state->itemsPtr, self.lastFastEnumerationState.itemsPtr, nil);
			GHAssertEquals(state->mutationsPtr, self.lastFastEnumerationState.mutationsPtr, nil);
			GHAssertEquals(state->extra[0], self.lastFastEnumerationState.extra[0], nil);
			GHAssertEquals(state->extra[1], self.lastFastEnumerationState.extra[1], nil);
			GHAssertEquals(state->extra[2], self.lastFastEnumerationState.extra[2], nil);
			GHAssertEquals(state->extra[3], self.lastFastEnumerationState.extra[3], nil);
			GHAssertEquals(state->extra[4], self.lastFastEnumerationState.extra[4], nil);
			
			state->state = 2;
			return 0;
		default:
			GHFail(@"Invalid state: %d", state->state);
			return 0;
	}
}

@end



@interface NSEnumeratorHBCollectionsTest : GHTestCase {
	id (^testBlock)(id);
	NSArray *testData;
	NSArray *expectedMappedData;
}

@end

@implementation NSEnumeratorHBCollectionsTest

- (void) setUp {
	[super setUp];
	
	testBlock = ^(id obj) {
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

- (void) test_allObjects_Are_Enumerated_In_Order_Mapped_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testBlock];
	
	NSArray *actualMapped = [testObject allObjects];
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_nextObject_Returns_Objects_In_Order_Mapped_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj = [testObject nextObject]; obj; obj = [testObject nextObject]) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_FastEnumeration_Returns_Objects_In_Order_Mapped_By_Block {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_FastEnumeration_Does_Not_Use_NextObject {
	NSEnumerator *testObject = [[testData objectEnumerator] hb_mapEnumeratorUsingBlock:testBlock];
	
	id partialMockTestObject = [OCMockObject partialMockForObject:testObject];
	[[partialMockTestObject reject] nextObject];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_StackBufEnumerator_FastEnumeration_Is_Normal {
	HBCollectionsStackBufEnumerator *testObject = 
		[[[HBCollectionsStackBufEnumerator alloc] initWithTestCase:self] autorelease];
	testObject.elements = testData;
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, testData, nil);
}

- (void) test_FastEnumeration_Overwrites_StackBuf_When_StackBuf_Is_ItemsPtr_Leaves_NSFastEnumerationState_Alone {
	HBCollectionsStackBufEnumerator *stackBufferEnumerator = 
		[[[HBCollectionsStackBufEnumerator alloc] initWithTestCase:self] autorelease];
	stackBufferEnumerator.elements = testData;
	
	NSEnumerator *testObject = [stackBufferEnumerator hb_mapEnumeratorUsingBlock:testBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, expectedMappedData, nil);
}

- (void) test_ItemsPtrEnumerator_FastEnumeration_Is_Normal {
	HBCollectionsItemsPtrEnumerator *testObject =
		[[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self] autorelease];
	testObject.elementsFactoryBlock = ^(NSUInteger stackBufLen) {
		return testData;
	};
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	GHAssertEqualObjects(actualMapped, testData, nil);
}

- (void) test_FastEnumeration_Uses_StackBuf_When_ItemsPtr_Isnt_StackBuf_But_Replaces_ItemsPtr_On_NSFastEnumerationState_For_Wrapped_Enumerator_And_Only_Delegates_Once_When_ItemsPtr_Count_Is_Less_Than_StackBuf_Len {
	HBCollectionsItemsPtrEnumerator *itemsPtrEnumerator =
		[[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self] autorelease];
	itemsPtrEnumerator.elementsFactoryBlock = ^(NSUInteger stackBufLen) {
		GHAssertTrue(stackBufLen > 3, @"stackBuf len too small: %d", stackBufLen);
		
		return testData;
	};
	
	NSEnumerator *testObject = [itemsPtrEnumerator hb_mapEnumeratorUsingBlock:testBlock];
	
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
		GHAssertFalse(stackBufLen < minimumStackBufLen, @"stackBuf len too small: %d", stackBufLen);
		
		generatedElementLen = (2 * stackBufLen) + 1;
		NSMutableArray *generatedElements = [testData mutableCopy];
		for (NSUInteger i = minimumStackBufLen; i < generatedElementLen; i++) {
			[generatedElements addObject:[[NSNumber numberWithUnsignedInteger:i] stringValue]];
		}
		
		return (NSArray *) generatedElements;
	};
	
	NSEnumerator *testObject = [itemsPtrEnumerator hb_mapEnumeratorUsingBlock:testBlock];
	
	NSMutableArray *actualMapped = [NSMutableArray array];
	for (id obj in testObject) {
		[actualMapped addObject:obj];
	}
	
	NSMutableArray *expandedExpectedMappedData = [expectedMappedData mutableCopy];
	for (NSUInteger i = [expectedMappedData count]; i < generatedElementLen; i++) {
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
