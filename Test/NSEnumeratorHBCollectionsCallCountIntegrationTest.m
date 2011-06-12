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
