//
//  NSString+ALCharacter.m
//
//  Created by Emiel on 08-01-13.
//  Copyright (c) 2013 Applike. All rights reserved.
//

#import "NSString+ALCharacter.h"

@implementation NSString (ALCharacter)

- (BOOL) startsWith:(NSString*)substring;
{
    if (self.length < substring.length)
    {
        return NO;
    }
    
    return ([[self substringWithRange:NSMakeRange(0, substring.length)] isEqualToString:substring]);
}


@end
