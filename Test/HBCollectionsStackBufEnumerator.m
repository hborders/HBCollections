#import "HBCollectionsStackBufEnumerator.h"
#import <GHUnit/GHUnit.h>

@interface HBCollectionsStackBufEnumerator()

@property (nonatomic) NSFastEnumerationState lastFastEnumerationState;

@end

@implementation HBCollectionsStackBufEnumerator

@synthesize elements = _elements;

@synthesize lastFastEnumerationState = _lastFastEnumerationState;

- (void) dealloc {
	self.elements = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state 
								  objects:(id *)stackbuf
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
