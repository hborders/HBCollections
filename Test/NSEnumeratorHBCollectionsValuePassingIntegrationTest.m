/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

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
