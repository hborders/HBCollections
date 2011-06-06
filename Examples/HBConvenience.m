#import "NSArray+HBCollections.h"

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