#import "HBCollectionsTestCaseEnumerator.h"
#import <GHUnit/GHUnit.h>

@interface HBCollectionsTestCaseEnumerator()

@property (nonatomic, retain) GHTestCase *testCase;

@end

@implementation HBCollectionsTestCaseEnumerator

@synthesize testCase = _testCase;

- (id) init {
	return [self initWithTestCase:nil];
}

- (id) initWithTestCase: (GHTestCase *) testCase {
	if (self = [super init]) {
		self.testCase = testCase;
	}
	
	return self;
}

- (void) dealloc {
	self.testCase = nil;
	
	[super dealloc];
}

- (void)failWithException:(NSException*)exception {
	[self.testCase failWithException:exception];
}

@end
