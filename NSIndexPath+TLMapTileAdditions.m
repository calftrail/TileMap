//
//  NSIndexPath+TLMapTileAdditions.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSIndexPath+TLMapTileAdditions.h"


@implementation NSIndexPath (TLMapTileAdditions)

+ (NSIndexPath*)tl_indexPathForDetailLevel:(NSUInteger)detailLevel
									column:(NSUInteger)tileColumn
									   row:(NSUInteger)tileRow
{
	NSUInteger indexes[] = { detailLevel, tileColumn, tileRow };
	return [NSIndexPath indexPathWithIndexes:indexes length:3];
}

- (NSUInteger)tl_detailLevel { return [self indexAtPosition:0]; }
- (NSUInteger)tl_column { return [self indexAtPosition:1]; }
- (NSUInteger)tl_row { return [self indexAtPosition:2]; }

@end
