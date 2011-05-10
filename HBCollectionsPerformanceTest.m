#import <GHUnit/GHUnit.h>
#import "NSEnumerator+HBCollections.h"

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

- (void) test_Large_Array_Performance_Is_Close_To_For_Loop {
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
	for (NSString *string in [[[[largeArray objectEnumerator] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (id) [number stringValue];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_breakEnumeratorUsingBlock:^(id obj) {
		return NO;
	}]) {
		[hbCollectionsed addObject:string];
	}
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval, nil);
}

- (void) test_Early_Break_Performance_Is_Close_To_For_Loop {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *forLooped = [NSMutableArray arrayWithCapacity:large];
	NSDate *forLoopStartDate = [NSDate date];
	for (NSNumber *number in largeArray) {
		[forLooped addObject:[number stringValue]];
		if ([forLooped count]) {
			break;	
		}
	}
	NSTimeInterval forLoopTimeInterval = -[forLoopStartDate timeIntervalSinceNow];
	[pool drain];
	
	pool = [[NSAutoreleasePool alloc] init];
	NSMutableArray *hbCollectionsed = [NSMutableArray arrayWithCapacity:large];
	NSDate *hbCollectionsStartDate = [NSDate date];
	for (NSString *string in [[[[largeArray objectEnumerator] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (id) [number stringValue];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		return YES;
	}] hb_breakEnumeratorUsingBlock:^(id obj) {
		return (BOOL)[hbCollectionsed count];
	}]) {
		[hbCollectionsed addObject:string];
	}
	NSTimeInterval hbCollectionsTimeInterval = -[hbCollectionsStartDate timeIntervalSinceNow];
	[pool drain];
	
	GHAssertLessThan(hbCollectionsTimeInterval, forLoopTimeInterval, nil);
}

@end
