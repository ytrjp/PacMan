//
//  PacMan.m
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PacMan.h"


@implementation PacMan

// on "init" you need to initialize your instance
-(id) initWithName:(NSString*)characterName usingTileMap:(TileMapInfo*)theTileMapInfo withSpeed:(float)_speed
{
    self= [super initWithName:characterName usingTileMap:theTileMapInfo withSpeed:_speed];
    if(self == nil) return nil;

    // PacMan does not have a predefined starting direction.
    direction= kNone;
    isTouching= NO;
    isNewTouch= NO;
    
    // Load the animation file.
    NSString *fileName= @"PacManAnim.png";
    spriteSheet= [CCSpriteBatchNode batchNodeWithFile:fileName];
    NSAssert(spriteSheet != nil, @"Unable to load sprite for %@", fileName);
    [self addChild:spriteSheet];
    sprite= [CCSprite spriteWithBatchNode:spriteSheet rect:CGRectMake(0,0,SPRITE_SIZE,SPRITE_SIZE)];
    
    // Build animation frames.
    NSMutableArray *frames= [[NSMutableArray alloc] init];
    CGSize spriteSheetSize= spriteSheet.textureAtlas.texture.contentSize;
    for(int x= 0; x < spriteSheetSize.width; x+= SPRITE_SIZE) {
        [frames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(x, 0, SPRITE_SIZE, SPRITE_SIZE)]];
    }
    
    // Build animation action.
    animation= [CCAnimation animationWithFrames:frames delay:0.1f];
    loopedAnimation= [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]];
    [sprite runAction:loopedAnimation];
    [spriteSheet addChild:sprite];
    
    sprite.position= spawnPosition;
    speed= _speed;
    
    return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [super dealloc];
}

-(void)adjustDirection:(ccTime)dt fromVector:(CGPoint)inputVector
{
    float rotation= 0;
    Direction newDir;
    if(fabsf(inputVector.x) > fabsf(inputVector.y)) {
        if(inputVector.x < 0) {
            newDir= kLeft;
        }
        else {
            newDir= kRight;
            rotation= 180.0f;
        }
    }
    else {
        if(inputVector.y < 0) {
            newDir= kDown;
            rotation= 270.0f;
        }
        else {
            newDir= kUp;
            rotation= 90.0f;
        }
    }
    CGPoint dirVector= [Character directionVector:newDir];
    CGPoint newPos= ccpAdd(sprite.position, ccpMult(dirVector, speed*dt));
    if([tileMapInfo isWallAtSpritePosition:newPos]) {
        return;
    }
    direction= newDir;
    sprite.rotation= rotation;    
}

-(void)computeDirection:(ccTime)dt
{
    if(!isTouching) {
        direction= kNone;
        return;
    }
    CGPoint inputVector= ccpSub(touchPoint, sprite.position);
    if(fabsf(inputVector.x) < 8 && fabsf(inputVector.y) < 8) {
        direction= kNone;
        return;
    }
    [self adjustDirection:dt fromVector:ccpNormalize(inputVector)];
}

-(CGPoint)processCollision:(CGPoint)newPosition
{
    return [super processCollision:newPosition];
}

-(CGPoint)processIntersection:(CGPoint)newPosition
{
    [self computeDirection:0.016666f];
    return [super processIntersection:newPosition];
}


// ===================================================================================
// Process touch events.
- (void)touchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    isTouching= YES;
    isNewTouch= YES;
}

- (void)touchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
    isTouching= NO;
}

- (void)touchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];    
}


// ===================================================================================
// Process accelerometer
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    //    if(isTouching) return;
    //    CGPoint inputVector= ccpNormalize(ccp(-acceleration.y, acceleration.x));
    //    [self adjustDirection:(1.0/60.0) fromVector:inputVector];
}


//=====================================================================
// Game loop update.
-(void)update:(ccTime)dt
{
    if(isNewTouch || !isTouching) {
        isNewTouch= NO;
        [self computeDirection:dt];
    }
    [super update:dt];
}

@end
