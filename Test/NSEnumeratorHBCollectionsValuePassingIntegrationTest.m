#import "NSEnumerator+HBCollections.h"
#import "HBCollectionsStackBufEnumerator.h"
#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>

@interface NSEnumeratorHBCollectionsValuePassingIntegrationTest : GHTestCase {
	id originalValue;
	
	HBCollectionsStackBufEnumerator *testEnumerator;
	
	id mappedValue;
	
	void (^enumerateBlock1)(id);
	id (^mapBlock1)(id);
	BOOL (^filterBlock1)(id);
	BOOL (^breakBlock1)(id);
	
	void (^enumerateBlock2)(id);
	id (^mapBlock2)(id);
	BOOL (^filterBlock2)(id);
	BOOL (^breakBlock2)(id);
	
	id lastEnumerateBlock2Obj;
	id lastMapBlock2Obj;
	id lastFilterBlock2Obj;
	id lastBreakBlock2Obj;	
}

@end

@implementation NSEnumeratorHBCollectionsValuePassingIntegrationTest

- (void) setUp {
	[super setUp];
	
	originalValue = @"1";
	
	testEnumerator = [[[HBCollectionsStackBufEnumerator alloc] init] autorelease];
	testEnumerator.elements = [NSArray arrayWithObjects:
							   originalValue,
							   nil];
	
	mappedValue = @"one";
	
	enumerateBlock1 = [[^(id obj) {
	} copy] autorelease];
	mapBlock1 = [[^(id obj) {
		if (obj == originalValue) {
			return mappedValue;
		} else {
			return (id) @"error1";
		}
	} copy] autorelease];
	filterBlock1 = [[^(id obj) {
		return YES;
	} copy] autorelease];
	breakBlock1 = [[^(id obj) {
		return NO;
	} copy] autorelease];
	
	enumerateBlock2 = [[^(id obj) {
		lastEnumerateBlock2Obj = obj;
	} copy] autorelease];
	mapBlock2 = [[^(id obj) {
		lastMapBlock2Obj = obj;
		if (obj == mappedValue) {
			return mappedValue;
		} else {
			return (id) @"error2";
		}
	} copy] autorelease];
	filterBlock2 = [[^(id obj) {
		lastFilterBlock2Obj = obj;
		return YES;
	} copy] autorelease];
	breakBlock2 = [[^(id obj) {
		lastBreakBlock2Obj = obj;
		return NO;
	} copy] autorelease];
	
	lastMapBlock2Obj = nil;
	lastFilterBlock2Obj = nil;
	lastBreakBlock2Obj = nil;
}

- (void) test_Action_Gets_Value_From_Preceding_Action {
	[[[testEnumerator hb_actionEnumeratorUsingBlock:enumerateBlock1] hb_actionEnumeratorUsingBlock:enumerateBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastEnumerateBlock2Obj, originalValue, nil);
}

- (void) test_Action_Gets_Value_From_Preceding_Map {
	[[[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock1] hb_actionEnumeratorUsingBlock:enumerateBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastEnumerateBlock2Obj, mappedValue, nil);
}

- (void) test_Action_Gets_Value_From_Preceding_Filter {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock1] hb_actionEnumeratorUsingBlock:enumerateBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastEnumerateBlock2Obj, originalValue, nil);
}

- (void) test_Action_Gets_Value_From_Preceding_Break {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock1] hb_actionEnumeratorUsingBlock:enumerateBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastEnumerateBlock2Obj, originalValue, nil);
}

- (void) test_Map_Gets_Value_From_Preceding_Action {
	[[[testEnumerator hb_actionEnumeratorUsingBlock:enumerateBlock1] hb_mapEnumeratorUsingBlock:mapBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastMapBlock2Obj, originalValue, nil);
}

- (void) test_Map_Gets_Mapped_Value_From_Preceding_Map {
	[[[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock1] hb_mapEnumeratorUsingBlock:mapBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastMapBlock2Obj, mappedValue, nil);
}

- (void) test_Map_Gets_Value_From_Preceding_Filter {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock1] hb_mapEnumeratorUsingBlock:mapBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastMapBlock2Obj, originalValue, nil);
}

- (void) test_Map_Gets_Value_From_Preceding_Break {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock1] hb_mapEnumeratorUsingBlock:mapBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastMapBlock2Obj, originalValue, nil);
}

- (void) test_Filter_Gets_Value_From_Preceding_Action {
	[[[testEnumerator hb_actionEnumeratorUsingBlock:enumerateBlock1] hb_filterEnumeratorUsingBlock:filterBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastFilterBlock2Obj, originalValue, nil);
}

- (void) test_Filter_Gets_Mapped_Value_From_Preceding_Map {
	[[[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock1] hb_filterEnumeratorUsingBlock:filterBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastFilterBlock2Obj, mappedValue, nil);
}

- (void) test_Filter_Gets_Value_From_Preceding_Filter {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock1] hb_filterEnumeratorUsingBlock:filterBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastFilterBlock2Obj, originalValue, nil);
}

- (void) test_Filter_Gets_Value_From_Preceding_Break {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock1] hb_filterEnumeratorUsingBlock:filterBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastFilterBlock2Obj, originalValue, nil);
}

- (void) test_Break_Gets_Value_From_Preceding_Action {
	[[[testEnumerator hb_actionEnumeratorUsingBlock:enumerateBlock1] hb_breakEnumeratorUsingBlock:breakBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastBreakBlock2Obj, originalValue, nil);
}

- (void) test_Break_Gets_Mapped_Value_From_Preceding_Map {
	[[[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock1] hb_breakEnumeratorUsingBlock:breakBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastBreakBlock2Obj, mappedValue, nil);
}

- (void) test_Break_Gets_Value_From_Preceding_Filter {
	[[[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock1] hb_breakEnumeratorUsingBlock:breakBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastBreakBlock2Obj, originalValue, nil);
}

- (void) test_Break_Gets_Value_From_Preceding_Break {
	[[[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock1] hb_breakEnumeratorUsingBlock:breakBlock2] hb_enumerate];
	
	GHAssertEqualObjects(lastBreakBlock2Obj, originalValue, nil);
}

@end
