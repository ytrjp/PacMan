//
//  Ghost.m
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Ghost.h"

#define ESCAPE_SPEED_RATIO  0.5f
#define DEAD_SPEED_RATIO    2.0f


@implementation Ghost

@synthesize activeState;


-(void)setupNormalAnimation
{
    sprite.opacity= 192;
    [animationFrames removeAllObjects];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(0,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(SPRITE_SIZE,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animation setFrames:animationFrames];
}

-(void)setupEscapeAnimation
{
    sprite.opacity= 192;
    [animationFrames removeAllObjects];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(2*SPRITE_SIZE,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(3*SPRITE_SIZE,0,SPRITE_SIZE,SPRITE_SIZE)]];    
    [animation setFrames:animationFrames];
}

-(void)setupEscapeEndAnimation
{
    sprite.opacity= 255;
    [animationFrames removeAllObjects];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(0,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(SPRITE_SIZE,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(2*SPRITE_SIZE,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(3*SPRITE_SIZE,0,SPRITE_SIZE,SPRITE_SIZE)]];    
    [animation setFrames:animationFrames];
}

-(void)setupDeadAnimation
{
    sprite.opacity= 80;
    [animationFrames removeAllObjects];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(0,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animationFrames addObject:[CCSpriteFrame frameWithTexture:spriteSheet.textureAtlas.texture rect:CGRectMake(SPRITE_SIZE,0,SPRITE_SIZE,SPRITE_SIZE)]];
    [animation setFrames:animationFrames];
}

-(void)buildAnimation
{
    animation= [CCAnimation animationWithFrames:animationFrames delay:0.1f];
    loopedAnimation= [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation restoreOriginalFrame:NO]];
    [sprite runAction:loopedAnimation];
    [spriteSheet addChild:sprite];    
}

-(void)updateEyes
{
    switch(direction) {
        case kUp:
            eyeSprite.position= ccpAdd(sprite.position, ccp(0,5));
            break;
        case kDown:
            eyeSprite.position= ccpAdd(sprite.position, ccp(0,1));
            break;
        case kLeft:
            eyeSprite.position= ccpAdd(sprite.position, ccp(-2,5));
            break;
        case kRight:
            eyeSprite.position= ccpAdd(sprite.position, ccp(2,5));
            break;
        case kNone:
            break;
    }
}

-(void)setupEyes
{
    switch(direction) {
        case kUp:
            [eyeSprite setTextureRect:CGRectMake(0,0,16,16)];
            break;
        case kDown:
            [eyeSprite setTextureRect:CGRectMake(16,0,16,16)];
            break;
        case kLeft:
            [eyeSprite setTextureRect:CGRectMake(0,16,16,16)];
            break;
        case kRight:
            [eyeSprite setTextureRect:CGRectMake(16,16,16,16)];
            break;
        case kNone:
            break;
    }    
}

// on "init" you need to initialize your instance
-(id) initWithName:(NSString*)characterName usingTileMap:(TileMapInfo*)theTileMapInfo withSpeed:(float)_speed
{
    self= [super initWithName:characterName usingTileMap:theTileMapInfo withSpeed:_speed];
    if(self == nil) return nil;

    // Start ghost in a random direction.
    activeState= Normal;
    normalSpeed= _speed;
    speed= _speed;
    direction= random() % 4;
    
    // Load the animation file.
    NSString *fileName= [name stringByAppendingString:@"Anim.png"];
    spriteSheet= [CCSpriteBatchNode batchNodeWithFile:fileName];
    NSAssert(spriteSheet != nil, @"Unable to load sprite for %@", fileName);
    [self addChild:spriteSheet];
    sprite= [CCSprite spriteWithBatchNode:spriteSheet rect:CGRectMake(0,0,SPRITE_SIZE,SPRITE_SIZE)];
    
    // Build animation frames.
    animationFrames= [[NSMutableArray alloc] init];
    CGSize spriteSheetSize= spriteSheet.textureAtlas.texture.contentSize;
    NSAssert(spriteSheetSize.width == 128, @"Ghost animation texture sheet is of wrong size");
    [self setupNormalAnimation];
    
    // Build animation action.
    [self buildAnimation];
    
    // Load ghost eyes.
    eyeSpriteSheet= [CCSpriteBatchNode batchNodeWithFile:@"GhostEyes.png"];
    eyeSprite= [CCSprite spriteWithBatchNode:eyeSpriteSheet rect:CGRectMake(0,0,16,16)];    
    [self addChild:eyeSpriteSheet];
    [eyeSpriteSheet addChild:eyeSprite z:1];
    [self updateEyes];
    
    sprite.position= spawnPosition;

    return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [super dealloc];
}


