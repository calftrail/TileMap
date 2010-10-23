//
//  TLMapCoordinate.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 9/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

struct TLMapCoordinate {
	double latitude;
	double longitude;
};
typedef struct TLMapCoordinate TLMapCoordinate;

NS_INLINE TLMapCoordinate TLMapCoordinateMake(double latitude, double longitude);


#pragma mark Inline function definitions

NS_INLINE TLMapCoordinate TLMapCoordinateMake(double latitude, double longitude) {
	return (TLMapCoordinate){ .latitude = latitude, .longitude = longitude };
}
