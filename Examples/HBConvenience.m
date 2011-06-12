#import "HBCollections.h"

void dictionariesFromArray() {
	NSArray *array = [NSArray arrayWithObjects:@"0", @"1", @"2", nil];
	
	id (^stringToNumberBlock)(id) = ^(id obj) {
		NSString *string = obj;
		return (id) [NSNumber numberWithInt:[string intValue]];
	};
	
	NSDictionary *arrayAsKeys = 
		[array hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:stringToNumberBlock];
	NSLog(@"arrayAsKeys: %@", arrayAsKeys);
	
	NSDictionary *arrayAsValues = 
		[array hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:stringToNumberBlock];
	NSLog(@"arrayAsValues: %@", arrayAsValues);
}

void enumeratorToMutableArray(NSEnumerator *enumerator) {
	NSMutableArray *mutableArray = [enumerator hb_allObjectsAsMutableArray];
	NSLog(@"Mutable array: %@", mutableArray);
}

void enumeratorToSet(NSEnumerator *enumerator) {
	NSSet *set = [enumerator hb_allObjectsAsSet];
	NSLog(@"Set: %@", set);
}

void enumeratorToMutableSet(NSEnumerator *enumerator) {
	NSMutableSet *mutableSet = [enumerator hb_allObjectsAsMutableSet];
	NSLog(@"Mutable set: %@", mutableSet);
}