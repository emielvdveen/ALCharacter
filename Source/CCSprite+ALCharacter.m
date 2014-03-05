//
//  CCSprite+ALCharacter.m
//
//  Created by Emiel on 07-11-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import "CCSprite+ALCharacter.h"

@implementation CCSprite (ALCharacter)

+ (CCSprite*) spriteWithPNG:(NSString*)filename;
{
    if ([UIScreen mainScreen].scale == 2 )
    {
        filename = [NSString stringWithFormat:@"%@@2x.png", filename];
    }
    else
    {
        filename = [NSString stringWithFormat:@"%@.png", filename];
    }
    
    return [CCSprite spriteWithFile:filename];
}

-(int)currentFrame:(CCAnimation*)animation
{
	int imageIndex = 0;
	for (int i=0; i<[animation.frames count]; i++) {
		CCAnimationFrame *frame = [[animation frames] objectAtIndex:i];
        CCSpriteFrame* spriteFrame = frame.spriteFrame;
        if ([self isFrameDisplayed:spriteFrame])
        {
			imageIndex = i+1;
			break;
		}
	}
	return imageIndex;
}

@end
