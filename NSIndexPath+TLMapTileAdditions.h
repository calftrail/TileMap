//
//  NSIndexPath+TLMapTileAdditions.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSIndexPath (TLMapTileAdditions)
+ (NSIndexPath*)tl_indexPathForDetailLevel:(NSUInteger)detailLevel
									column:(NSUInteger)tileColumn
									   row:(NSUInteger)tileRow;

@property (readonly) NSUInteger tl_detailLevel;
@property (readonly) NSUInteger tl_column;
@property (readonly) NSUInteger tl_row;

@end
