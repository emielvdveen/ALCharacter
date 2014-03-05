//
//  ALScriptSession.h
//
//  Created by Emiel on 09-01-13.
//  Copyright (c) 2013 Applike. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Manages a single animation script while running
 */
@interface ALScriptSession : NSObject

/**
 Creates a new animation script session
 
 @param blocks an array containing script elements
 */
- (id)initWithBlocks:(NSArray*)blocks;

/**
 Starts the animation
 
 @param interval delay between the animation frames
 @param completedHandler called when the script has been finished
 */
- (void) start:(ccTime)interval completed:(void(^)())completedHandler;

/**
 Interupts a running animation
 
 @param completedHandler called when animation script has succesfully been interrupted or the session has already been finished
 */
- (void) interrupt:(void(^)())completedHandler;

/**
 Stops the animation
 */
- (void) stop;

@end
