//
//  TLMapTileLayer.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapTileLayer.h"

#import <QuartzCore/QuartzCore.h>
#import "NSAffineTransform+TLAdditions.h"
#import "NSIndexPath+TLMapTileAdditions.h"

#import "TLMapProjection.h"
#import "TLMapLayer.h"
#import "TLMapTilesetOSM.h"

NS_INLINE NSRect TLMapTileRect(NSIndexPath* tilePath);

@interface TLMapTileLayer () <TLMapTilesetDelegate>
@end

@implementation TLMapTileLayer

- (id)init {
	self = [super init];
	if (self) {
		tileset = [TLMapTilesetOSM new];
		[tileset setDelegate:self];
	}
	return self;
}

- (void)dealloc {
	[tileset release];
	[super dealloc];
}

- (TLMapTileset*)currentTileset {
	return tileset;
}

- (NSAffineTransform*)transformFromMapToTilespace:(NSUInteger)detailLevel {
	NSAffineTransform* transform = [NSAffineTransform transform];
	NSUInteger numTilesAlongEdge = 1 << detailLevel;
	NSRect tileBounds = self.currentTileset.bounds;
	
	// tile space is flipped
	[transform translateXBy:0.0f yBy:(CGFloat)numTilesAlongEdge];
	[transform scaleXBy:1.0f yBy:-1.0f];
	
	// fit map space to tile space
	[transform scaleBy:(CGFloat)numTilesAlongEdge];
	[transform scaleXBy:(1.0f / tileBounds.size.width)
					yBy:(1.0f / tileBounds.size.height)];
	[transform translateXBy:(-tileBounds.origin.x)
						yBy:(-tileBounds.origin.y)];
	
	return transform;
}

- (NSUInteger)currentDetailLevel {
	const double levelAdjustment = 0.0;
	
	// find how much of the map each unit (pixel) needs
	NSSize unitSize = NSMakeSize(1.0f, 1.0f);
	NSSize unitSizeInView = [self convertSizeFromBase:unitSize];
	NSAffineTransform* viewToMap = [[self tl_mapHost] drawTransform];
	[viewToMap invert];
	NSSize unitSizeOnMap = [viewToMap transformSize:unitSizeInView];
	
	// find how much of the map a pixel in tileset's level 0 contains
	NSRect tileBounds = self.currentTileset.bounds;
	NSUInteger tilePixelWidth = self.currentTileset.tileHeight;
	NSUInteger tilePixelHeight = self.currentTileset.tileWidth;
	NSSize pixelSize = NSMakeSize((tileBounds.size.width / (CGFloat)tilePixelWidth),
								  (tileBounds.size.height / (CGFloat)tilePixelHeight));
	
	// determine detail level
	double factorNeeded = MAX((pixelSize.width / unitSizeOnMap.width),
							  (pixelSize.height / unitSizeOnMap.height));
	double exactDetailLevel = log2(factorNeeded);
	NSInteger unclampedLevel = lround(exactDetailLevel + levelAdjustment);
	NSUInteger maxLevel = self.currentTileset.levelsOfDetail - 1;
	return MIN(maxLevel, MAX(0, unclampedLevel));
}

- (NSAffineTransform*)transformFromTilesToView {
	NSUInteger detailLevel = [self currentDetailLevel];
	NSAffineTransform* tilesToMap = [[self transformFromMapToTilespace:detailLevel]
									 tl_inverseTransform];
	NSAffineTransform* mapToView = [[self tl_mapHost] drawTransform];
	
	NSAffineTransform* tilesToView = [NSAffineTransform transform];
	[tilesToView appendTransform:tilesToMap];
	[tilesToView appendTransform:mapToView];
	return tilesToView;
}

- (NSSet*)tilesInViewRect:(NSRect)rect {
	NSAffineTransform* tilesToDrawing = [self transformFromTilesToView];
	NSRect tilesRect = [[tilesToDrawing tl_inverseTransform] tl_transformRect:rect];
	
	NSMutableSet* tilesInRect = [NSMutableSet set];
	NSUInteger detailLevel = [self currentDetailLevel];
	NSUInteger tileLimit = 1 << detailLevel;
	NSInteger minTileX = (NSInteger)MAX(0, floor(tilesRect.origin.x));
	NSInteger maxTileX = (NSInteger)MIN(tileLimit,
										ceil(tilesRect.origin.x + tilesRect.size.width));
	NSInteger minTileY = (NSInteger)MAX(0, floor(tilesRect.origin.y));
	NSInteger maxTileY = (NSInteger)MIN(tileLimit,
										ceil(tilesRect.origin.y + tilesRect.size.height));
	for (NSInteger tileX = minTileX; tileX < maxTileX; ++tileX) {
		for (NSInteger tileY = minTileY; tileY < maxTileY; ++tileY) {
			NSIndexPath* tilePath = [NSIndexPath tl_indexPathForDetailLevel:detailLevel
																	 column:tileX
																		row:tileY];
			[tilesInRect addObject:tilePath];
		}
	}
	return tilesInRect;
}

- (void)drawRect:(NSRect)rect {
	NSSet* visibleTiles = [self tilesInViewRect:[self visibleRect]];
	[(self.currentTileset) setVisibleTiles:visibleTiles];
	//NSLog(@"%@", visibleTiles);
	
	NSSet* redrawnTiles = [self tilesInViewRect:rect];
	NSAffineTransform* tilesToDrawing = [self transformFromTilesToView];
	for (NSIndexPath* tilePath in redrawnTiles) {
		NSRect tileRect = TLMapTileRect(tilePath);
		NSRect targetRect = [tilesToDrawing tl_transformRect:tileRect];
		NSImage* tileImage = [(self.currentTileset) imageForTileIfAvailable:tilePath];
		[tileImage drawInRect:targetRect
					 fromRect:NSZeroRect
					operation:NSCompositeCopy
					 fraction:1.0f];
	}
}

- (void)mapTileset:(TLMapTileset*)aTileset
	  didFetchTile:(NSIndexPath*)tilePath
{
	(void)aTileset;
	if (tilePath.tl_detailLevel == [self currentDetailLevel]) {
		NSRect redrawRect = [[self transformFromTilesToView]
							 tl_transformRect:TLMapTileRect(tilePath)];
		[self setNeedsDisplayInRect:redrawRect];
	}
}

@end


NS_INLINE NSRect TLMapTileRect(NSIndexPath* tilePath) {
	return NSMakeRect(tilePath.tl_column, tilePath.tl_row, 1.0f, 1.0f);
}
