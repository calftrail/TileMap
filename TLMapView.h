//
//  TLMapView.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TLMapProjection;


@interface TLMapView : NSView {
@private
	TLMapProjection* projection;
	NSRect desiredBounds;
	NSMutableArray* mapLayers;
}

@property (nonatomic, copy) TLMapProjection* projection;
@property (nonatomic, assign) NSRect desiredBounds;

@property (nonatomic, readonly) NSArray* mapLayers;
- (void)addMapLayer:(id)newMapLayer;

@end
