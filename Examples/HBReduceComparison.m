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

void reduceWithForLoop() {
	/*
	 * We must specify the for loop for each pass through the array.
	 */
	NSArray *array = @[
    @0,
    @1,
    @2,
    ];

	NSInteger total = 0;
	for (NSNumber *number in array) {
		total += [number integerValue];
	}
	NSLog(@"My total: %ld", total);
	
	NSInteger minimum = NSIntegerMax;
	for (NSNumber *number in array) {
		minimum = MIN(minimum, [number integerValue]);
	}
	NSLog(@"My minimum: %ld", minimum);
}

void reduceWithFoundation() {
	/*
	 * We don't have to specify the for loop, but we still have mutable state.
	 */
	
    NSArray *array = @[
    @0,
    @1,
    @2,
    ];
	
	__block NSInteger total = 0;
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSNumber *number = obj;
		total += [number integerValue];
	}];
	NSLog(@"My total: %ld", total);
	
	__block NSInteger minimum = NSIntegerMax;
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSNumber *number = obj;
		minimum = MIN(minimum, [number integerValue]);
	}];
	NSLog(@"My minimum: %ld", minimum);
}

void reduceWithHBCollections() {
	/*
	 * We can get the total and minimum in a single line.
	 * (For some compiler sanity, I like casting to appropriate types)
	 * This gives better compiler warnings about unused variables, and
	 * removes mutable state.
	 */
	
    NSArray *array = @[
    @0,
    @1,
    @2,
    ];
	
	NSNumber *total = [array hb_reduceUsingBlock:^(id previousObj, id obj) {
		NSNumber *previousNumber = previousObj;
		NSNumber *number = obj;
		return (id) [NSNumber numberWithInteger:[previousNumber integerValue] + [number integerValue]];
	}
								 andInitialValue:@0];
	NSLog(@"My total: %@", total);
	
	NSNumber *minimum = [array hb_reduceUsingBlock:^(id previousObj, id obj) {
		NSNumber *previousNumber = previousObj;
		NSNumber *number = obj;
		return (id) [NSNumber numberWithInteger:MIN([previousNumber integerValue], [number integerValue])];
	}
								   andInitialValue:[NSNumber numberWithInteger:NSIntegerMax]];
	NSLog(@"My minimum: %@", minimum);
	
}

