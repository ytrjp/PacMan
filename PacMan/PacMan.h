//
//  PacMan.h
//  PacMan
//
//  Created by Michel Launier on 11-05-11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Character.h"



@interface PacMan : Character {
    BOOL    isNewTouch;
    BOOL    isTouching;
    CGPoint touchPoint;
}

- (void)touchBegan:(UITouch*)touch withEvent:(UIEvent*)event;
- (void)touchEnded:(UITouch*)touch withEvent:(UIEvent*)event;
- (void)touchMoved:(UITouch*)touch withEvent:(UIEvent*)event;
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;


@end
