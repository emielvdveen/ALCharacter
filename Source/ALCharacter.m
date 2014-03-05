//
//  ALCharacter.m
//
//  Created by Emiel on 08-11-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import "ALCharacter.h"

#import "ALScriptBreakBlock.h"
#import "ALScriptFrameBlock.h"
#import "ALScriptPauseBlock.h"
#import "ALScriptBeginBlock.h"
#import "ALScriptEndBlock.h"
#import "ALScriptSession.h"

#import "NSString+ALCharacter.h"
#import "CCSprite+ALCharacter.h"

@interface ALCharacter ()

@property (nonatomic, strong) CCAnimation* animation;
@property (nonatomic, strong) ALScriptSession* session;

@property (nonatomic, strong) NSString* prefix;
@property (nonatomic, strong) NSArray* names;

@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) int frameCount;
@property (nonatomic, assign) int frameCounter;
@property (nonatomic, assign) int frameTo;
@property (nonatomic, assign) int repeat;
@property (nonatomic, assign) int moveX;
@property (nonatomic, assign) float interval;

@property (nonatomic, strong) void (^addSpriteSheetCompletedHandler)();
@property (nonatomic, strong) void (^sessionCompletedHandler)();

@end

@implementation ALCharacter

#define MAKERANGE NSMakeRange(from, (to-from)+1)

#pragma mark - Class level methods

+ (NSString*) plistWithName:(NSString*)name
{
    return ([UIScreen mainScreen].scale == 2 ?  [NSString stringWithFormat:@"%@@2x.plist", name]: [NSString stringWithFormat:@"%@.plist", name]);
}

+ (NSString*) textureWithName:(NSString*)name
{
    return ([UIScreen mainScreen].scale == 2 ?  [NSString stringWithFormat:@"%@@2x.png", name]: [NSString stringWithFormat:@"%@.png", name]);
}

#pragma mark - Lifecycle

- (id)initWithNames:(NSArray*)names prefix:(NSString*)prefix frameCount:(int)frameCount interval:(float)interval loadTextures:(BOOL)loadSpriteSheets;
{
    self = [super init];
    if (self) {
        _active = NO;        
        _prefix = prefix;
        _frameCount = frameCount;
        _interval = interval;
        _names = names;
        
        if (loadSpriteSheets)
        {
            [self loadSpriteSheets];
        }
        
        [self determineFirstFrame];
    }
    return self;
}

- (void) determineFirstFrame
{
    _sprite = [self searchForFirstFrame];
    if (!_sprite)
    {
        _sprite = [CCSprite spriteWithSpriteFrame:[self frame:1]];
    }
    [self addChild:_sprite];
}

- (CCSprite*) searchForFirstFrame;
{
    for(NSString* name in _names)
    {
        NSString* firstFrameName = [NSString stringWithFormat:@"%@_first.png", name];
        UIImage* firstFrame = [UIImage imageNamed:firstFrameName];
        if (firstFrame)
        {
            return [CCSprite spriteWithCGImage:firstFrame.CGImage key:firstFrameName];
            break;
        }
    }
    return nil;
}

- (void) loadSpriteSheets;
{
    for(NSString* name in _names)
    {
        [self addSpriteSheetInternal:name];
    }
}

- (void) addSpriteSheetInternal:(NSString*)name
{
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[ALCharacter plistWithName:name]];
    if (_addSpriteSheetCompletedHandler)
    {
        _addSpriteSheetCompletedHandler();
        _addSpriteSheetCompletedHandler = nil;
    }
}

- (void) dealloc
{
    [self removeAllChildrenWithCleanup:YES];
    
    if (_sessionCompletedHandler)
    {
        _sessionCompletedHandler = nil;
    }
}

#pragma mark - Scripting

- (void) run:(NSString*)script completed:(void(^)())completedHandler;
{
    //NSLog(@"retainCount = %i", [self retainCount]);
    script = [self replaceActions:[self actions] inScript:script];
    script = [self extractLoops:script];
    NSArray* runBlocks = [self parseScript:script];

    @synchronized(self)
    {
        if (_session)
        {
            NSLog(@"Trying to interrupt session with: %@ ",script);
            [_session interrupt:^{
                NSLog(@"Session interrupted with: %@ ",script);
                _session = nil;
                [self startSession:runBlocks completed:completedHandler];
            }];
        }
        else
        {
            [self startSession:runBlocks completed:completedHandler];
        }
    }
}

- (NSDictionary*) actions;
{
    return [NSDictionary dictionary];
}

- (NSString*) replaceActions:(NSDictionary*)actions inScript:(NSString*)script;
{
    NSMutableString* result = [script mutableCopy];
    
    /* sort keys so longest actions comes first to prevent we replace a short action name that is also a
     substring of a longer action name (eg: "lookUp" and "LookUpRight") */
    NSArray *sortedAllKeys = [actions.allKeys sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = a;
        NSString *second = b;
        if (first.length > second.length)
        {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedDescending;
        }
    }];
    
    // replace actions
    for (NSString* actionName in sortedAllKeys) {
        NSRange range = [result rangeOfString:actionName];
        if (range.length > 0)
        {
            NSString* actionValue = [actions objectForKey:actionName];
            [result replaceOccurrencesOfString:actionName withString:actionValue options:0 range:NSMakeRange(0, result.length)];
        }
    }
    
    return result;
}

