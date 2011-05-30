#import "NSEnumerator+HBCollections.h"
#import "HBCollectionsStackBufEnumerator.h"
#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>

@interface NSEnumeratorHBCollectionsValuePassingIntegrationTest : GHTestCase {
	id originalValue;
	
	HBCollectionsStackBufEnumerator *testEnumerator;
	
	id mappedValue;
	
	id (^mapBlock1)(id);
	BOOL (^filterBlock1)(id);
	BOOL (^breakBlock1)(id);
	
	id (^mapBlock2)(id);
	BOOL (^filterBlock2)(id);
	BOOL (^breakBlock2)(id);
	
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

- (void) test_Map_Gets_Mapped_Value_From_Preceding_Map {
	for (id obj in [[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock1] hb_mapEnumeratorUsingBlock:mapBlock2]);
	
	GHAssertEqualObjects(lastMapBlock2Obj, mappedValue, nil);
}

- (void) test_Filter_Gets_Mapped_Value_From_Preceding_Map {
	for (id obj in [[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock1] hb_filterEnumeratorUsingBlock:filterBlock2]);
	
	GHAssertEqualObjects(lastFilterBlock2Obj, mappedValue, nil);
}

- (void) test_Break_Gets_Mapped_Value_From_Preceding_Map {
	for (id obj in [[testEnumerator hb_mapEnumeratorUsingBlock:mapBlock1] hb_breakEnumeratorUsingBlock:breakBlock2]);
	
	GHAssertEqualObjects(lastBreakBlock2Obj, mappedValue, nil);
}

- (void) test_Map_Gets_Value_From_Preceding_Filter {
	for (id obj in [[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock1] hb_mapEnumeratorUsingBlock:mapBlock2]);
	
	GHAssertEqualObjects(lastMapBlock2Obj, originalValue, nil);
}

- (void) test_Filter_Gets_Value_From_Preceding_Filter {
	for (id obj in [[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock1] hb_filterEnumeratorUsingBlock:filterBlock2]);
	
	GHAssertEqualObjects(lastFilterBlock2Obj, originalValue, nil);
}

- (void) test_Break_Gets_Value_From_Preceding_Filter {
	for (id obj in [[testEnumerator hb_filterEnumeratorUsingBlock:filterBlock1] hb_breakEnumeratorUsingBlock:breakBlock2]);
	
	GHAssertEqualObjects(lastBreakBlock2Obj, originalValue, nil);
}

- (void) test_Map_Gets_Value_From_Preceding_Break {
	for (id obj in [[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock1] hb_mapEnumeratorUsingBlock:mapBlock2]);
	
	GHAssertEqualObjects(lastMapBlock2Obj, originalValue, nil);
}

- (void) test_Filter_Gets_Value_From_Preceding_Break {
	for (id obj in [[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock1] hb_filterEnumeratorUsingBlock:filterBlock2]);
	
	GHAssertEqualObjects(lastFilterBlock2Obj, originalValue, nil);
}

- (void) test_Break_Gets_Value_From_Preceding_Break {
	for (id obj in [[testEnumerator hb_breakEnumeratorUsingBlock:breakBlock1] hb_breakEnumeratorUsingBlock:breakBlock2]);
	
	GHAssertEqualObjects(lastBreakBlock2Obj, originalValue, nil);
}

@end
