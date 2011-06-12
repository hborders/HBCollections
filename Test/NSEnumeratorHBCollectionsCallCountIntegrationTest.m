#import "NSEnumerator+HBCollections.h"
#import "HBCollectionsStackBufEnumerator.h"
#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>

@interface NSEnumeratorHBCollectionsCallCountIntegrationTest : GHTestCase {
	HBCollectionsStackBufEnumerator *testEnumerator;

	NSUInteger enumerateCount;
	NSUInteger mapCount;
	NSUInteger filterCount;
	NSUInteger breakCount;
	
	void (^enumerateBlock)(id);
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
	
	enumerateCount = 0;
	mapCount = 0;
	filterCount = 0;
	breakCount = 0;
	
	enumerateBlock = [[^(id obj) {
		enumerateCount++;
	} copy] autorelease];
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

- (void) test_Enumerate_Block_Not_Called_After_Preceding_Filter_NO {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:^(id obj) {
		return NO;
	}] hb_actionEnumeratorUsingBlock:enumerateBlock] hb_enumerate];
	
	GHAssertEquals(enumerateCount, (NSUInteger) 0, nil);
}

- (void) test_Enumerate_Block_Not_Called_After_Succeeding_Break_YES {
	[[[testEnumerator hb_actionEnumeratorUsingBlock:enumerateBlock] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_enumerate];
	
	GHAssertEquals(enumerateCount, (NSUInteger) 1, nil);
}

- (void) test_Enumerate_Block_Not_Called_After_Preceding_Break_YES {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_actionEnumeratorUsingBlock:enumerateBlock] hb_enumerate];
	
	GHAssertEquals(enumerateCount, (NSUInteger) 0, nil);
}

- (void) test_Map_Block_Not_Called_After_Preceding_Filter_NO {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:^(id obj) {
		return NO;
	}] hb_mapEnumeratorUsingBlock:mapBlock] hb_enumerate];
	
	GHAssertEquals(mapCount, (NSUInteger) 0, nil);
}

- (void) test_Map_Block_Not_Called_After_Succeeding_Break_YES {
	[[[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_enumerate];
	
	GHAssertEquals(mapCount, (NSUInteger) 1, nil);
}

- (void) test_Map_Block_Not_Called_After_Preceding_Break_YES {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_mapEnumeratorUsingBlock:mapBlock] hb_enumerate];
	
	GHAssertEquals(mapCount, (NSUInteger) 0, nil);
}

- (void) test_Filter_Block_Not_Called_After_Preceding_Filter_NO {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:^(id obj) {
		return NO;
	}] hb_filterEnumeratorUsingBlock:filterBlock] hb_enumerate];
	
	GHAssertEquals(filterCount, (NSUInteger) 0, nil);
}

- (void) test_Filter_Block_Not_Called_After_Succeeding_Break_YES {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_enumerate];
	
	GHAssertEquals(filterCount, (NSUInteger) 1, nil);
}

- (void) test_Filter_Block_Not_Called_After_Preceding_Break_YES {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_filterEnumeratorUsingBlock:filterBlock] hb_enumerate];
	
	GHAssertEquals(filterCount, (NSUInteger) 0, nil);
}

- (void) test_Break_Block_Not_Called_After_Preceding_Filter_NO {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:^(id obj) {
		return NO;
	}] hb_breakEnumeratorUsingBlock:breakBlock] hb_enumerate];
	
	GHAssertEquals(breakCount, (NSUInteger) 0, nil);
}

- (void) test_Break_Block_Not_Called_After_Succeeding_Break_YES {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock] hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_enumerate];
	
	GHAssertEquals(breakCount, (NSUInteger) 1, nil);
}

- (void) test_Break_Block_Not_Called_After_Preceding_Break_YES {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_breakEnumeratorUsingBlock:breakBlock] hb_enumerate];
	
	GHAssertEquals(breakCount, (NSUInteger) 0, nil);
}

@end
