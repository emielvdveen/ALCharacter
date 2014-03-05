//
//  ExampleLayer.m
//
//  Created by Emiel on 06-11-12.
//  Copyright Applike 2012. All rights reserved.
//


// Import the interfaces
#import "ExampleLayer.h"
#import "ExampleCharacter.h"
#import "CCSprite+ALCharacter.h"


#pragma mark - ExampleLayer


@interface ExampleLayer ()

@property (nonatomic, strong) ExampleCharacter* character;

@end

@implementation ExampleLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ExampleLayer *layer = [ExampleLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// 
-(id) init
{
	if( (self=[super init]))
    {
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

		CCSprite *background;
        background = [CCSprite spriteWithPNG:@"background"];
		background.position = ccp(size.width/2, size.height/2);

		// add the label as a child to this Layer
		[self addChild: background];
        
        _character = [ExampleCharacter new];
        _character.sprite.anchorPoint = ccp(0,0);
        _character.sprite.position = ccp(-300, 165);
        
		[self addChild: _character];
        
        [self executeScript];
	}
	
	return self;
}

- (void) executeScript;
{
    // ^ = interuptable moment in the animation, if another script is executed it wil try to interupted the running
    NSString* script = @"walkIn stopWalking ^ order pause angry ^ order winking pause happy ^ walkOut";
    [_character run:script completed:^{
        [self executeScript2];
    }];
}

- (void) executeScript2;
{
    [_character run:@"walkIn stopWalking" completed:^{
        [_character run:@"order pause angry" completed:^{
            [_character run:@"order winking pause happy" completed:^{
                [_character run:@"walkOut" completed:^{
                    [self executeScript];
                }];
            }];
        }];
    }];
}


@end