- (NSString*) extractLoops:(NSString*)script;
{
    NSMutableString* script_ = [script mutableCopy];
    NSRange loopEnd = [script_ rangeOfString:@")"];
    while (loopEnd.location != NSNotFound)
    {
        NSRange loopBegin = [script_ rangeOfString:@"(" options:NSBackwardsSearch range:NSMakeRange(0, loopEnd.location)];
        
        int from = loopEnd.location;
        int to = script_.length-1;
        NSRange loopCountEnd = [script_ rangeOfString:@" " options:0 range:MAKERANGE];
        if (loopCountEnd.location == NSNotFound)
        {
            loopCountEnd.location = to+1;
        }
        
        from = loopEnd.location+2;
        to = loopCountEnd.location-1;
        NSString *loopCountString = [script_ substringWithRange:MAKERANGE];
        int loopCount = [loopCountString intValue];
        
        from = loopBegin.location+1;
        to = loopEnd.location-1;
        NSString* subscript = [script_ substringWithRange:MAKERANGE];
        
        /* delete loop */
        from = loopBegin.location;
        to = loopCountEnd.location-1;
        [script_ deleteCharactersInRange:MAKERANGE];
        
        [script_ insertString:@" ] " atIndex:loopBegin.location];
        for(int i=0; i<loopCount; i++)
        {
            /* insert loop run, every loop run is optional which is indicated with the ? */
            [script_ insertString:subscript atIndex:loopBegin.location];
            [script_ insertString:@" " atIndex:loopBegin.location];
        }
        [script_ insertString:@" [" atIndex:loopBegin.location];
        
        /* next loop */
        loopEnd = [script_ rangeOfString:@")"];
    }
    
    return script_;
}

- (NSArray*) parseScript:(NSString*)script;
{
    NSMutableArray* blocks = [[NSMutableArray alloc] init];
    
    // break down script
    NSArray* components = [script componentsSeparatedByString:@" "];
    for(NSString* component in components)
    {
        if (component.length == 0)
        {
            continue;
        }
        // check for start char
        if ([component startsWith:@"["])
        {
            [blocks addObject:[[ALScriptBeginBlock alloc] init]];
        }
        // check for end char
        else if ([component startsWith:@"]"])
        {
            [blocks addObject:[[ALScriptEndBlock alloc] init]];
        }
        // check for pause
        else if ([component startsWith:@"|"])
        {
            ALScriptPauseBlock* pause = [self parsePause:component];
            [blocks addObject:pause];
        }
        // check for break
        else if ([component isEqualToString:@"^"])
        {
            [blocks addObject:[[ALScriptBreakBlock alloc] init]];
        }
        // frames
        else
        {
            [blocks addObject:[[ALScriptFrameBlock alloc] initWithSprite:_sprite frames:component delegate:self]];
        }
    }
    
    return blocks;
}

- (ALScriptPauseBlock*) parsePause:(NSString*)pause;
{
    int duration = 1;
    if ([pause startsWith:@"|*"])
    {
        NSMutableString* pause_ = [pause mutableCopy];
        [pause_ replaceOccurrencesOfString:@"|*" withString:@"" options:0 range:NSMakeRange(0, pause_.length)];
        duration = [pause_ intValue];
    }
    
    return [[ALScriptPauseBlock alloc ] initWithDuration:duration];
}

- (void) startSession:(NSArray*)blocks completed:(void(^)())completedHandler;
{
    NSAssert(_session == nil, @"previous session should be finished");
    
    _sessionCompletedHandler = nil;
    _sessionCompletedHandler = [completedHandler copy];
    _session = [[ALScriptSession alloc] initWithBlocks:blocks];
    
    [_session start:_interval completed:^{
        @synchronized(self)
        {
            _session = nil;
            if (_sessionCompletedHandler)
            {
                _sessionCompletedHandler();
            }
        }
    }];
}

- (void) interrupt:(void(^)())completedHandler;
{

    [_session interrupt:^{
        @synchronized(self)
        {
            NSLog(@"Session interrupted");
            _session = nil;
            completedHandler();
        }
    }];
}

- (int) stop;
{
    @synchronized(self)
    {
        if (_session)
        {
            [_session stop];
            _session = nil;
        }
        
        if (_sessionCompletedHandler)
        {
            _sessionCompletedHandler = nil;
        }
    }
    
    return [_sprite currentFrame:_animation];
}

- (float) interval;
{
    return _interval;
}

- (void) showFrame:(int)frameNr;
{
    CCSpriteFrame* frame = [self frame:frameNr];
    if (frame)
    {
        [_sprite setDisplayFrame:frame];
    }
}

- (CCSpriteFrame*) frame:(int)frameNr;
{
    NSString* nextFrame = [NSString stringWithFormat:@"%@%04d.png", _prefix, frameNr];
    return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:nextFrame];
}

#pragma mark - ScriptFramesDataSource

- (NSArray*) framesFrom:(int)from to:(int)to
{
    NSMutableArray* frames = [[NSMutableArray alloc] init];
    for(int i=from; i<=to; i++)
    {
        CCSpriteFrame *frame = [self frame:i];
        if (frame)
        {
            [frames addObject:frame];
        }
        else
        {
            NSLog(@"frame %i not found", i);
        }
    }
    return frames;
}

#pragma mark - CCNode Actions

-(void) setActionManager:(CCActionManager *)actionManager
{
	if( actionManager != _actionManager ) {
		[self stopAllActions];
		_actionManager = actionManager;
	}
}

-(CCActionManager*) actionManager
{
	return _actionManager;
}

@end
