#import "NSArray+HBCollections.h"

void reduceWithForLoop() {
	/*
	 * We must specify the for loop for each pass through the array.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:
					  [NSNumber numberWithInt:0],
					  [NSNumber numberWithInt:1], 
					  [NSNumber numberWithInt:2],
					  nil];

	NSInteger total = 0;
	for (NSNumber *number in array) {
		total += [number integerValue];
	}
	NSLog(@"My total: %d", total);
	
	NSInteger minimum = NSIntegerMax;
	for (NSNumber *number in array) {
		minimum = MIN(minimum, [number integerValue]);
	}
	NSLog(@"My minimum: %d", minimum);
}

void reduceWithFoundation() {
	/*
	 * We don't have to specify the for loop, but we still have mutable state.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:
					  [NSNumber numberWithInt:0],
					  [NSNumber numberWithInt:1], 
					  [NSNumber numberWithInt:2],
					  nil];
	
	__block NSInteger total = 0;
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSNumber *number = obj;
		total += [number integerValue];
	}];
	NSLog(@"My total: %d", total);
	
	__block NSInteger minimum = NSIntegerMax;
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSNumber *number = obj;
		minimum = MIN(minimum, [number integerValue]);
	}];
	NSLog(@"My minimum: %d", minimum);
}

void reduceWithHBCollections() {
	/*
	 * We can get the total and minimum in a single line.
	 * (For some compiler sanity, I like casting to appropriate types)
	 * This gives better compiler warnings about unused variables, and
	 * removes mutable state.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:
					  [NSNumber numberWithInt:0],
					  [NSNumber numberWithInt:1], 
					  [NSNumber numberWithInt:2],
					  nil];
	
	NSNumber *total = [array hb_reduceUsingBlock:^(id previousObj, id obj) {
		NSNumber *previousNumber = previousObj;
		NSNumber *number = obj;
		return (id) [NSNumber numberWithInteger:[previousNumber integerValue] + [number integerValue]];
	}
								 andInitialValue:[NSNumber numberWithInt:0]];
	NSLog(@"My total: %@", total);
	
	NSNumber *minimum = [array hb_reduceUsingBlock:^(id previousObj, id obj) {
		NSNumber *previousNumber = previousObj;
		NSNumber *number = obj;
		return (id) [NSNumber numberWithInteger:MIN([previousNumber integerValue], [number integerValue])];
	}
								   andInitialValue:[NSNumber numberWithInteger:NSIntegerMax]];
	NSLog(@"My minimum: %@", minimum);
	
}

