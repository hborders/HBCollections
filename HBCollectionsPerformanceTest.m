#import <GHUnit/GHUnit.h>
#import "NSEnumerator+HBCollections.h"

#define HBCollectionsPerformanceTestCloseFactor 1.5
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

- (void) test_Large_Array_Map_Performance_Is_Close_To_For_Loop {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	NSDate *forLoopStartDate = [NSDate date];
	for (NSNumber *number in largeArray) {
		[forLooped addObject:[number stringValue]];
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *hbCollectionsed = [NSMutableArray arrayWithCapacity:large];
	NSDate *hbCollectionsStartDate = [NSDate date];
	for (NSString *string in [[largeArray objectEnumerator] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (id) [number stringValue];
	}]) {
		[hbCollectionsed addObject:string];
	}
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

- (void) test_Large_Array_Filter_Performance_Is_Close_To_For_Loop {
	NSNumber *filterNumber = [NSNumber numberWithInt:42];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	NSDate *forLoopStartDate = [NSDate date];
	for (NSNumber *number in largeArray) {
		if ([number isEqualToNumber:filterNumber]) {
			[forLooped addObject:number];
		}
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *hbCollectionsed = [NSMutableArray arrayWithCapacity:large];
	NSDate *hbCollectionsStartDate = [NSDate date];
	for (NSNumber *number in [[largeArray objectEnumerator] hb_filterEnumeratorUsingBlock:^(id obj) {
		return [obj isEqualToNumber:filterNumber];
	}]) {
		[hbCollectionsed addObject:number];
	}
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

- (void) test_Large_Array_Late_Break_Performance_Is_Close_To_For_Loop {
	NSUInteger lateBreakIndex = [largeArray count] - 1;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	NSDate *forLoopStartDate = [NSDate date];
	for (NSNumber *number in largeArray) {
		if ([forLooped count] == lateBreakIndex) {
			break;	
		}
		[forLooped addObject:number];
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *hbCollectionsed = [NSMutableArray arrayWithCapacity:large];
	NSDate *hbCollectionsStartDate = [NSDate date];
	for (NSNumber *number in [[largeArray objectEnumerator] hb_breakEnumeratorUsingBlock:^(id obj) {
		return (BOOL)([hbCollectionsed count] == lateBreakIndex);
	}]) {
		[hbCollectionsed addObject:number];
	}
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

- (void) test_Large_Array_Early_Break_Performance_Is_Not_Terrible_Compared_To_For_Loop {
	NSUInteger earlyBreakIndex = 1000;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	NSDate *forLoopStartDate = [NSDate date];
	for (NSNumber *number in largeArray) {
		if ([forLooped count] == earlyBreakIndex) {
			break;	
		}
		[forLooped addObject:number];
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *hbCollectionsed = [NSMutableArray arrayWithCapacity:large];
	NSDate *hbCollectionsStartDate = [NSDate date];
	for (NSNumber *number in [[largeArray objectEnumerator] hb_breakEnumeratorUsingBlock:^(id obj) {
		return (BOOL)([hbCollectionsed count] == earlyBreakIndex);
	}]) {
		[hbCollectionsed addObject:number];
	}
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestNotTerribleFactor, nil);
}

- (void) test_Large_Array_Nested_Map_And_Filter_Performance_Is_Close_To_For_Loop {
	NSNumber *filterNumber = [NSNumber numberWithInt:42];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	NSDate *forLoopStartDate = [NSDate date];
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
	NSMutableArray *hbCollectionsed = [NSMutableArray arrayWithCapacity:large];
	NSDate *hbCollectionsStartDate = [NSDate date];
	for (NSNumber *renumber in [[[largeArray objectEnumerator] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (id) [number stringValue];
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *stringValue = obj;
		return (id) [NSNumber numberWithInteger:[stringValue integerValue]];
	}]) {
		[hbCollectionsed addObject:renumber];
	}
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval * HBCollectionsPerformanceTestCloseFactor, nil);
}

@end
