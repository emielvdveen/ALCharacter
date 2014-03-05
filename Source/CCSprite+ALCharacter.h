//
//  CCSprite+ALCharacter.h
//
//  Created by Emiel on 07-11-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import "cocos2d.h"

@interface CCSprite (ALCharacter)

+ (CCSprite*) spriteWithPNG:(NSString*)filename;

-(int)currentFrame:(CCAnimation*)animation;

@end
