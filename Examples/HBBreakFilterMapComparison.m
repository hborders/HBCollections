#import "NSArray+HBCollections.h"
#import "NSEnumerator+HBCollections.h"

/*
 * Assume we have a command line function that converts single-number strings to english words,
 * ignores non-numbers,
 * and stops when it reaches @"EOF"
 *
 * I repeated the data structure boilerplate so that each example would be self-contained.
 */

void breakFilterMapWithForLoop() {
	NSCharacterSet *nonDecimalDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								@"zero", @"0",
								@"one", @"1",
								@"two", @"2",
								// etc
								nil];
	
	/*
	 * Three separate cases exist, each is difficult to test separately or inject as a dependency.
	 * Also, mutable state exists.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:@"0", @"a", @"2", @"EOF", @"1", nil];
	NSMutableArray *arrayInEnglish = [NSMutableArray array];
	for (NSString *string in array) {
		if ([string isEqualToString:@"EOF"]) {
			break;
		} else if ([string rangeOfCharacterFromSet:nonDecimalDigitCharacterSet].location == NSNotFound) {
			[arrayInEnglish addObject:[dictionary objectForKey:string]];
		}
	}
}

void breakFilterMapWithFoundation() {
	NSCharacterSet *nonDecimalDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								@"zero", @"0",
								@"one", @"1",
								@"two", @"2",
								// etc
								nil];
	
	/*
	 * Same issues as for loop:
	 * Three separate cases exist, each is difficult to test separately or inject as a dependency.
	 * Also, mutable state exists.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:@"0", @"a", @"2", @"EOF", @"1", nil];
	__block NSMutableArray *arrayInEnglish = [NSMutableArray array];
	[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSString *string = obj;
		if ([string isEqualToString:@"EOF"]) {
			*stop = YES;
		} else if ([string rangeOfCharacterFromSet:nonDecimalDigitCharacterSet].location == NSNotFound) {
			[arrayInEnglish addObject:[dictionary objectForKey:string]];
		}
	}];
	
	NSLog(@"arrayInEnglish: %@", arrayInEnglish); // prints "zero", "two"
}

void breakFilterMapWithHBCollections() {
	NSCharacterSet *nonDecimalDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								@"zero", @"0",
								@"one", @"1",
								@"two", @"2",
								// etc
								nil];
	
	/*
	 * Now, the individual rules have been broken into 3 separate block.
	 * Each block is easy to test and to inject into this function as a dependency.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:@"0", @"a", @"2", @"EOF", @"1", nil];
	NSArray *arrayInEnglish = [[[[array hb_breakEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [string isEqualToString:@"EOF"];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL) ([string rangeOfCharacterFromSet:nonDecimalDigitCharacterSet].location == NSNotFound);
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [dictionary objectForKey:string];
	}] allObjects];
	
	NSLog(@"arrayInEnglish: %@", arrayInEnglish); // prints "zero", "two"
}

void breakFilterMapWithHBCollectionsAsEnumerator() {
	NSCharacterSet *nonDecimalDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
								@"zero", @"0",
								@"one", @"1",
								@"two", @"2",
								// etc
								nil];
	
	/*
	 * In case you need to interface with code that requires fast enumeration,
	 * or you want open-ended lazy evaluation.
	 */
	
	NSArray *array = [NSArray arrayWithObjects:@"0", @"a", @"2", @"EOF", @"1", nil];
	NSEnumerator *enumeratorInEnglish = [[[array hb_breakEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [string isEqualToString:@"EOF"];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL) ([string rangeOfCharacterFromSet:nonDecimalDigitCharacterSet].location == NSNotFound);
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [dictionary objectForKey:string];
	}];
	
	/*
	 * At this point, nothing has been evaluated.  The enumerator has just been set up to evaluate lazily.
	 * We could use -allObjects to evaluate all results at once as in the previous example, or
	 * we could use -nextObject to evaluate results lazily, or 
	 * we could use fast enumeration to evaluate results traditionally.
	 *
	 * CAUTION: the enumerator is single-use only. Create a new one for each of the above cases.
	 */
							
	// prints "zero", "two"
	for (NSString *stringInEnglish in enumeratorInEnglish) {
		NSLog(@"stringInEnglish: %@", stringInEnglish);
	}
}