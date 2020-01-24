//
//  PWDebugMenu.h
//  PWAppKit
//
//  Created by Kai Brüning on 26.1.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import <DebugOptionsFoundation/DebugOptionsFoundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWDebugOptionGroup (PWDebugMenu)

- (NSMenu*) createMenu;

@end

#pragma mark -

@interface PWRootDebugOptionGroup (PWDebugMenu)

// Note: this method sets isDebugMenuEnabled to YES if NDEBUG is not defined. This enables the debug menu if the
// release version is later run on the same machine.
- (void) insertDebugMenuInMainMenu:(NSMenu*)mainMenu beforeItemWithTag:(NSInteger)aTag;

- (void) createDebugMenuInMenuItem:(NSMenuItem*)debugMenuItem;

@end

#pragma mark -

@interface PWDebugOption (PWDebugMenu)

@property (nonatomic, readonly)         NSInteger   orderInMenu;    // default is 0, -100 for sub menus

@property (nonatomic, readonly, copy)   NSString*   menuItemTitle;  // default is self.title

// Must be implemented by sub classes.
- (void) addMenuItemToMenu:(NSMenu*)menu;

// Create a basic menu item for this debug item. For use by sub classes.
- (NSMenuItem*) createMenuItemWithAction:(nullable SEL)selector;

@end

NS_ASSUME_NONNULL_END
