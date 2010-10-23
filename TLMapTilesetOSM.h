//
//  TLMapTilesetOSM.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TLMapTileset.h"

@interface TLMapTilesetOSM : TLMapTileset {
@private
	TLMapProjection* projection;
	NSRect bounds;
}
@end
