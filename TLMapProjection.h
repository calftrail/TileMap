//
//  TLMapProjection.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TLMapCoordinate.h"

@interface TLMapProjection : NSObject {}

- (NSPoint)projectCoordinate:(TLMapCoordinate)aCoordinate;
- (TLMapCoordinate)unprojectPoint:(NSPoint)aPoint;

@end
