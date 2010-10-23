//
//  AppDelegate.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 8/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TLMapView;

@interface AppDelegate : NSObject {
@private
	TLMapView* map;
}

@property (nonatomic, assign) IBOutlet TLMapView* map;

@end
