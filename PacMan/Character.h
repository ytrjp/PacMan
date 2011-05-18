//
//  Character.h
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "TileMapInfo.h"

// Character sprite 32x32
#define SPRITE_SIZE  32


typedef enum DirectionEnum {
    kUp, kDown, kLeft, kRight, kNone
} Direction;

@interface Character : CCNode {
    NSString            *name;
    CGPoint             spawnPosition;
    CCSpriteBatchNode   *spriteSheet;
    CCSprite            *sprite;
    float               speed;
    Direction           direction;
    TileMapInfo         *tileMapInfo;
    CGPoint             currentTile;
    CCAnimation         *animation;
    CCAction            *loopedAnimation;
}

-(id) initWithName: (NSString*)characterName usingTileMap:(TileMapInfo*)tileMapInfo withSpeed:(float)_speed;
-(CGPoint)positionCleanup:(CGPoint)pos withDirection:(Direction)dir;
+(CGPoint)directionVector:(Direction)dir;
-(void)update:(ccTime)dt;
-(CGPoint)processCollision:(CGPoint)newPosition;
-(CGPoint)processIntersection:(CGPoint)newPosition;


@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) CCSprite *sprite;
@property (readonly,nonatomic) CCSpriteBatchNode *spriteSheet;
@property (readwrite,nonatomic) Direction direction;

@end
