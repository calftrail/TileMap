//
//  TLMapSimpleLayer.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapSimpleLayer.h"

#import <QuartzCore/QuartzCore.h>
#import "TLMapProjection.h"
#import "TLMapLayer.h"
#import "NSAffineTransform+TLAdditions.h"

@implementation TLMapSimpleLayer

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		self.wantsLayer = YES;
		self.layer.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

+ (NSRect)mercatorSquare {
	static double RadiansToDegrees = 180.0 / M_PI;
	CGFloat n = (CGFloat)(atan(sinh(M_PI)) * RadiansToDegrees);
	CGFloat s = (CGFloat)(-atan(sinh(M_PI)) * RadiansToDegrees);
	CGFloat e = 180.0f;
	CGFloat w = -180.0f;
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)worldBounds {
	CGFloat n = 90.0f;
	CGFloat s = -90.0f;
	CGFloat e = 180.0f;
	CGFloat w = -180.0f;
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)conusBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_the_United_States
	CGFloat n = +49 + ((23 + (4 / 60.0f)) / 60.0f);		// Lake of the Woods, Minnesota
	CGFloat s = +25 + ((7 + (6 / 60.0f)) / 60.0f);		// Cape Sable, Florida
	CGFloat e = -66 - (57 / 60.0f);						// West Quoddy Head, Maine
	CGFloat w = -124 - ((43 + (59 / 60.0f)) / 60.0f);	// Cape Alava, Washington
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)africaBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_Africa#Extreme_points
	CGFloat n = +37 + (21 / 60.0f);						// Ras ben Sakka, Tunisia
	CGFloat s = -34 - (50 / 60.0f);						// Cape Agulhas, South Africa
	CGFloat e = +51 + ((27 + (52 / 60.0f)) / 60.0f);	// Ras Hafun, Somalia
	CGFloat w = -17 - ((33 + (22 / 60.0f)) / 60.0f);	// Pointe des Almadies, Senegal
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)europeBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_Europe
	CGFloat n = +71 + ((8 + (3 / 60.0f)) / 60.0f);		// Cape Nordkinn, Norway
	CGFloat s = +36;									// Punta de Tarifa, Spain
	CGFloat e = +68 + (11 / 60.0f);						// mouth of Bajdarata river
	CGFloat w = -9 - ((30 + (3 / 60.0f)) / 60.0f);		// Cabo da Roca, Portugal
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)asiaBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_Asia#Extreme_points
	CGFloat n = +77 + (43 / 60.0f);						// Cape Chelyuskin, Russia
	CGFloat s = +1 + (16 / 60.0f);						// Cape Piai, Malaysia
	//CGFloat e = -169 - (40 / 60.0f);					// Cape Dezhnev, Russia
	CGFloat e = +180.0f;								// Anti-meridian
	CGFloat w = +26 + (4 / 60.0f);						// Cape Baba, Turkey
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)australiaBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_Australia
	CGFloat n = -10 - (41 / 60.0f);						// Cape York, Queensland
	CGFloat s = -39 - (8 / 60.0f);						// Wilsons Promontory, Victoria
	CGFloat e = +153 + (38 / 60.0f);					// Cape Byron, New South Wales
	CGFloat w = +113 + (9 / 60.0f);						// Steep Point, Western Australia
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)southAmericaBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_South_America
	CGFloat n = +12 + ((27 + (31 / 60.0f)) / 60.0f);	// Punta Gallinas, Colombia
	CGFloat s = -53 - ((53 + (47 / 60.0f)) / 60.0f);	// Cape Froward, Chile
	CGFloat e = -34 - ((47 + (35 / 60.0f)) / 60.0f);	// Ponta do Seixas, Brazil
	CGFloat w = -81 - ((19 + (43 / 60.0f)) / 60.0f);	// Punta Pariñas, Peru
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)northAmericaBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_North_America
	CGFloat n = +71 + (58 / 60.0f);						// Boothia Peninsula, Nunavut
	CGFloat s = +7 + ((10 + (29 / 60.0f)) / 60.0f);		// Punta Mariato, Panama
	CGFloat e = -55 - ((37 + (15 / 60.0f)) / 60.0f);	// Cape St Charles, Labrador
	CGFloat w = -168 - (5 / 60.0f);						// Cape Prince of Wales, Alaska
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)antarcticaBounds {
	// from http://en.wikipedia.org/wiki/Extreme_points_of_Antarctica
	CGFloat n = -63 - (23 / 60.0f);						// Hope Bay, Antarctic Peninsula
	CGFloat s = -90.0f;									// South Pole
	CGFloat e = +180.0f;								// Anti-meridian
	CGFloat w = -180.0f;								// Anti-meridian
	return NSMakeRect(w, s, e-w, n-s);
}

+ (NSRect)fakeProjectShape:(NSRect)shape
			withProjection:(TLMapProjection*)proj
{
	shape = NSIntersectionRect(shape, [[self class] mercatorSquare]);
	NSPoint bottomLeft = [proj projectCoordinate:
						  TLMapCoordinateMake(shape.origin.y,
											  shape.origin.x)];
	NSPoint topRight = [proj projectCoordinate:
						TLMapCoordinateMake(shape.origin.y + shape.size.height,
											shape.origin.x + shape.size.width)];
	return NSMakeRect(bottomLeft.x, bottomLeft.y,
					  topRight.x - bottomLeft.x, topRight.y - bottomLeft.y);
}

- (void)drawShape:(NSRect)shape {
	TLMapProjection* proj = [[self tl_mapHost] projection];
	NSRect projShape = [[self class] fakeProjectShape:shape
									   withProjection:proj];
	NSBezierPath* projectedPath = [NSBezierPath bezierPathWithRect:projShape];
	
	NSAffineTransform* t = [[self tl_mapHost] drawTransform];
	[[t transformBezierPath:projectedPath] fill];
}

- (void)drawRect:(NSRect)rect {
	(void)rect;
	NSRect shape = NSZeroRect;
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	CGContextSetAlpha([[NSGraphicsContext currentContext] graphicsPort], 0.125f);
	
	[[NSColor blueColor] setFill];
	shape = [[self class] worldBounds];
	//[self drawShape:shape];
	
	[[NSColor redColor] setFill];
	shape = [[self class] northAmericaBounds];
	[self drawShape:shape];
	
	[[NSColor yellowColor] setFill];
	shape = [[self class] asiaBounds];
	[self drawShape:shape];
	
	[[NSColor blackColor] setFill];
	shape = [[self class] australiaBounds];
	[self drawShape:shape];
	
	[[NSColor brownColor] setFill];
	shape = [[self class] africaBounds];
	[self drawShape:shape];
	
	[[NSColor whiteColor] setFill];
	shape = [[self class] europeBounds];
	[self drawShape:shape];
	
	[[NSColor greenColor] setFill];
	shape = [[self class] southAmericaBounds];
	[self drawShape:shape];
	
	[[NSColor grayColor] setFill];
	shape = [[self class] antarcticaBounds];
	[self drawShape:shape];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end
