#import "NSEnumerator+HBCollections.h"
#import "HBCollectionsStackBufEnumerator.h"
#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>

@interface NSEnumeratorHBCollectionsCallCountIntegrationTest : GHTestCase {
	HBCollectionsStackBufEnumerator *testEnumerator;

	NSUInteger mapCount;
	NSUInteger filterCount;
	NSUInteger breakCount;
	
	id (^mapBlock)(id);
	BOOL (^filterBlock)(id);
	BOOL (^breakBlock)(id);
}

@end

@implementation NSEnumeratorHBCollectionsCallCountIntegrationTest

- (void) setUp {
	[super setUp];
	
	testEnumerator = [[[HBCollectionsStackBufEnumerator alloc] init] autorelease];
	testEnumerator.elements = [NSArray arrayWithObjects:
							   @"1",
							   @"2",
							   @"3",
							   nil];
	
	mapCount = 0;
	filterCount = 0;
	breakCount = 0;
	
	mapBlock = [[^(id obj) {
		mapCount++;
		return obj;
	} copy] autorelease];
	filterBlock = [[^(id obj) {
		filterCount++;
		return YES;
	} copy] autorelease];
	breakBlock = [[^(id obj) {
		breakCount++;
		return NO;
	} copy] autorelease];
}

- (void) test_Map_Block_Not_Called_After_Preceding_Filter_NO {
	for (id obj in [[testEnumerator hb_filterEnumeratorUsingBlock:^(id obj) {
		return NO;
	}] hb_mapEnumeratorUsingBlock:mapBlock]);
	
	GHAssertEquals(mapCount, (NSUInteger) 0, nil);
}

- (void) test_Map_Block_Not_Called_After_Succeeding_Break_YES {
	for (id obj in [[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}]);
	
	GHAssertEquals(mapCount, (NSUInteger) 1, nil);
}

- (void) test_Map_Block_Not_Called_After_Preceding_Break_YES {
	for (id obj in [[testEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_mapEnumeratorUsingBlock:mapBlock]);
	
	GHAssertEquals(mapCount, (NSUInteger) 0, nil);
}

- (void) test_Filter_Block_Not_Called_After_Preceding_Filter_NO {
	for (id obj in [[testEnumerator hb_filterEnumeratorUsingBlock:^(id obj) {
		return NO;
	}] hb_filterEnumeratorUsingBlock:filterBlock]);
	
	GHAssertEquals(filterCount, (NSUInteger) 0, nil);
}

- (void) test_Filter_Block_Not_Called_After_Succeeding_Break_YES {
	for (id obj in [[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}]);
	
	GHAssertEquals(filterCount, (NSUInteger) 1, nil);
}

- (void) test_Filter_Block_Not_Called_After_Preceding_Break_YES {
	for (id obj in [[testEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_filterEnumeratorUsingBlock:filterBlock]);
	
	GHAssertEquals(filterCount, (NSUInteger) 0, nil);
}

- (void) test_Break_Block_Not_Called_After_Preceding_Filter_NO {
	for (id obj in [[testEnumerator hb_filterEnumeratorUsingBlock:^(id obj) {
		return NO;
	}] hb_breakEnumeratorUsingBlock:breakBlock]);
	
	GHAssertEquals(breakCount, (NSUInteger) 0, nil);
}

- (void) test_Break_Block_Not_Called_After_Succeeding_Break_YES {
	for (id obj in [[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}]);
	
	GHAssertEquals(breakCount, (NSUInteger) 1, nil);
}

- (void) test_Break_Block_Not_Called_After_Preceding_Break_YES {
	for (id obj in [[testEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_breakEnumeratorUsingBlock:breakBlock]);
	
	GHAssertEquals(breakCount, (NSUInteger) 0, nil);
}

@end
