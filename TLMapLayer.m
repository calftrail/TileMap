//
//  TLMapLayer.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapLayer.h"


@implementation NSView (TLMapLayerDevelopmentHack)

- (id <TLMapHost>)tl_mapHost {
	return (id <TLMapHost>)[self superview];
}

@end
