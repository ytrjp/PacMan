//
//  PacManLayer.m
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// Import the interfaces
#import "PacManLayer.h"
#import "TileMapInfo.h"
#import "PacMan.h"
#import "Ghost.h"

#define PACMAN_SPEED    80.0f


// HelloWorldLayer implementation
@implementation PacManLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PacManLayer *layer = [PacManLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
    
        // Load tile map.
        tileMapInfo= [[[TileMapInfo alloc] initWithTMXFile:@"PacMan.tmx"] retain]; 
        [self addChild:tileMapInfo.tileMap z:-1];

		// Determine player & NPC spawn points.
        pacMan= [[[PacMan alloc] initWithName:@"PacMan" usingTileMap:tileMapInfo withSpeed:PACMAN_SPEED] retain];
        [self addChild:pacMan];
        pacMan.direction= kNone;
        
        Ghost *inky= [[Ghost alloc] initWithName:@"Inky" usingTileMap:tileMapInfo withSpeed:0.8*PACMAN_SPEED];
        [self addChild:inky];

        Ghost *pinky= [[Ghost alloc] initWithName:@"Pinky" usingTileMap:tileMapInfo withSpeed:0.8*PACMAN_SPEED];
        [self addChild:pinky];
        
        Ghost *blinky= [[Ghost alloc] initWithName:@"Blinky" usingTileMap:tileMapInfo withSpeed:0.8*PACMAN_SPEED];
        [self addChild:blinky];
        blinky.direction= kLeft;
        
        Ghost *clyde= [[Ghost alloc] initWithName:@"Clyde" usingTileMap:tileMapInfo withSpeed:0.8*PACMAN_SPEED];
        [self addChild:clyde];
        
        ghosts= [[[NSArray alloc] initWithObjects:inky, pinky, blinky, clyde, nil] retain];

        // enable touch events.
        self.isTouchEnabled= YES;
        self.isAccelerometerEnabled= YES;
        
        // Prepare score label
        score= 0;
        NSString *scoreString= [NSString stringWithFormat:@"%d" ,score];
        scoreLabel = [CCLabelTTF labelWithString:scoreString fontName:@"Marker Felt" fontSize:24];
        scoreLabel.position= ccp(0.25f * tileMapInfo.mapSize.width * tileMapInfo.tileSize.width,
                                 (tileMapInfo.mapSize.height+1) * tileMapInfo.tileSize.height);
        [self addChild:scoreLabel];
        
        // enable game loop.
        isGameOver= NO;
        [self scheduleUpdate];
        [self schedule: @selector(tick250ms:) interval:0.25];
        
        
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    [ghosts release];
    ghosts= nil;
    
    [pacMan release];
    pacMan= nil;
    
    [tileMapInfo release];
    tileMapInfo= nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}


-(void)shutdown {
    [self cleanup];
    [[CCDirector sharedDirector] end];
    exit(0);
}


-(void)playerLost {
    isGameOver= YES;
    
    // create and initialize a Label
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"You Lost" fontName:@"Marker Felt" fontSize:64];
        
    // ask director the the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
        
    // position the label on the center of the screen
    label.position =  ccp( size.width /2 , size.height/2 );
    		
    // add the label as a child to this Layer
    [self addChild: label];
    
}

-(void)playerWins {
    isGameOver= YES;
    
    // create and initialize a Label
    CCLabelTTF *label = [CCLabelTTF labelWithString:@"You Win" fontName:@"Marker Felt" fontSize:64];
    
    // ask director the the window size
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // position the label on the center of the screen
    label.position =  ccp( size.width /2 , size.height/2 );
    
    // add the label as a child to this Layer
    [self addChild: label];
    
}


// ===================================================================================
// Process touch events.
- (void)ccTouchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    if(touch == nil) return;
    [pacMan touchBegan:touch withEvent:(UIEvent*)event];
}

- (void)ccTouchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    if(touch == nil) return;

    // Simulate end menu.
    if(isGameOver) {
        CGPoint touchPoint = [touch locationInView:[touch view]];
        touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
        CGSize winSize= [[CCDirector sharedDirector] winSize];
        CGPoint center= ccp(winSize.width*0.5f, winSize.height * 0.5f);
        if(touchPoint.x < center.x - winSize.width * 0.125f) return;
        if(touchPoint.x > center.x + winSize.width * 0.125f) return;
        if(touchPoint.y < center.y - winSize.height * 0.125f) return;
        if(touchPoint.y > center.y + winSize.height * 0.125f) return;
        
        self.isTouchEnabled= NO;
        [self shutdown];
        return;
    }

    [pacMan touchEnded:touch withEvent:event];
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if(touch == nil) return;
    [pacMan touchMoved:touch withEvent:event];
}


// ===================================================================================
// Process accelerometer
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    [pacMan accelerometer:accelerometer didAccelerate:acceleration];
}


// ===================================================================================
// Game loop
-(void)update:(ccTime)dt
{
    if(isGameOver) return;
    
    Ghost* ghost;
    [pacMan update:dt];
    for(ghost in ghosts) {
        [ghost update:dt];
    }
    
    // Look for game over condition.
    float collisionDistance= ccpLength(ccp(tileMapInfo.tileSize.width*0.5f,tileMapInfo.tileSize.height*0.5f));
    for(ghost in ghosts) {
        if(ccpLength(ccpSub(pacMan.sprite.position, ghost.sprite.position)) < collisionDistance) {
            if(ghost.activeState == Dead) continue;
            if(ghost.activeState == Escape) {
                ghostScore+= 200;
                score+= ghostScore;
                ghost.activeState= Dead;
            }
            else {
                [self playerLost];                            
            }
        }
    }

    // Compute score and win condition.
    if([tileMapInfo isCollectableAtSpritePosition:pacMan.sprite.position]) {
        score+= 10;
        if([tileMapInfo isPillAtSpritePosition:pacMan.sprite.position]) {
            for(ghost in ghosts) {
                ghost.activeState= Escape;
                ghostScore= 0;
            }
        }
        [tileMapInfo clearCollectableAtSpritePosition:pacMan.sprite.position];
        if([tileMapInfo areAllCollectablesTaken]) {
            [self playerWins];
        }
    }
}

-(void)tick250ms:(ccTime)dt
{
    // Display score.
    [scoreLabel setString:[NSString stringWithFormat:@"%d" ,score]];
}

@end
