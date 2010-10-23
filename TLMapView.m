//
//  TLMapView.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 8/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapView.h"

#import <QuartzCore/QuartzCore.h>
#import "TLMapProjection.h"

static NSString* TLMapViewKVOContext = @"TLMapView KVO context";

@interface TLMapView ()
- (NSRect)mapBoundsPaddedToFit:(NSRect)proposedBounds;
@end

@implementation TLMapView

@synthesize projection;
@synthesize desiredBounds;
@synthesize mapLayers;

- (void)addMapLayersObject:(id)newMapLayer { [mapLayers addObject:newMapLayer]; }
- (void)removeMapLayersObject:(id)l { (void)l; [self doesNotRecognizeSelector:_cmd]; }


#pragma mark Lifecyle

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		projection = [TLMapProjection new];
		desiredBounds = NSMakeRect(-180.0f, -90.0f, 360.0f, 180.0f);
		mapLayers = [NSMutableArray new];
		
		[self addObserver:self
			   forKeyPath:@"desiredBounds"
				  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
				  context:&TLMapViewKVOContext];
		[self addObserver:self
			   forKeyPath:@"frame"
				  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
				  context:&TLMapViewKVOContext];
    }
    return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"desiredBounds"];
	[self removeObserver:self forKeyPath:@"frame"];
	[projection release];
	[mapLayers release];
	[super dealloc];
}


#pragma mark Observation

- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void*)context
{
    if (context == &TLMapViewKVOContext) {
		if ([keyPath isEqualToString:@"desiredBounds"]) {
			/* NOTE: not using self.mapLayers avoids gcc-4.2 "type of accessor does
			 not match the type of property" error */
			for (NSView* mapLayer in [self mapLayers]) {
				[mapLayer setNeedsDisplay:YES];
			}
		}
		else if ([keyPath isEqualToString:@"frame"]) {
			for (NSView* mapLayer in [self mapLayers]) {
				mapLayer.frame = self.bounds;
			}
		}
	}
	else {
		[super observeValueForKeyPath:keyPath
							 ofObject:object
							   change:change
							  context:context];
	}
}


#pragma mark Map layer handling

- (NSRect)mapBoundsPaddedToFit:(NSRect)proposedBoundsRect {
	CGRect proposedBounds = NSRectToCGRect(proposedBoundsRect);
	NSView* fitView = self;
	CGFloat percentOfFrameWidth = proposedBounds.size.width / fitView.frame.size.width;
	CGFloat percentOfFrameHeight = proposedBounds.size.height / fitView.frame.size.height;
	CGRect paddedBounds = CGRectNull;
	if (percentOfFrameWidth < percentOfFrameHeight) {
		// proposedBounds aren't wide enough
		CGFloat properWidth = fitView.frame.size.width * percentOfFrameHeight;
		CGFloat difference = properWidth - proposedBounds.size.width;
		paddedBounds = CGRectInset(proposedBounds, -difference / 2.0f, 0.0f);
	}
	else if (percentOfFrameHeight < percentOfFrameWidth) {
		// proposedBounds aren't high enough
		CGFloat properHeight = fitView.frame.size.height * percentOfFrameWidth;
		CGFloat difference = properHeight - proposedBounds.size.height;
		paddedBounds = CGRectInset(proposedBounds, 0.0f, -difference / 2.0f);
	}
	else {
		paddedBounds = proposedBounds;
	}
	return NSRectFromCGRect(paddedBounds);
}

- (NSAffineTransform*)drawTransform {
	NSRect mapBounds = [self mapBoundsPaddedToFit:(self.desiredBounds)];
	NSRect myBounds = self.bounds;
	NSAffineTransform* drawTransform = [NSAffineTransform transform];
	[drawTransform translateXBy:(myBounds.origin.x)
							yBy:(myBounds.origin.y)];
	[drawTransform scaleXBy:(myBounds.size.width / mapBounds.size.width)
						yBy:(myBounds.size.height / mapBounds.size.height)];
	[drawTransform translateXBy:(-mapBounds.origin.x)
							yBy:(-mapBounds.origin.y)];
	return drawTransform;
}

- (void)registerMapLayer:(NSView*)newMapLayer {
	newMapLayer.frame = self.bounds;
	[self addSubview:newMapLayer];
}

- (void)addMapLayer:(id)newMapLayer {
	[self registerMapLayer:newMapLayer];
	[self addMapLayersObject:newMapLayer];
}

@end
