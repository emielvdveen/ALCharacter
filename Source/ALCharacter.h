//
//  ALCharacter.h
//
//  Created by Emiel on 08-11-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import "cocos2d.h"
#import "ALScriptFrameBlock.h"

#define DEFAULT_INTERVAL (ccTime) 1./12.

/**
 Base class for a an animatable object in a game.
 */
@interface ALCharacter : CCLayer <ALScriptFramesDataSource>

@property (nonatomic, assign) CCSprite* sprite;

/**
 Returns the plist of a sprite sheet
 
 @param name the name of the sprite sheet
 */
+ (NSString*) plistWithName:(NSString*)name;

/**
 Returns the texture of a sprite sheet
 
 @param name the name of the sprite sheet
 */
+ (NSString*) textureWithName:(NSString*)name;


/**
 Creates a new Character
 
 @param names the names of the textures to be used by this character
 @param prefix the prefix of each frame inside the sprite sheet
 @param frameCount the total number of frames used by this character
 @param interval the time between each animation frame
 @param loadSpriteSheets whether the sprite sheets should be loaded during creation of the character
 */
- (id)initWithNames:(NSArray*)names prefix:(NSString*)prefix frameCount:(int)frameCount interval:(float)interval loadTextures:(BOOL)loadSpriteSheets;

/**
 Displays a specific frame whithout animating it
 
 @param frameNr the number of the frame to be displayed
 */
- (void) showFrame:(int)frameNr;

/**
 The time between each animation frame of this character
 */
- (float) interval;

/**
 Runs the given animation script. If another script is currently running it will first interrupt that one before starting the new script.
 If the current running script has no interruptable moments the new script will be started after the current one has been finished.
 
 @param script the animation script to run
 @param completed called when the script has completed, if the script is interrupted this handler will not be called
 */
- (void) run:(NSString*)script completed:(void(^)())completedHandler;

/**
 Interrupts the current running animation script.

 If the animation has already been finished, the completed handler will be called immediately
 
 @param completed called when the current running script has been interrupted or if no script is running
 */
- (void) interrupt:(void(^)())completedHandler;
 
/**
 Stops the current animation script immediately (freeze)
 */
- (int) stop;

@end
