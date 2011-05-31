@protocol HBCollection

- (NSEnumerator *) hb_mapEnumeratorUsingBlock:(id (^)(id obj)) block;
- (NSEnumerator *) hb_filterEnumeratorUsingBlock:(BOOL (^)(id obj)) block;
- (NSEnumerator *) hb_breakEnumeratorUsingBlock:(BOOL (^)(id obj)) block;

- (NSDictionary *) hb_allObjectsAsDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block;
- (NSMutableDictionary *) hb_allObjectsAsMutableDictionaryByMappingKeysToValuesWithBlock:(id (^)(id keyObj)) block;

- (NSDictionary *) hb_allObjectsAsDictionaryByMappingValuesToKeysWithBlock:(id (^)(id valueObj)) block;
- (NSMutableDictionary *) hb_allObjectsAsMutableDictionaryByMappingValuesToKeysWithBlock:(id (^)(id valueObj)) block;

@end
