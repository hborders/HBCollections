/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

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
