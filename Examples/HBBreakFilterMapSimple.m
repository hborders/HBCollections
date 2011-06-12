/*
 
 Copyright (c) 2011, Heath Borders
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 Neither the name of the Heath Borders nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 
 */

#import "NSArray+HBCollections.h"
#import "HBCollections.h"

void map() {
	NSArray *strings = [NSArray arrayWithObjects:
					  @"0",
					  @"1",
					  @"2",
					  nil];
	NSArray *numbers = [[strings hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	}] allObjects];
	
	NSLog(@"%@", numbers);
}

void filterMap() {
	NSArray *strings = [NSArray arrayWithObjects:
						@"",
						@"0",
						@"1",
						@"2",
						nil];
	NSArray *numbers = [[[strings hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL) ([string length] > 0);
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	}] allObjects];
	
	NSLog(@"%@", numbers);
}

void mapThenFilterWithDifferentTypes() {
	NSArray *strings = [NSArray arrayWithObjects:
						@"0",
						@"1",
						@"2",
						nil];
	NSArray *evenNumbers = [[[strings hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		return (BOOL) ([number intValue] % 2 == 0);
	}] allObjects];
	
	NSLog(@"%@", evenNumbers);
}

void breakFilterMap() {
	NSArray *strings = [NSArray arrayWithObjects:
						@"",
						@"0",
						@"1",
						@"STOP HERE!!!!",
						@"2",
						nil];
	NSArray *onlyZeroAndOneNumbers = [[[[strings hb_breakEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [@"STOP HERE!!!!" isEqualToString:string];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL) ([string length] > 0);
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	}] allObjects];
	
	NSLog(@"%@", onlyZeroAndOneNumbers);
}

void breakFilterMapFastEnumeration() {
	NSArray *strings = [NSArray arrayWithObjects:
						@"",
						@"0",
						@"1",
						@"STOP HERE!!!!",
						@"2",
						nil];
	NSEnumerator *onlyZeroAndOneNumbers = [[[strings hb_breakEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [@"STOP HERE!!!!" isEqualToString:string];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL) ([string length] > 0);
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	}];
	
	for (NSNumber *number in onlyZeroAndOneNumbers) {
		NSLog(@"%@", number);	
	}
}

void breakFilterMapAction() {
	NSArray *strings = [NSArray arrayWithObjects:
						@"",
						@"0",
						@"1",
						@"STOP HERE!!!!",
						@"2",
						nil];
	NSEnumerator *alreadyLoggedNumbers = [[[[strings hb_breakEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [@"STOP HERE!!!!" isEqualToString:string];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL) ([string length] > 0);
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	}] hb_actionEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		NSLog(@"%@", number);
	}];
	
	for (NSNumber *number in alreadyLoggedNumbers) {
		NSLog(@"We logged %@ already, doing it a second time.", number);
	}
}

void breakFilterMapActionEnumerate() {
	NSArray *strings = [NSArray arrayWithObjects:
						@"",
						@"0",
						@"1",
						@"STOP HERE!!!!",
						@"2",
						nil];
	[[[[[strings hb_breakEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return [@"STOP HERE!!!!" isEqualToString:string];
	}] hb_filterEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (BOOL) ([string length] > 0);
	}] hb_mapEnumeratorUsingBlock:^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	}] hb_actionEnumeratorUsingBlock:^(id obj) {
		NSNumber *number = obj;
		NSLog(@"%@", number);
	}] hb_enumerate]; // we performed the enumerating in-line.
}