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
 * Assume we have a command line function that converts single-number strings to english words,
 * ignores non-numbers,
 * and stops when it reaches @"EOF"
 *
 * I repeated the data structure boilerplate so that each example would be self-contained.
 */

void breakFilterMapWithForLoop() {
	NSCharacterSet *nonDecimalDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSDictionary *dictionary = @{
    @"0" : @"zero",
    @"1" : @"one",
    @"2" : @"two",
    //etc
    };
	
	/*
	 * Three separate cases exist, each is difficult to test separately or inject as a dependency.
	 * Also, mutable state exists.
	 */
	
    NSArray *array = @[
    @"0",
    @"a",
    @"2",
    @"EOF",
    @"1",
    ];
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
	NSDictionary *dictionary = @{
    @"0" : @"zero",
    @"1" : @"one",
    @"2" : @"two",
    //etc
    };
	
	/*
	 * Same issues as for loop:
	 * Three separate cases exist, each is difficult to test separately or inject as a dependency.
	 * Also, mutable state exists.
	 */
	
	NSArray *array = @[
    @"0",
    @"a",
    @"2",
    @"EOF",
    @"1",
    ];
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
	NSDictionary *dictionary = @{
    @"0" : @"zero",
    @"1" : @"one",
    @"2" : @"two",
    //etc
    };
	
	/*
	 * Now, the individual rules have been broken into 3 separate block.
	 * Each block is easy to test and to inject into this function as a dependency.
	 */
	
	NSArray *array = @[
    @"0",
    @"a",
    @"2",
    @"EOF",
    @"1",
    ];
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
	NSDictionary *dictionary = @{
    @"0" : @"zero",
    @"1" : @"one",
    @"2" : @"two",
    //etc
    };
	
	/*
	 * In case you need to interface with code that requires fast enumeration,
	 * or you want open-ended lazy evaluation.
	 */
	
	NSArray *array = @[
    @"0",
    @"a",
    @"2",
    @"EOF",
    @"1",
    ];
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