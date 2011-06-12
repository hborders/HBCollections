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