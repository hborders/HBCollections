/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import "HBCollectionsStackBufEnumerator.h"
#import <GHUnit/GHUnit.h>

@interface HBCollectionsStackBufEnumerator()

@property (nonatomic) NSFastEnumerationState lastFastEnumerationState;

@end

@implementation HBCollectionsStackBufEnumerator

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id __unsafe_unretained [])stackbuf
									count:(NSUInteger)len {
	static unsigned long mutationsPtr = 0;
	switch (state->state) {
		case 0: {
			GHAssertGreaterThanOrEqual(len, [self.elements count], @"len should be %d or larger", [self.elements count]);
			
			NSFastEnumerationState lastFastEnumerationState = { 0 };
			state->state = lastFastEnumerationState.state = 1;
			state->itemsPtr = lastFastEnumerationState.itemsPtr = stackbuf;
			state->mutationsPtr = lastFastEnumerationState.mutationsPtr = &mutationsPtr;
			state->extra[0] = lastFastEnumerationState.extra[0] = 10;
			state->extra[1] = lastFastEnumerationState.extra[1] = 11;
			state->extra[2] = lastFastEnumerationState.extra[2] = 12;
			state->extra[3] = lastFastEnumerationState.extra[3] = 13;
			state->extra[4] = lastFastEnumerationState.extra[4] = 14;
			
			[self.elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				stackbuf[idx] = obj;
			}];
			
			self.lastFastEnumerationState = lastFastEnumerationState;
			
			return [self.elements count];
		}
		case 1:
			GHAssertEquals(state->state, self.lastFastEnumerationState.state, nil);
			GHAssertEquals(state->itemsPtr, self.lastFastEnumerationState.itemsPtr, nil);
			GHAssertEquals(state->mutationsPtr, self.lastFastEnumerationState.mutationsPtr, nil);
			GHAssertEquals(state->extra[0], self.lastFastEnumerationState.extra[0], nil);
			GHAssertEquals(state->extra[1], self.lastFastEnumerationState.extra[1], nil);
			GHAssertEquals(state->extra[2], self.lastFastEnumerationState.extra[2], nil);
			GHAssertEquals(state->extra[3], self.lastFastEnumerationState.extra[3], nil);
			GHAssertEquals(state->extra[4], self.lastFastEnumerationState.extra[4], nil);
			
			state->state = 2;
			
			return 0;
		default:
			GHFail(@"Invalid state: %d", state->state);
			return 0;
	}
}

@end
