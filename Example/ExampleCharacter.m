//
//  ExampleCharacter.m
//
//  Created by Emiel on 11-11-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import "ExampleCharacter.h"

@implementation ExampleCharacter

- (id)init
{
    self = [super initWithNames:[NSArray arrayWithObjects:@"example_character",@"example_character_walk", nil] prefix:@"klant 2 los" frameCount:105 interval:DEFAULT_INTERVAL loadTextures:YES];
    return self;
}

- (void) preloadingDone;
{
    NSLog(@"Preloading spritesheet done.. ");
}

- (NSDictionary*) actions;
{
    NSMutableDictionary* actions = [[NSMutableDictionary alloc] init];
    [actions setObject:@"1-15#20" forKey:@"walkIn"];
    [actions setObject:@"16-24" forKey:@"stopWalking"];
    [actions setObject:@"15-1#-20" forKey:@"walkOut"];
    [actions setObject:@"26-56" forKey:@"order"];
    [actions setObject:@"56-62" forKey:@"winking"];
    [actions setObject:@"63-86" forKey:@"angry"];
    [actions setObject:@"87-105" forKey:@"happy"];
    [actions setObject:@"|*10" forKey:@"pause"];    
    return actions;
}

@end
