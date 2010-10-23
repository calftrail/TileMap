//
//  TLMapNavigationLayer.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapNavigationLayer.h"

#import "TLMapView.h"
#import "TLMapLayer.h"
#import "NSAffineTransform+TLAdditions.h"


@implementation TLMapNavigationLayer


- (NSAffineTransform*)transformFromViewToMap {
	return [[[self tl_mapHost] drawTransform] tl_inverseTransform];
}

- (void)mouseDown:(NSEvent*)theEvent {
	//NSLog(@"%@", theEvent);
	NSPoint mouseInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	draggedMapPoint = [[self transformFromViewToMap] transformPoint:mouseInView];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	//NSLog(@"%@", theEvent);
	NSPoint mouseInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSAffineTransform* viewToMap = [self transformFromViewToMap];
	NSPoint mouseInMap = [viewToMap transformPoint:mouseInView];
	
	NSRect mapBounds = [(TLMapView*)[self tl_mapHost] desiredBounds];
	NSRect newBounds = NSOffsetRect(mapBounds,
									draggedMapPoint.x - mouseInMap.x,
									draggedMapPoint.y - mouseInMap.y);
	[(TLMapView*)[self tl_mapHost] setDesiredBounds:newBounds];
}

- (void)mouseUp:(NSEvent*)theEvent {
	(void)theEvent;
	//NSLog(@"%@", theEvent);
}

- (void)panScroll:(NSEvent*)theEvent {
	NSPoint mouseInWindow = [theEvent locationInWindow];
	NSPoint scrollInWindow = NSMakePoint(mouseInWindow.x - [theEvent deltaX],
										 mouseInWindow.y + [theEvent deltaY]);
	NSPoint mouseInView = [self convertPoint:mouseInWindow fromView:nil];
	NSPoint scrollInView = [self convertPoint:scrollInWindow fromView:nil];
	
	NSSize movementInView = NSMakeSize(scrollInView.x - mouseInView.x,
									   scrollInView.y - mouseInView.y);
	NSSize movementInMap = [[self transformFromViewToMap] transformSize:movementInView];
	
	NSRect mapBounds = [(TLMapView*)[self tl_mapHost] desiredBounds];
	NSRect newBounds = NSOffsetRect(mapBounds, movementInMap.width, movementInMap.height);
	[(TLMapView*)[self tl_mapHost] setDesiredBounds:newBounds];
}

- (void)zoomScroll:(NSEvent*)theEvent {
	const CGFloat zoomScrollFactor = 1.0f / 50;
	CGFloat scaleAmount = (CGFloat)pow(2.0f, -zoomScrollFactor * [theEvent deltaY]);
	NSPoint mouseInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSPoint mouseInMap = [[self transformFromViewToMap] transformPoint:mouseInView];
	
	NSAffineTransform* t = [NSAffineTransform transform];
	[t translateXBy:mouseInMap.x yBy:mouseInMap.y];
	[t scaleBy:scaleAmount];
	[t translateXBy:(-mouseInMap.x) yBy:(-mouseInMap.y)];
	
	NSRect mapBounds = [(TLMapView*)[self tl_mapHost] desiredBounds];
	NSRect newBounds = [t tl_transformRect:mapBounds];
	[(TLMapView*)[self tl_mapHost] setDesiredBounds:newBounds];
	//NSLog(@"%@ -(%f)> %@", NSStringFromRect(mapBounds), scaleAmount, NSStringFromRect(newBounds));
}

- (void)scrollWheel:(NSEvent*)theEvent {
	if ([theEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask) {
		[self zoomScroll:theEvent];
	}
	else {
		[self panScroll:theEvent];	
	}
}

@end
