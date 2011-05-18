//
//  TileMapInfo.h
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface TileMapInfo : NSObject {
    CCTMXTiledMap       *tileMap;
    CCTMXObjectGroup    *objects;
    CCTMXLayer          *wallLayer;
    CCTMXLayer          *collectableLayer;
    CGSize              mapSize;
    CGSize              tileSize;
}

@property (readonly,nonatomic) CCTMXTiledMap    *tileMap;
@property (readonly,nonatomic) CCTMXObjectGroup *objects;
@property (readonly,nonatomic) CCTMXLayer       *wallLayer;
@property (readonly,nonatomic) CCTMXLayer       *collectableLayer;
@property (readonly,nonatomic) CGSize           mapSize;
@property (readonly,nonatomic) CGSize           tileSize;

-(CGPoint)toTileCoordinate:(CGPoint)spritePosition;
-(CGPoint)toSpritePosition:(CGPoint)tileCoord;

-(BOOL)areAllCollectablesTaken;

-(BOOL)isWallAtTileCoordinate:(CGPoint)tileCoord;
-(BOOL)isCollectableAtTileCoordinate:(CGPoint)tileCoord;
-(BOOL)isDotAtTileCoordinate:(CGPoint)tileCoord;
-(BOOL)isPillAtTileCoordinate:(CGPoint)tileCoord;
-(void)clearCollectableAtTileCoordinate:(CGPoint)tileCoord;
-(BOOL)isIntersectionAtTileCoordinate:(CGPoint)tileCoord;
-(CGPoint)tileCenterAtTileCoordinate:(CGPoint)tileCoord;

-(BOOL)isWallAtSpritePosition:(CGPoint)spritePosition;
-(BOOL)isCollectableAtSpritePosition:(CGPoint)spritePosition;
-(BOOL)isDotAtSpritePosition:(CGPoint)spritePosition;
-(BOOL)isPillAtSpritePosition:(CGPoint)spritePosition;
-(void)clearCollectableAtSpritePosition:(CGPoint)spritePosition;
-(BOOL)isIntersectionAtSpritePosition:(CGPoint)spritePosition;
-(CGPoint)tileCenterAtSpritePosition:(CGPoint)spritePosition;

-(CGPoint)resolveCollision:(CGPoint)spritePosition;

@end
