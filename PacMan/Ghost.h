//
//  Ghost.h
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Character.h"

typedef enum { Normal, Escape, Dead } GhostStateEnum;

@interface Ghost : Character {
    GhostStateEnum      activeState;
    float               normalSpeed;
    NSMutableArray      *animationFrames;
    CCSpriteBatchNode   *eyeSpriteSheet;
    CCSprite            *eyeSprite;
}

@property (readwrite,nonatomic) GhostStateEnum activeState;

@end
