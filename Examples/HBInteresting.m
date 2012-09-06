/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import "HBCollections.h"

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
	NSEnumerator *numberEnumerator = [[HBExampleUIntegerEnumerator alloc] initWithStart:1];
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
	
	NSEnumerator *numberEnumerator = [[HBExampleUIntegerEnumerator alloc] initWithStart:1];
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
							  @0,
							  @1,
							  nil]] lastObject];
}