//
//  Character.m
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Character.h"
#import "TileMapInfo.h"


@implementation Character

@synthesize name;
@synthesize sprite;
@synthesize spriteSheet;
@synthesize direction;


// on "init" you need to initialize your instance
-(id) initWithName: (NSString*)characterName usingTileMap:(TileMapInfo*)theTileMapInfo withSpeed:(float)_speed
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        name= [characterName retain];
        
        // Determine tile offset.
        tileMapInfo= [theTileMapInfo retain];
        CGSize tileSize= tileMapInfo.tileMap.tileSize;
        
        NSString *spawnName= [name stringByAppendingString:@"SpawnPoint"];
        NSMutableDictionary *spawnPoint = [tileMapInfo.objects objectNamed:spawnName];
        NSAssert(spawnPoint != nil, [name stringByAppendingString:@" SpawnPoint not found"]);
        int x = [[spawnPoint valueForKey:@"x"] intValue]+tileSize.width;
        int y = [[spawnPoint valueForKey:@"y"] intValue]+tileSize.height/2;
        spawnPosition= ccp(x,y);
        currentTile= [tileMapInfo toTileCoordinate:sprite.position];
    }
    return self;
}

-(id) init
{
    // We do not support initialization without a name & tilemap.
    [self dealloc];
    @throw [NSException exceptionWithName:@"BNRBadInitCall" reason:@"Initialize TileMapInfo with initWithTMXFile:" userInfo:nil];
    return nil;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [tileMapInfo release];
    tileMapInfo= nil;
    
    [name release];
    name= nil;
    
    [super dealloc];
}

+(CGPoint)directionVector:(Direction)dir {
    switch(dir) {
        case kUp:    return ccp(0,1.0);
        case kDown:  return ccp(0, -1.0);
        case kLeft:  return ccp(-1.0, 0);
        case kRight: return ccp(1.0, 0);
        case kNone:  return ccp(0,0);
    }
    return ccp(0,0);
}

-(CGPoint)positionCleanup:(CGPoint)pos withDirection:(Direction)dir
{
    CGPoint tileCenter= [tileMapInfo tileCenterAtSpritePosition:pos];
    switch(dir) {
        case kUp:    return ccp(tileCenter.x, pos.y); break;
        case kDown:  return ccp(tileCenter.x, pos.y); break;
        case kLeft:  return ccp(pos.x, tileCenter.y); break;
        case kRight: return ccp(pos.x, tileCenter.y); break;
        case kNone:  return pos;            
    }
    return pos;
}


-(BOOL)isTraversingCenter:(CGPoint)oldPos withNewPosition:(CGPoint)newPos withDirectionVector:(CGPoint)dirVect
{
    CGPoint tileCenter= [tileMapInfo tileCenterAtSpritePosition:newPos];
    if(tileCenter.x == newPos.x && tileCenter.y == newPos.y) return YES;
    float x= (newPos.x-tileCenter.x) * (oldPos.x-tileCenter.x);
    float y= (newPos.y-tileCenter.y) * (oldPos.y-tileCenter.y);
    return fabsf(dirVect.x) > fabsf(dirVect.y) ? x < 0 : y < 0;
}


-(CGPoint)processIntersection:(CGPoint)newPosition
{    
    return newPosition;
}

-(CGPoint)processCollision:(CGPoint)newPosition
{
    direction= kNone;
    return [tileMapInfo tileCenterAtSpritePosition:sprite.position];
}


//=====================================================================
// Game loop update.
-(void)update:(ccTime)dt
{
    // compute new postion.
    CGPoint dirVect= [Character directionVector:direction];
    CGPoint deltaPosition= ccpMult(dirVect, speed*dt);
    CGPoint newPosition= ccpAdd(sprite.position, deltaPosition);
    newPosition= [self positionCleanup:newPosition withDirection:direction];
    
    // Determine if we have changed tile.
    if([self isTraversingCenter:sprite.position withNewPosition:newPosition withDirectionVector: dirVect]) {
        CGPoint tilePos= [tileMapInfo toTileCoordinate:newPosition];
        if(tilePos.x == 0) {
            newPosition= [tileMapInfo toSpritePosition:ccp([tileMapInfo mapSize].width-1,tilePos.y)];
        }
        else {
            if(tilePos.x == [tileMapInfo mapSize].width-1) {
                newPosition= [tileMapInfo toSpritePosition:ccp(0,tilePos.y)];
            }
            else {
                if([tileMapInfo isIntersectionAtSpritePosition:newPosition]) {
                    newPosition= [self processIntersection:newPosition];
                }                
            }
        }
    }
    
    // Process collisions.
    CGPoint collisionPosition= ccp(newPosition.x+tileMapInfo.tileSize.width*0.5f*dirVect.x, newPosition.y+tileMapInfo.tileSize.height*0.5f*dirVect.y);
    if([tileMapInfo isWallAtSpritePosition:collisionPosition]) {
        newPosition= [self processCollision:newPosition];
    }

    // Move sprite
    currentTile= [tileMapInfo toTileCoordinate:newPosition];
    sprite.position= newPosition;
}


@end
