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
#import "NSEnumerator+HBCollections.h"
#import "NSArray+HBCollections.h"

#define HBCollectionsPerformanceTestCloseFactor 1.6
#define HBCollectionsPerformanceTestNotTerribleFactor 5

@interface HBCollectionsPerformanceTest : GHTestCase {
	NSUInteger large;
	NSMutableArray *largeArray;
}

@end

@implementation HBCollectionsPerformanceTest

- (void) setUp {
	[super setUp];
	
	large = 1000000;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	largeArray = [[NSMutableArray alloc] initWithCapacity:large];
	for (NSUInteger i = 0; i < large; i++) {
		[largeArray addObject:[NSNumber numberWithUnsignedInteger:i]];
	}
	[pool drain];
}

- (void) tearDown {
	[largeArray release];
	
	[super tearDown];
}

- (void) test_Large_Array_Enumerate_Performance_Is_Close_To_For_Loop {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *forLoopStartDate = [NSDate date];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	for (NSNumber *number in largeArray) {
		[forLooped addObject:number];
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *hbCollectionsed = [NSMutableArray arrayWithCapacity:large];
	NSDate *hbCollectionsStartDate = [NSDate date];
	[[largeArray hb_actionEnumeratorUsingBlock:^(id obj) {
		[hbCollectionsed addObject:obj];
	}] hb_enumerate];
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

- (void) test_Large_Array_Map_Performance_Is_Close_To_For_Loop {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *forLoopStartDate = [NSDate date];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	for (NSNumber *number in largeArray) {
		[forLooped addObject:[number stringValue]];
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSDate *hbCollectionsStartDate = [NSDate date];
	NSArray *hbCollectionsed = [[largeArray hb_mapEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (id) [number stringValue];
	}] allObjects];
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[hbCollectionsed count]; // make unused warning go away
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

- (void) test_Large_Array_Filter_Performance_Is_Close_To_For_Loop {
	NSNumber *filterNumber = [NSNumber numberWithInt:42];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *forLoopStartDate = [NSDate date];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	for (NSNumber *number in largeArray) {
		if ([number isEqualToNumber:filterNumber]) {
			[forLooped addObject:number];
		}
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSDate *hbCollectionsStartDate = [NSDate date];
	NSArray *hbCollectionsed = [[largeArray hb_filterEnumeratorUsingBlock:^(id obj) {
		return [obj isEqualToNumber:filterNumber];
	}] allObjects];
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[hbCollectionsed count]; // make unused warning go away
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

- (void) test_Large_Array_Late_Break_Performance_Is_Close_To_For_Loop {
	NSUInteger lateBreakIndex = [largeArray count] - 1;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *forLoopStartDate = [NSDate date];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	for (NSNumber *number in largeArray) {
		if ([forLooped count] == lateBreakIndex) {
			break;	
		}
		[forLooped addObject:number];
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSDate *hbCollectionsStartDate = [NSDate date];
	__block NSUInteger count = 0;
	NSArray *hbCollectionsed = [[largeArray hb_breakEnumeratorUsingBlock:^(id obj) {
		count++;
		return (BOOL)(count == lateBreakIndex);
	}] allObjects];
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[hbCollectionsed count]; // make unused warning go away
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

- (void) test_Large_Array_Early_Break_Performance_Is_Not_Terrible_Compared_To_For_Loop {
	NSUInteger earlyBreakIndex = 1000;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *forLoopStartDate = [NSDate date];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	for (NSNumber *number in largeArray) {
		if ([forLooped count] == earlyBreakIndex) {
			break;	
		}
		[forLooped addObject:number];
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSDate *hbCollectionsStartDate = [NSDate date];
	__block NSUInteger count = 0;
	NSArray *hbCollectionsed = [[largeArray hb_breakEnumeratorUsingBlock:^(id obj) {
		count++;
		return (BOOL)(count == earlyBreakIndex);
	}] allObjects];
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[hbCollectionsed count];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestNotTerribleFactor, nil);
}

- (void) test_Large_Array_Nested_Map_And_Filter_Performance_Is_Close_To_For_Loop {
	NSNumber *filterNumber = [NSNumber numberWithInt:42];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDate *forLoopStartDate = [NSDate date];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	for (NSNumber *number in largeArray) {
		NSString *stringValue = [number stringValue];
		NSNumber *numberValue = [NSNumber numberWithInteger:[stringValue integerValue]];
		if (![numberValue isEqualToNumber:filterNumber]) {
			[forLooped addObject:numberValue];	
		}
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSDate *hbCollectionsStartDate = [NSDate date];
	NSArray *hbCollectionsed = [[[largeArray hb_mapEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (id) [number stringValue];
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *stringValue = obj;
		return (id) [NSNumber numberWithInteger:[stringValue integerValue]];
	}] allObjects];
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[hbCollectionsed count]; // make unused warning go away
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

@end
