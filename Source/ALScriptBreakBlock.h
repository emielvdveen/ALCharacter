//
//  ALScriptBreak.h
//
//  Created by Emiel on 06-12-12.
//  Copyright (c) 2012 Applike. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Placeholder object that makes it possible to mark when an animation script can be interrupted and possibly succeeded with another script. 
 Typically an animation should be interruptable when it is in a base position.
 */
@interface ALScriptBreakBlock : NSObject

@end
