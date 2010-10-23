//
//  NSAffineTransform+TLAdditions.h
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSAffineTransform (TLAdditions)
- (NSRect)tl_transformRect:(NSRect)aRect;
- (NSAffineTransform*)tl_inverseTransform;
@end
