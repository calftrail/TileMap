//
//  TLMapLayer.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TLMapProjection;

@protocol TLMapHost
@property (nonatomic, readonly) TLMapProjection* projection;
@property (nonatomic, readonly) NSAffineTransform* drawTransform;
@end

@interface NSView (TLMapLayerDevelopmentHack)
@property (nonatomic, readonly) id <TLMapHost> tl_mapHost;
@end
