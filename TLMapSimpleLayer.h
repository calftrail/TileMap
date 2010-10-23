//
//  TLMapSimpleLayer.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TLMapProjection;

@interface TLMapSimpleLayer : NSView {}
+ (NSRect)worldBounds;
+ (NSRect)fakeProjectShape:(NSRect)shape
			withProjection:(TLMapProjection*)proj;
@end
