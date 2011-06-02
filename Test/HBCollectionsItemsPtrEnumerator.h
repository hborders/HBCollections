#import <Foundation/Foundation.h>
#import "HBCollectionsTestCaseEnumerator.h"

@interface HBCollectionsItemsPtrEnumerator : HBCollectionsTestCaseEnumerator {
}

@property (nonatomic, copy) NSArray *(^elementsFactoryBlock)(NSUInteger stackBufLen);

@end
