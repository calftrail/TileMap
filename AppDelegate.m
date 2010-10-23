//
//  AppDelegate.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "TLMapView.h"
#import "TLMapSimpleLayer.h"
#import "TLMapTileLayer.h"
#import "TLMapNavigationLayer.h"


@interface NSObject (TLAdditions)
+ (id)tl_make;
@end


@implementation AppDelegate

@synthesize map;

- (void)awakeFromNib {
	[self.map addMapLayer:[TLMapTileLayer tl_make]];
	//[self.map addMapLayer:[TLMapSimpleLayer tl_make]];
	[self.map addMapLayer:[TLMapNavigationLayer tl_make]];
	self.map.desiredBounds = [TLMapSimpleLayer fakeProjectShape:[TLMapSimpleLayer worldBounds]
												 withProjection:(map.projection)];
}

- (void)dealloc {
	[map release];
	[super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication {
	(void)theApplication;
	return YES;
}

@end


@implementation NSObject (TLAdditions)

+ (id)tl_make {
	return [[[self class] new] autorelease];
}

@end
