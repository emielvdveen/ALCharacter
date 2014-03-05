//
//  ALScriptFrames.m
//
//  Created by Emiel on 07-12-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import "ALScriptFrameBlock.h"
#import "ALCharacter.h"

@interface ALScriptFrameBlock ()

@property (nonatomic, strong) CCSprite* sprite;
@property (nonatomic, strong) NSString* frames;
@property (nonatomic, strong) CCAnimation* animation;

@property (nonatomic, weak) id<ALScriptFramesDataSource> dataSource;

@end

@implementation ALScriptFrameBlock

- (id) initWithSprite:(CCSprite*)sprite frames:(NSString*)frames delegate:(id<ALScriptFramesDataSource>)dataSource;
{
    self = [super init];
    if (self) {
        _sprite = sprite;
        _frames = frames;
        _dataSource = dataSource;
    }
    return self;
}

- (void) run:(float)interval completedHandler:(void(^)())completedHandler;
{
    NSArray* components = [_frames componentsSeparatedByString:@"#"];
    int moveX = 0;
    if (components.count >= 2)
    {
        moveX = [components[1] intValue];
    }
    
    NSArray* frameComponents = [components[0] componentsSeparatedByString:@"-"];
    NSAssert(frameComponents.count >= 2, @"from & to shoud be present");
    int from = [frameComponents[0] intValue];
    int to = [frameComponents[1] intValue];
    
    
    BOOL reversed = from > to;
    NSArray *frames = reversed ? [_dataSource framesFrom:to to:from] : [_dataSource framesFrom:from to:to];
    if (reversed)
    {
        NSArray * reversedFrames = [[frames reverseObjectEnumerator] allObjects];
        frames = reversedFrames;
    }
    
    _animation = [CCAnimation animationWithSpriteFrames:frames delay:interval];
    CCActionInterval *action = [CCAnimate actionWithAnimation:_animation];
    
    _sprite.flipX = moveX < 0 ? YES : NO;
    
    CCAction *callback = [CCCallBlock actionWithBlock:completedHandler];
    CCSequence* sequence = [CCSequence actions:action, callback, nil];
    
    [_sprite runAction: sequence];
    
    if (moveX != 0)
    {
        CGPoint newPosition = _sprite.position;
        int deltaX = frames.count*moveX;
        newPosition.x = newPosition.x+deltaX;
        CCActionInterval *move = [CCMoveTo actionWithDuration:interval*frames.count position:newPosition];
        [_sprite runAction:move];
    }
}

- (void) stop;
{
    [_sprite stopAllActions];
}

@end
