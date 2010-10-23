//
//  TLMapTileset.m
//  TileMap
//
//  Created by Nathan Vander Wilt on 10/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TLMapTileset.h"

static NSString* ObservationContext = @"TLMapTileset observation context";
static const NSInteger tl_NSHTTPURLResponseOK = 200;

@interface TLMapTileFetchOperation : NSOperation {
@private
	NSIndexPath* tilePath;
	TLMapTileset* tileset;
}
+ (id)fetchOperationForTile:(NSIndexPath*)theTilePath
				  ofTileset:(TLMapTileset*)theTileset;
@end

@interface TLMapTileset ()
- (void)updateTiles;
- (void)fetchOperationForTile:(NSIndexPath*)theTilePath
				 yieldedImage:(NSImage*)anImage
						error:(NSError*)anError;
@end


@implementation TLMapTileset

@dynamic projection;
@dynamic bounds;
@dynamic levelsOfDetail;
@dynamic tileHeight;
@dynamic tileWidth;

@synthesize delegate;
@synthesize visibleTiles;

- (id)init {
	self = [super init];
	if (self) {
		tileInformation = [[NSMapTable mapTableWithStrongToStrongObjects] retain];
		fetchQueue = [NSOperationQueue new];
		[self addObserver:self
			   forKeyPath:@"visibleTiles"
				  options:NSKeyValueObservingOptionNew
				  context:&ObservationContext];
		[self addObserver:self
			   forKeyPath:@"simultaneousFetchLimit"
				  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
				  context:&ObservationContext];
	}
	return self;
}

- (void)dealloc {
	delegate = nil;
	[visibleTiles release];
	[tileInformation release];
	[fetchQueue release];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString*)keyPath
					  ofObject:(id)object
						change:(NSDictionary*)change
					   context:(void*)context
{
    if (context == &ObservationContext) {
		if ([keyPath isEqualToString:@"visibleTiles"]) {
			[self updateTiles];
		}
		else if ([keyPath isEqualToString:@"simultaneousFetchLimit"]) {
			NSInteger fetchLimit = NSOperationQueueDefaultMaxConcurrentOperationCount;
			if ([self simultaneousFetchLimit]) {
				fetchLimit = MIN(NSIntegerMax, [self simultaneousFetchLimit]);
			}
			[fetchQueue setMaxConcurrentOperationCount:fetchLimit];
		}
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)updateTiles {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:NO];
	}
	
	NSMutableSet* knownTiles = [NSMutableSet
								setWithArray:NSAllMapTableKeys(tileInformation)];
	NSMutableSet* newTiles = [NSMutableSet setWithSet:(self.visibleTiles)];
	[newTiles minusSet:knownTiles];
	NSMutableSet* removedTiles = knownTiles; knownTiles = nil;
	[removedTiles minusSet:(self.visibleTiles)];
	
	for (NSIndexPath* removedTile in removedTiles) {
		id fetchStatus = [tileInformation objectForKey:removedTile];
		if ([fetchStatus isKindOfClass:[NSOperation class]]) {
			[fetchStatus cancel];
		}
		[tileInformation removeObjectForKey:removedTile];
	}
	
	for (NSIndexPath* newTile in newTiles) {
		NSOperation* op = [TLMapTileFetchOperation fetchOperationForTile:newTile
															   ofTileset:self];
		[fetchQueue addOperation:op];
		[tileInformation setObject:op forKey:newTile];
	}
}

- (void)mainThreadFetchRegistration:(NSDictionary*)fetchInfo {
	NSIndexPath* theTilePath = [fetchInfo objectForKey:@"tilePath"];
	NSImage* anImage = [fetchInfo objectForKey:@"image"];
	NSError* anError = [fetchInfo objectForKey:@"error"];
	if (anImage) {
		[tileInformation setObject:anImage forKey:theTilePath];
		[(self.delegate) mapTileset:self didFetchTile:theTilePath];
	}
	else if (anError) {
		NSLog(@"Error fetching %@: %@", theTilePath, anError);
		[tileInformation setObject:anError forKey:theTilePath];
	}
	else {
		[tileInformation removeObjectForKey:theTilePath];
	}
}

