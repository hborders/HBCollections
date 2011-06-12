#import "HBCollections.h"

void enumerateWithForLoop() {
	
	/*
	 * The only reuse possible is within the loop body.
	 * Even though the fors are nearly identical, they must be specified every time.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:@"0", @"1", @"2", nil];
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
	
	NSArray *array = [NSArray arrayWithObjects:@"0", @"1", @"2", nil];
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
	
	NSArray *array = [NSArray arrayWithObjects:@"0", @"1", @"2", nil];
	[[array hb_actionEnumeratorUsingBlock:processingMyStringBlock] hb_enumerate];
	
	NSSet *set = [NSSet setWithObjects:@"0", @"1", @"2", nil];
	[[set hb_actionEnumeratorUsingBlock:processingMyStringBlock] hb_enumerate];
	
	// we can even use the block on random enumerations.
	
	NSEnumerator *enumerator = [array objectEnumerator]; // this could have come from anywhere
	[[enumerator hb_actionEnumeratorUsingBlock:processingMyStringBlock] hb_enumerate];
}