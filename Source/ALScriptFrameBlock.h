//
//  ALScriptFrames.h
//
//  Created by Emiel on 07-12-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/**
 Call back interface for retreiving CCSpriteFrame objects
 */
@protocol ALScriptFramesDataSource <NSObject>

/**
 Returns the corresponding CCSpriteFrame objects identified by frame number range
 */
- (NSArray*) framesFrom:(int)from to:(int)to;
@end

/**
 Manages a frame component of the animation script
 */
@interface ALScriptFrameBlock : NSObject

/**
 Creates a new ScriptFrameBlock
 
 @param sprite the sprite object used by the character which should be animated
 @param frames the script component defining the frames to run
 @param dataSource used to retreive CCSpriteFrame objects
 */
- (id) initWithSprite:(CCSprite*)sprite frames:(NSString*)frames delegate:(id<ALScriptFramesDataSource>)dataSource;

/**
 Starts the frame component of the animation script
 
 @param interval delay between the animation frames
 @param completedHandler called when this part of the animation script has been finished
*/
- (void) run:(float)interval completedHandler:(void(^)())completedHandler;

/**
 Stops the frame component of the animation script
 */
- (void) stop;

@end
