//
//  TLMapTileset.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class TLMapProjection;
@protocol TLMapTilesetDelegate;


@interface TLMapTileset : NSObject {
@private
	id delegate;
	NSSet* visibleTiles;
	NSMapTable* tileInformation;
	NSOperationQueue* fetchQueue;
}

@property (readonly) TLMapProjection* projection;
@property (readonly) NSRect bounds;

@property (readonly) NSUInteger levelsOfDetail;
@property (readonly) NSUInteger tileHeight;
@property (readonly) NSUInteger tileWidth;

@property (nonatomic, assign) id <TLMapTilesetDelegate> delegate;
@property (copy) NSSet* visibleTiles;
- (NSImage*)imageForTileIfAvailable:(NSIndexPath*)tilePath;

@end


@protocol TLMapTilesetDelegate
@optional
- (void)mapTileset:(TLMapTileset*)aTileset
	  didFetchTile:(NSIndexPath*)tilePath;
@end


@interface TLMapTileset (TLMapTilesetSubclasses)
@property (readonly) NSUInteger simultaneousFetchLimit;
- (NSURL*)urlForTile:(NSIndexPath*)tilePath;
- (NSImage*)getImageForTile:(NSIndexPath*)tilePath
					  error:(NSError**)err;
@end
