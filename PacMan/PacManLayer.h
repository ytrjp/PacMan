//
//  PacManLayer.h
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class PacMan;
@class Ghost;
@class TileMapInfo;

@interface PacManLayer : CCLayer {
    TileMapInfo*        tileMapInfo;
    PacMan              *pacMan;
    NSArray             *ghosts;
    unsigned int        score;
    CCLabelTTF          *scoreLabel;
    BOOL                isGameOver;
    float               ghostScore;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