-(CGPoint)processIntersection:(CGPoint)newPosition
{
    unsigned int newDir;
    CGPoint newPos;
    CGPoint cDirVect= [Character directionVector:direction];
    do{
        CGPoint dirVect;
        BOOL useRandom= YES;
        if(activeState == Dead && (random() & 1) == 0) { // When dead, guide ghost towards spawn point.
            dirVect= ccpSub(spawnPosition, sprite.position);
            if((random() & 1) == 0) {
                newDir= dirVect.x > 0  ? kRight : kLeft;
            }
            else {
                newDir= dirVect.y > 0 ? kUp : kDown;
            }
            dirVect= [Character directionVector:newDir];
            useRandom= NO;
        }
        if(useRandom) {
            newDir= random() % 4;
            dirVect= [Character directionVector:newDir];
            if((cDirVect.x * dirVect.x) < -0.9f || (cDirVect.y * dirVect.y) < -0.9f) {
                newDir= (newDir+1) % 4;
                dirVect= [Character directionVector:newDir];
            }            
        }
        
        CGPoint tileCoord= [tileMapInfo toTileCoordinate:sprite.position];
        newPos= ccp(tileCoord.x+dirVect.x, tileCoord.y-dirVect.y);
    } while([tileMapInfo isWallAtTileCoordinate:newPos]);
    direction= newDir;
    [self setupEyes];
    return newPosition;
}

-(void) setActiveState:(GhostStateEnum)newState
{
    if(activeState == Dead && newState == Escape) {
        return;
    }
    activeState= newState;
    switch(activeState) {
        case Normal:
            speed= normalSpeed;
            [self setupNormalAnimation];
            [self unschedule:@selector(escapeAlmostFinished:)];
            [self unschedule:@selector(escapeEnded:)];
            break;
        case Escape:
            speed= normalSpeed * ESCAPE_SPEED_RATIO;
            [self setupEscapeAnimation];
            [self unschedule:@selector(escapeEnded:)];
            [self schedule: @selector(escapeAlmostFinished:) interval:15];
            break;
        case Dead:
            speed= normalSpeed * DEAD_SPEED_RATIO;
            [self setupDeadAnimation];
            [self unschedule:@selector(escapeAlmostFinished:)];
            [self unschedule:@selector(escapeEnded:)];
            break;
    }
}

-(void)escapeAlmostFinished:(ccTime)dt
{
    [self setupEscapeEndAnimation];
    [self unschedule:@selector(escapeAlmostFinished:)];
    [self schedule:@selector(escapeEnded:) interval:5];
}

-(void)escapeEnded:(ccTime)dt
{
    [self unschedule:@selector(escapeEnded:)];
    [self setActiveState:Normal];
}


//=====================================================================
// Game loop update.
-(void)update:(ccTime)dt
{
    if(activeState == Dead) {
        float distanceToSpawnPoint= ccpDistance(sprite.position, spawnPosition);
        if(distanceToSpawnPoint <= SPRITE_SIZE) {
            [self setActiveState:Normal];
        }
    }
    [super update:dt];
    [self updateEyes];
}

@end
