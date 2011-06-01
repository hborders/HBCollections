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
