//
//  ALScriptPause.h
//
//  Created by Emiel on 06-12-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALScriptPauseBlock : NSObject

@property (nonatomic, assign) int duration;

/**
 Create a new animation pause block
 
 @param duration the number of frames the animation should pause
 @param completedHandler called when the script has been finished
 */
- (id)initWithDuration:(int)duration;

/**
 Runs the pause
 
 @param interval the time between each frame used to calculate the lenght of the pause
 @param completedHandler called when the the pause has been finished
 */
- (void) run:(float)interval completedHandler:(void(^)())completedHandler;

/**
 Interrupts the pause. Will cause the run completedHandler to be called.
 */
- (void) interrupt;

@end
