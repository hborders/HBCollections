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

void enumerateWithForLoop() {
	
	/*
	 * The only reuse possible is within the loop body.
	 * Even though the fors are nearly identical, they must be specified every time.
	 */
	
	NSArray *array = @[
    @"0",
    @"1",
    @"2",
    ];
	for (NSString *string in array) {
		NSLog(@"processing my string: %@", string);
	}
	
	NSSet *set = [NSSet setWithObjects:@"0", @"1", @"2", nil];
	for (NSString *string in set) {
		NSLog(@"processing my string: %@", string);
	}
}

void enumerateWithFoundation() {
	/*
	 * Now, we don't have to specify the fors, but 
	 * the blocks can't be reused because they accept different parameters.
	 */
	
	NSArray *array = @[
    @"0",
    @"1",
    @"2",
    ];
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *string = obj;
		NSLog(@"processing my string: %@", string);
	}];
	
	NSSet *set = [NSSet setWithObjects:@"0", @"1", @"2", nil];
	[set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		NSString *string = obj;
		NSLog(@"processing my string: %@", string);
	}];
}

void enuemrateWithHBCollections() {
	/*
	 * With HBCollections, the blocks are re-usable, and we don't
	 * have you specify the fors.
	 */
	
	void (^processingMyStringBlock)(id) = ^(id obj) {
		NSString *string = obj;
		NSLog(@"processing my string: %@", string); 
	};
	
	NSArray *array = @[
    @"0",
    @"1",
    @"2",
    ];
	[[array hb_actionEnumeratorUsingBlock:processingMyStringBlock] hb_enumerate];
	
	NSSet *set = [NSSet setWithObjects:@"0", @"1", @"2", nil];
	[[set hb_actionEnumeratorUsingBlock:processingMyStringBlock] hb_enumerate];
	
	// we can even use the block on random enumerations.
	
	NSEnumerator *enumerator = [array objectEnumerator]; // this could have come from anywhere
	[[enumerator hb_actionEnumeratorUsingBlock:processingMyStringBlock] hb_enumerate];
}