- (void)fetchOperationForTile:(NSIndexPath*)theTilePath
				 yieldedImage:(NSImage*)anImage
						error:(NSError*)anError
{
	if (![(self.visibleTiles) containsObject:theTilePath]) {
		//NSLog(@"Discarding fetched tile %@", theTilePath);
		return;
	}
	NSMutableDictionary* fetchInfo = [NSMutableDictionary dictionary];
	[fetchInfo setObject:theTilePath forKey:@"tilePath"];
	if (anImage) [fetchInfo setObject:anImage forKey:@"image"];
	if (anError) [fetchInfo setObject:anError forKey:@"error"];
	[self performSelectorOnMainThread:@selector(mainThreadFetchRegistration:)
						   withObject:fetchInfo
						waitUntilDone:NO];
}

- (NSImage*)imageForTileIfAvailable:(NSIndexPath*)tilePath {
	id fetchStatus = [tileInformation objectForKey:tilePath];
	NSImage* image = nil;
	if ([fetchStatus isKindOfClass:[NSImage class]]) {
		image = fetchStatus;
	}
	return image;
}

@end


@implementation TLMapTileset (TLMapTilesetSubclasses)

- (NSUInteger)simultaneousFetchLimit { return 0; }

- (NSURL*)urlForTile:(NSIndexPath*)tilePath {
	(void)tilePath;
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

- (NSImage*)getImageForTile:(NSIndexPath*)tilePath
					  error:(NSError**)err
{
	NSURL* tileURL = [self urlForTile:tilePath];
	//NSLog(@"Starting fetch %@", tilePath);
	// NOTE: see also NSURLRequestReloadIgnoringLocalCacheData / NSURLRequestReturnCacheDataElseLoad
	NSURLRequestCachePolicy policy = NSURLRequestUseProtocolCachePolicy;
	NSURLRequest* tileRequest = [NSURLRequest requestWithURL:tileURL
												 cachePolicy:policy
											 timeoutInterval:15.0];
	
	NSError* fetchError = nil;
	NSHTTPURLResponse* response = nil;
	NSData* imageData = [NSURLConnection sendSynchronousRequest:tileRequest
											  returningResponse:&response
														  error:&fetchError];
	//NSLog(@"Fetched %@ (%p / %@)", tileURL, imageData, fetchError);
	
	NSImage* image = nil;
	if (imageData && [response statusCode] == tl_NSHTTPURLResponseOK) {
		image = [[NSImage alloc] initWithData:imageData];
		[image autorelease];
		if (!image && err) {
			NSDictionary* errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									 tileURL, NSURLErrorKey,
									 @"Couldn't use returned tile data", NSLocalizedDescriptionKey, nil];
			*err = [NSError errorWithDomain:NSCocoaErrorDomain
									   code:NSFileReadCorruptFileError userInfo:errInfo];
		}
	}
	else if (err) {
		if (fetchError) {
			*err = fetchError;
		}
		else {
			NSString* description = [NSString stringWithFormat:@"Could not fetch tile (%@)",
									 [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]];
			NSDictionary* errInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									 tileURL, NSURLErrorKey,
									 description, NSLocalizedDescriptionKey, nil];
			*err = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:errInfo];
		}
	}
	return image;
}

@end


@implementation TLMapTileFetchOperation

- (id)initWithTile:(NSIndexPath*)theTilePath tileset:(id)theTileset {
	self = [super init];
	if (self) {
		tilePath = [theTilePath copy];
		tileset = [theTileset retain];
	}
	return self;
}

- (void)dealloc {
	[tilePath release];
	[tileset release];
	[super dealloc];
}

+ (id)fetchOperationForTile:(NSIndexPath*)theTilePath
				  ofTileset:(TLMapTileset*)theTileset
{
	TLMapTileFetchOperation* fetchOperation = [[TLMapTileFetchOperation alloc]
											   initWithTile:theTilePath tileset:theTileset];
	return [fetchOperation autorelease];
}

- (void)main {
	if ([self isCancelled]) return;
	NSError* error = nil;
	NSImage* image = [tileset getImageForTile:tilePath error:&error];
	[tileset fetchOperationForTile:tilePath yieldedImage:image error:error];
}

@end
