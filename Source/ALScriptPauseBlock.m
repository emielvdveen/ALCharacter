//
//  ALScriptPause.m
//
//  Created by Emiel on 06-12-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import "ALScriptPauseBlock.h"
#import "cocos2d.h"

@interface ALScriptPauseBlock ()

@property (nonatomic,assign) BOOL started;
@property (nonatomic,assign) BOOL interrupted;
@property (nonatomic,assign) BOOL finished;

@property (nonatomic,strong) NSTimer* timer;
@property (nonatomic,strong) void (^completedHandler)();

@end

@implementation ALScriptPauseBlock

@synthesize duration = _duration;

- (id)initWithDuration:(int)duration;
{
    self = [super init];
    if (self) {
        _duration = duration;
    }
    return self;
}

- (void) run:(ccTime)interval completedHandler:(void(^)())completedHandler;
{
    NSAssert(_timer == nil, @"can only run once");
    @synchronized(self)
    {
        NSTimeInterval timeInterval = (float)_duration*(float)interval;
        
        _started = YES;
        _completedHandler = [completedHandler copy];
        _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(handleTimeOut) userInfo:nil repeats:NO];
    }
}

- (void) interrupt;
{
    NSAssert(_started, @"can only interrupt when started");
    NSAssert(!_interrupted, @"can only interrupt once");
    @synchronized(self)
    {
        if (!_interrupted && !_finished)
        {
            _interrupted = YES;
            if (_timer)
            {
                [_timer invalidate];
                _timer = nil;
            }
            
            [self handleTimeOut];
        }
    }
}

- (void) handleTimeOut;
{
    @synchronized(self)
    {
        if (!_finished)
        {
            _finished = YES;
            
            if (_completedHandler)
            {
                _completedHandler();
                _completedHandler = nil;
            }
        }
    }
}

- (void)dealloc {
    _completedHandler = nil;
}

@end
