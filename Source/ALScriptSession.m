//
//  ALScriptSession.m
//
//  Created by Emiel on 09-01-13.
//  Copyright (c) 2013 Applike. All rights reserved.
//

#import "ALScriptSession.h"
#import "ALScriptBreakBlock.h"
#import "ALScriptPauseBlock.h"
#import "ALScriptFrameBlock.h"
#import "ALScriptBeginBlock.h"
#import "ALScriptEndBlock.h"

@interface ALScriptSession ()

@property (nonatomic, assign) ccTime interval;

@property (nonatomic, strong) NSArray* blocks;
@property (nonatomic, assign) int blockPointer;
@property (nonatomic, assign) int optionalLevel;

@property (nonatomic, assign) BOOL interruptFlag;
@property (nonatomic, assign) BOOL interupted;
@property (nonatomic, strong) void (^interruptCompletedHandler)();

@property (nonatomic, assign) BOOL finishFlag;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, strong) void (^finishedCompletedHandler)();

@end

@implementation ALScriptSession

- (void)dealloc
{
    _finishedCompletedHandler = nil;
    _interruptCompletedHandler = nil;
}

- (id)initWithBlocks:(NSArray*)blocks;
{
    self = [super init];
    if (self) {
        _blocks = blocks;
        _blockPointer = 0;
    }
    return self;
}

- (void) start:(ccTime)interval completed:(void(^)())completedHandler;
{
    _interval = interval;
    _blockPointer = 0;
    _finishedCompletedHandler = [completedHandler copy];
    [self runNextBlock];
}

- (void) runNextBlock;
{
    if (_blocks.count == _blockPointer || _finishFlag)
    {
        [self handleFinish];
        return;
    }
    
    id currentBlock = [self currentBlock];
    if ([currentBlock isKindOfClass:[ALScriptPauseBlock class]])
    {
        ALScriptPauseBlock* pause = currentBlock;
        _blockPointer++;
        [pause run:_interval completedHandler:^{
            [self performSelector:@selector(runNextBlock) withObject:nil afterDelay:0];
        }];
        return;
    }
    else if ([currentBlock isKindOfClass:[ALScriptBreakBlock class]])
    {
        _blockPointer++;
        [self performSelector:@selector(runNextBlock) withObject:nil afterDelay:0];
        return;
    }
    else if ([currentBlock isKindOfClass:[ALScriptBeginBlock class]])
    {
        _optionalLevel++;
        _blockPointer++;
        [self performSelector:@selector(runNextBlock) withObject:nil afterDelay:0];
        return;
    }
    else if ([currentBlock isKindOfClass:[ALScriptEndBlock class]])
    {
        _optionalLevel--;
        _blockPointer++;
        [self performSelector:@selector(runNextBlock) withObject:nil afterDelay:0];
        return;
    }
    
    NSAssert([[self currentBlock] isKindOfClass:[ALScriptFrameBlock class]], @"only script frames are runnable from here");
    
    ALScriptFrameBlock* framesBlock = [self currentBlock];
    [framesBlock run:(float)_interval completedHandler:^{
        if ([self shouldRunNextBlock])
        {
            [self performSelector:@selector(runNextBlock) withObject:nil afterDelay:0];
        }
        else
        {
            if ([self hasFinished])
            {
                [self performSelector:@selector(handleFinish) withObject:nil afterDelay:0];
            }
            else
            {
                [self performSelector:@selector(handleInterrupt) withObject:nil afterDelay:0];
            }
        }
    }];
}

- (BOOL) hasFinished;
{
    return _blockPointer == _blocks.count;
}

- (void) handleFinish;
{
    _finished = YES;
    
    if (_finishedCompletedHandler)
    {
        _finishedCompletedHandler();
        _finishedCompletedHandler = nil;
    }

    _interruptCompletedHandler = nil;
}

- (void) handleInterrupt;
{
    _interupted = YES;
    
    if (_interruptCompletedHandler)
    {
        _interruptCompletedHandler();
        _interruptCompletedHandler = nil;
    }
    
    _finishedCompletedHandler = nil;
}

- (id) currentBlock;
{
    if ([self hasFinished])
    {
        return nil;
    }
    
    return [_blocks objectAtIndex:(NSUInteger) _blockPointer];
}

- (void) interrupt:(void(^)())completedHandler;
{
    if ([self hasFinished])
    {
        completedHandler();
        return;
    }
    
    if (!_interruptFlag)
    {
        _interruptFlag = YES;
        if ([[self currentBlock] isKindOfClass:[ALScriptPauseBlock class]])
        {
            ALScriptPauseBlock* pause = [self currentBlock];
            [pause interrupt];
        }
        _interruptCompletedHandler = [completedHandler copy];
    }
}

- (void) stop;
{
    _finishFlag = YES;
    if ([[self currentBlock] isKindOfClass:[ALScriptFrameBlock class]])
    {
        ALScriptFrameBlock* frames = [self currentBlock];
        [frames stop];
    }
}

- (BOOL) shouldRunNextBlock;
{
    if (_interruptFlag)
    {
        [self forward];
        return ![[self currentBlock] isKindOfClass:[ALScriptBreakBlock class]];
    }
    else
    {
        _blockPointer++;
        return YES;
    }
}

- (void) forward;
{
    if (_optionalLevel > 0)
    {
        [self fastForward];
    }
    else
    {
        _blockPointer++;
        
        if (_interruptFlag)
        {
            // skipping pauses while interrupting
            while ([[self currentBlock] isKindOfClass:[ALScriptPauseBlock class]])
            {
                _blockPointer++;
            }
        }
    }
}

- (void) fastForward;
{
    while (_optionalLevel > 0)
    {
        _blockPointer++;
        if ([[self currentBlock] isKindOfClass:[ALScriptEndBlock class]])
        {
            _optionalLevel--;
        }
    }
}

@end
