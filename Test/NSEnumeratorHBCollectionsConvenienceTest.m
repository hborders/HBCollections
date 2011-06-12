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
	
	testObject = [[NSArray arrayWithObjects:
				   @"1",
				   @"1",
				   @"2",
				   @"3",
				   nil] objectEnumerator];
	
	mapBlock = [[^(id obj) {
		if ([@"1" isEqual:obj]) {
			return (id) @"one";					
		} else if ([@"2" isEqual:obj]) {
			return (id) @"two";			
		} else if ([@"3" isEqual:obj]) {
			return (id) @"three";
		} else {
			return (id) @"error";
		}
	} copy] autorelease];
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
	NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"one", @"1",
							  @"two", @"2",
							  @"three", @"3",
							  nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock {
	NSMutableDictionary *expected = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 @"one", @"1",
									 @"two", @"2",
									 @"three", @"3",
									 nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsDictionaryByMappingValuesToKeysWithBlock {
	NSDictionary *expected = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"1", @"one",
							  @"2", @"two",
							  @"3", @"three",
							  nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:mapBlock], expected, nil);
}

- (void) testAllObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock {
	NSMutableDictionary *expected = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									 @"1", @"one",
									 @"2", @"two",
									 @"3", @"three",
									 nil];
	GHAssertEqualObjects([testObject hb_allObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock:mapBlock], expected, nil);
}

@end
