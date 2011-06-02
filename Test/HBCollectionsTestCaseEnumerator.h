#import <Foundation/Foundation.h>

@class GHTestCase;

@interface HBCollectionsTestCaseEnumerator : NSEnumerator {
	
}

- (id) initWithTestCase: (GHTestCase *) testCase;

- (void)failWithException:(NSException*)exception;

@end
