//
//  TLMapTilesetOSM.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapTilesetOSM.h"

#import "NSIndexPath+TLMapTileAdditions.h"

#import "TLMapSimpleLayer.h"
#import "TLMapProjection.h"


@implementation TLMapTilesetOSM

@synthesize projection;
@synthesize bounds;
- (NSUInteger)levelsOfDetail { return 16; }
- (NSUInteger)tileHeight { return 256; }
- (NSUInteger)tileWidth { return 256; }
- (NSUInteger)simultaneousFetchLimit { return 2; }

- (id)init {
	self = [super init];
	if (self) {
		projection = [TLMapProjection new];
		bounds = [TLMapSimpleLayer fakeProjectShape:[TLMapSimpleLayer worldBounds]
									 withProjection:projection];
	}
	return self;
}

- (void)dealloc {
	[projection release];
	[super dealloc];
}

- (NSURL*)urlForTile:(NSIndexPath*)tilePath {
	NSURL* baseURL = [NSURL URLWithString:@"http://tile.openstreetmap.org/"];
	//NSURL* baseURL = [NSURL URLWithString:@"http://example.com"];
	NSString* path = [NSString stringWithFormat:@"%u/%u/%u.png",
					  [tilePath tl_detailLevel], [tilePath tl_column], [tilePath tl_row]];
	return [NSURL URLWithString:path relativeToURL:baseURL];
}

@end
