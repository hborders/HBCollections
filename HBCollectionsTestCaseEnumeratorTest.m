#import <GHUnit/GHUnit.h>
#import "HBCollectionsStackBufEnumerator.h"
#import "HBCollectionsItemsPtrEnumerator.h"

@interface HBCollectionsTestCaseEnumeratorTest : GHTestCase {
	NSArray *testData;
}

@end

@implementation HBCollectionsTestCaseEnumeratorTest

- (void) setUp {
	[super setUp];
	
	testData = [NSArray arrayWithObjects:
				@"0",
				@"1",
				@"2",
				nil];
}

- (void) test_StackBufEnumerator_FastEnumeration_Is_Normal {
	HBCollectionsStackBufEnumerator *testObject = 
	[[[HBCollectionsStackBufEnumerator alloc] initWithTestCase:self] autorelease];
	testObject.elements = testData;
	
	NSMutableArray *actualData = [NSMutableArray array];
	for (id obj in testObject) {
		[actualData addObject:obj];
	}
	
	GHAssertEqualObjects(actualData, testData, nil);
}

- (void) test_ItemsPtrEnumerator_FastEnumeration_Is_Normal {
	HBCollectionsItemsPtrEnumerator *testObject =
	[[[HBCollectionsItemsPtrEnumerator alloc] initWithTestCase:self] autorelease];
	testObject.elementsFactoryBlock = ^(NSUInteger stackBufLen) {
		return testData;
	};
	
	NSMutableArray *actualData = [NSMutableArray array];
	for (id obj in testObject) {
		[actualData addObject:obj];
	}
	
	GHAssertEqualObjects(actualData, testData, nil);
}

@end
