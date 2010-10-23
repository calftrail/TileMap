//
//  NSAffineTransform+TLAdditions.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSAffineTransform+TLAdditions.h"

NS_INLINE NSRect tl_NSFlipRect(NSRect aRect);

@implementation NSAffineTransform (TLAdditions)

- (NSRect)tl_transformRect:(NSRect)aRect {
	NSRect rect = (NSRect){
		.origin = [self transformPoint:(aRect.origin)],
		.size = [self transformSize:(aRect.size)]
	};
	return rect.size.height > 0.0 ? rect : tl_NSFlipRect(rect);
}

- (NSAffineTransform*)tl_inverseTransform {
	NSAffineTransform* inverse = [self copy];
	[inverse invert];
	return [inverse autorelease];
}

@end

NS_INLINE NSRect tl_NSFlipRect(NSRect aRect) {
	return NSMakeRect(aRect.origin.x,
					  aRect.origin.y + aRect.size.height,
					  aRect.size.width,
					  -aRect.size.height);
}
