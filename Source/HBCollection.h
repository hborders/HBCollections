@protocol HBCollection

- (NSEnumerator *) hb_enumeratorUsingBlock:(void (^)(id obj)) block;
- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block;
- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj)) block;
- (NSEnumerator *) hb_breakEnumeratorUsingBlock:(BOOL (^)(id obj)) block;

- (id) hb_reduceUsingBlock:(id (^)(id previousObj, id obj)) block 
		   andInitialValue:(id) initialValue;

- (NSDictionary *) hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block;
- (NSMutableDictionary *) hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block;

- (NSDictionary *) hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:(id (^)(id valueObj)) block;
- (NSMutableDictionary *) hb_allObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock:(id (^)(id valueObj)) block;

@end
