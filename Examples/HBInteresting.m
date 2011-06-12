#import "NSEnumerator+HBCollections.h"

/*
 * These aren't strictly the simplest solutions to the problem, but are examples of interesting ways to solve them.
 */

@interface HBExampleUIntegerEnumerator : NSEnumerator

- (id) initWithStart: (NSUInteger) start;

@end

@interface HBExampleUIntegerEnumerator()

@property (nonatomic) NSUInteger index;

@end

@implementation HBExampleUIntegerEnumerator

@synthesize index = _index;

- (id) initWithStart: (NSUInteger) start {
	self = [super init];
	if (self) {
		_index = start;
	}
	
	return self;
}

#pragma mark -
#pragma mark NSEnumerator

- (id) nextObject {
	NSNumber *number = [NSNumber numberWithUnsignedInteger:_index];
	_index++;
	return number;
}

@end

NSNumber *factorial(NSUInteger n) {
	NSEnumerator *numberEnumerator = [[[HBExampleUIntegerEnumerator alloc] initWithStart:1] autorelease];
	return [[numberEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (BOOL) ([number unsignedIntegerValue] <= n);
	}] hb_reduceUsingBlock:^(id previousObj, id obj) {
		NSNumber *previousFactorial = previousObj;
		NSNumber *number = obj;
		return (id) [NSNumber numberWithUnsignedInteger:[previousFactorial unsignedIntegerValue] * [number unsignedIntegerValue]];
	}
			andInitialValue:[NSNumber numberWithUnsignedInteger:1]];
}

NSNumber *fibonacci(NSUInteger n) {
	if (n == 0) {
		return [NSNumber numberWithInt:0];
	}
	
	NSEnumerator *numberEnumerator = [[[HBExampleUIntegerEnumerator alloc] initWithStart:1] autorelease];
	return [[[numberEnumerator hb_breakEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (BOOL) ([number unsignedIntegerValue] <= n);
	}] hb_reduceUsingBlock:^(id previousObj, id obj) {
		NSMutableArray *lastTwoFibs = previousObj;
		NSNumber *secondToLastFib = [lastTwoFibs objectAtIndex:0];
		NSNumber *lastFib = [lastTwoFibs objectAtIndex:1];
		NSNumber *nextFib = [NSNumber numberWithUnsignedInteger:[lastFib unsignedIntegerValue] + [secondToLastFib unsignedIntegerValue]];
		[lastTwoFibs replaceObjectAtIndex:0 withObject:lastFib];
		[lastTwoFibs replaceObjectAtIndex:1 withObject:nextFib];
		return (id) lastTwoFibs;
	}
			 andInitialValue:[NSMutableArray arrayWithObjects:
							  [NSNumber numberWithUnsignedInteger:0],
							  [NSNumber numberWithUnsignedInteger:1],
							  nil]] lastObject];
}