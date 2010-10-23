//
//  TLMapProjection.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapProjection.h"


@implementation TLMapProjection

/* NOTE: this class currently just implements
 the "Google Mercator" projection parameters (EPSG:3785)
 or a Plate Carée projection with the same sphere radius. */

static double EarthRadius = 6378137.0;
static double DegreesToRadians = M_PI / 180.0;
static double RadiansToDegrees = 180.0 / M_PI;

#if 1

- (NSPoint)projectCoordinate:(TLMapCoordinate)aCoordinate {
	double phi = aCoordinate.latitude * DegreesToRadians;
	double lamba = aCoordinate.longitude * DegreesToRadians;
	double x = lamba;
	double y = log(tan(M_PI/4.0 + phi/2.0));	// asinh(tan(phi));
	return NSMakePoint((CGFloat)(EarthRadius * x),
					   (CGFloat)(EarthRadius * y));
}

- (TLMapCoordinate)unprojectPoint:(NSPoint)aPoint {
	double x = aPoint.x / EarthRadius;
	double y = aPoint.y / EarthRadius;
	double phi = M_PI_2 - 2.0 * atan(exp(-y));	// atan(sinh(y));
	double lambda = x;
	return TLMapCoordinateMake(phi * RadiansToDegrees,
							   lambda * RadiansToDegrees);
}

#else

- (NSPoint)projectCoordinate:(TLMapCoordinate)aCoordinate {
	return NSMakePoint(aCoordinate.longitude * DegreesToRadians * EarthRadius,
					   aCoordinate.latitude * DegreesToRadians * EarthRadius);
}

- (TLMapCoordinate)unprojectPoint:(NSPoint)aPoint {
	return TLMapCoordinateMake(aPoint.y * RadiansToDegrees / EarthRadius,
							   aPoint.x * RadiansToDegrees / EarthRadius);
}

#endif

@end
