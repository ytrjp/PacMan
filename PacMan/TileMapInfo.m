//
//  TileMapInfo.m
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TileMapInfo.h"

#define DOT_ID  27
#define PILL_ID 28


@implementation TileMapInfo

@synthesize tileMap;
@synthesize objects;
@synthesize wallLayer;
@synthesize collectableLayer;
@synthesize mapSize;
@synthesize tileSize;


// on "init" you need to initialize your instance
-(id) initWithTMXFile: (NSString*)fileName
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init]) == nil) return nil;
        
    // Load tile map.
    tileMap= [[CCTMXTiledMap tiledMapWithTMXFile:fileName] retain];
    mapSize= tileMap.mapSize;
    tileSize= tileMap.tileSize;
    
    // Load all layers from the tile map.
    wallLayer= [[tileMap layerNamed:@"Walls"] retain];
    NSAssert(wallLayer != nil, @"Wall Layer not found");
    collectableLayer= [[tileMap layerNamed:@"Collectables"] retain];
    NSAssert(collectableLayer != nil, @"Collectable Layer not found");
        
    // Load all map related objects.
    objects= [[tileMap objectGroupNamed:@"Objects"] retain];
    NSAssert(objects != nil, @"TileMap Objects not found");
        
	return self;
}

-(id) init
{
    // We do not support initialization without a TMX file.
    [self dealloc];
    @throw [NSException exceptionWithName:@"BNRBadInitCall" reason:@"Initialize TileMapInfo with initWithTMXFile:" userInfo:nil];
    return nil;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    [objects release];
    objects= nil;
    
    [collectableLayer release];
    collectableLayer= nil;
    
    [wallLayer release];
    wallLayer= nil;
    
    [tileMap release];
    tileMap= nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(CGPoint)toSpritePosition:(CGPoint)tileCoord
{
    return ccp((tileCoord.x+0.5) * tileSize.width, (mapSize.height-tileCoord.y-0.5)*tileSize.height);
}

-(CGPoint)toTileCoordinate:(CGPoint)spritePosition
{
    return ccp(floorf(spritePosition.x/tileSize.width), mapSize.height-floorf(spritePosition.y/tileSize.height)-1.0f);
}

-(BOOL)isWallAtTileCoordinate:(CGPoint)tileCoord
{
    int gid= [wallLayer tileGIDAt:tileCoord];
    return gid != 0;
}

-(BOOL)isWallAtSpritePosition:(CGPoint)spritePosition
{
    return [self isWallAtTileCoordinate:[self toTileCoordinate:spritePosition]];
}

-(BOOL)isNavigableAtTileCoordinate:(CGPoint)tileCoord
{
    return ![self isWallAtTileCoordinate:tileCoord];
}

-(BOOL)isNavigableAtSpritePosition:(CGPoint)spritePosition
{
    return ![self isWallAtSpritePosition:spritePosition];
}

-(BOOL)isCollectableAtTileCoordinate:(CGPoint)tileCoord
{
    return [collectableLayer tileGIDAt:tileCoord] != 0;
}

-(BOOL)isCollectableAtSpritePosition:(CGPoint)spritePosition
{
    return [self isCollectableAtTileCoordinate:[self toTileCoordinate:spritePosition]];
}

-(BOOL)isDotAtTileCoordinate:(CGPoint)tileCoord
{
    NSLog(@"collectable gid= %d", [collectableLayer tileGIDAt:tileCoord]);
    return [collectableLayer tileGIDAt:tileCoord] == DOT_ID;
}

-(BOOL)isDotAtSpritePosition:(CGPoint)spritePosition
{
    return [self isDotAtTileCoordinate:[self toTileCoordinate:spritePosition]];
}

-(BOOL)isPillAtTileCoordinate:(CGPoint)tileCoord
{
    return [collectableLayer tileGIDAt:tileCoord] == PILL_ID;
}

-(BOOL)isPillAtSpritePosition:(CGPoint)spritePosition
{
    return [self isPillAtTileCoordinate:[self toTileCoordinate:spritePosition]];
}

-(void)clearCollectableAtTileCoordinate:(CGPoint)tileCoord
{
    [collectableLayer removeTileAt:tileCoord];
}

-(void)clearCollectableAtSpritePosition:(CGPoint)spritePosition
{
    [self clearCollectableAtTileCoordinate:[self toTileCoordinate:spritePosition]];
}

-(BOOL)isIntersectionAtTileCoordinate:(CGPoint)tileCoord
{
    BOOL left = tileCoord.x > 0 && [self isNavigableAtTileCoordinate:ccp(tileCoord.x-1, tileCoord.y)];
    BOOL right= tileCoord.x < mapSize.width && [self isNavigableAtTileCoordinate:ccp(tileCoord.x+1, tileCoord.y)];
    BOOL down = tileCoord.y > 0 && [self isNavigableAtTileCoordinate:ccp(tileCoord.x, tileCoord.y-1)];
    BOOL up   = tileCoord.y < mapSize.height && [self isNavigableAtTileCoordinate:ccp(tileCoord.x, tileCoord.y+1)];
    return (left || right) && (down || up);
}

-(BOOL)isIntersectionAtSpritePosition:(CGPoint)spritePosition
{
    return [self isIntersectionAtTileCoordinate:[self toTileCoordinate:spritePosition]];
}

-(CGPoint)tileCenterAtTileCoordinate:(CGPoint)tileCoord
{
    return [self toSpritePosition:tileCoord];
}

-(CGPoint)tileCenterAtSpritePosition:(CGPoint)spritePosition
{
    return [self tileCenterAtTileCoordinate:[self toTileCoordinate:spritePosition]];
}


-(CGPoint)resolveCollision:(CGPoint)spritePosition
{
    CGPoint tileCenter= [self tileCenterAtSpritePosition:spritePosition];
    if([self isWallAtSpritePosition:ccp(spritePosition.x+0.5*tileSize.width, spritePosition.y)]) {
        spritePosition= ccp(tileCenter.x, spritePosition.y);
    }
    if([self isWallAtSpritePosition:ccp(spritePosition.x-0.5*tileSize.width, spritePosition.y)]) {
        spritePosition= ccp(tileCenter.x, spritePosition.y);        
    }
    if([self isWallAtSpritePosition:ccp(spritePosition.x, spritePosition.y+0.5*tileSize.height)]) {
        spritePosition= ccp(spritePosition.x, tileCenter.y);
    }
    if([self isWallAtSpritePosition:ccp(spritePosition.x, spritePosition.y-0.5*tileSize.height)]) {
        spritePosition= ccp(spritePosition.x, tileCenter.y);
    }
    return spritePosition;
}

-(BOOL)areAllCollectablesTaken
{
    for(int x= 0; x < mapSize.width; ++x) {
        for(int y= 0; y < mapSize.height; ++y) {
            if([collectableLayer tileGIDAt:ccp(x,y)] != 0) {
                return NO;                
            }
        }
    }
    return YES;
}

@end
