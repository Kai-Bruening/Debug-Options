//
//  DebugOptionsMenu.h
//  DebugOptionsMenu
//
//  Created by Kai Bruening on 23.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import <Foundation/Foundation.h>
#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for DebugOptionsMenu.
FOUNDATION_EXPORT double DebugOptionsMenuVersionNumber;

//! Project version string for DebugOptionsMenu.
FOUNDATION_EXPORT const unsigned char DebugOptionsMenuVersionString[];

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)
#import <DebugOptionsMenu/PWDebugMenu-iOS.h>
#else
#import <DebugOptionsMenu/PWDebugMenu.h>
#endif
