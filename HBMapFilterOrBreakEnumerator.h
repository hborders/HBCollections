#import <Foundation/Foundation.h>

typedef void (^HBMapFilterOrBreakBlock)(id obj, 
										id *mappedObjPtr,
										BOOL *shouldFilterPtr, 
										BOOL *shouldBreakPtr);

@interface HBMapFilterOrBreakEnumerator : NSEnumerator {
}

@property (nonatomic) NSUInteger hb_allObjectsSizeHint;

- (id) initWithMapFilterOrBreakeeEnumerator: (NSEnumerator *) mapFilterOrBreakeeEnumerator
				  andMapFilterOrBreakBlocks: (NSArray *) mapFilterOrBreakBlocks;

- (id) initWithMapFilterOrBreakeeEnumerator: (NSEnumerator *) mapFilterOrBreakeeEnumerator
				  andMapFilterOrBreakBlocks: (NSArray *) mapFilterOrBreakBlocks
					  andAllObjectsSizeHint: (NSUInteger) allObjectsSizeHint;

- (HBMapFilterOrBreakEnumerator *) hb_addMapFilterOrBreakBlock: (HBMapFilterOrBreakBlock) mapFilterOrBreakBlock;

@end
