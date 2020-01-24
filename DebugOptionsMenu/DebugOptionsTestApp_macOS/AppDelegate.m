//
//  AppDelegate.m
//  DebugOptionsTestApp_macOS
//
//  Created by Kai Bruening on 27.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "AppDelegate.h"
#import <DebugOptionsMenu/DebugOptionsMenu.h>

NS_ASSUME_NONNULL_BEGIN

// This tag value is set on the sub menu item which holds the help menu, thereby inserting the debug menu before
// the help menu.
static NSUInteger const DebugMenuInsertMenuItemTag = 4711;

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    PWRootDebugOptionGroup* _rootDebugOptionGroup;
}

- (void)applicationWillFinishLaunching:(NSNotification*)notification
{
    // Create the debug option tree as early as possible.
    _rootDebugOptionGroup = [PWRootDebugOptionGroup createRootGroup];

    // Important: must keep the debug option tree alive by referencing it from a strong ivar.
    // Also important: must always create the option tree, even if the menu is disabled. Else default values set in the
    // options would not come to play.
    if (PWRootDebugOptionGroup.isDebugMenuEnabled)
        [_rootDebugOptionGroup insertDebugMenuInMainMenu:NSApp.mainMenu beforeItemWithTag:DebugMenuInsertMenuItemTag];

    if (TestAppEnableBasicLogging)
        NSLog (@"applicationWillFinishLaunching:%@", notification);
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    if (TestAppEnableBasicLogging)
        NSLog (@"applicationDidFinishLaunching:%@", notification);
}


- (void)applicationWillTerminate:(NSNotification*)notification
{
    if (TestAppEnableBasicLogging)
        NSLog (@"applicationDidFinishLaunching:%@", notification);
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)sender hasVisibleWindows:(BOOL)flag
{
    if (TestAppEnableBasicLogging)
        NSLog (@"applicationShouldHandleReopen:%@ hasVisibleWindows:%i", sender, flag);
    return YES;
}

@end

DEBUG_OPTION_DEFINE_GROUP (TestAppDebugSubGroup, PWRootDebugOptionGroup,
                           @"Test App", @"Sub group for the Debug Menu Test App")

DEBUG_OPTION_DEFINE_SWITCH (TestAppEnableBasicLogging, TestAppDebugSubGroup,
                            @"Enable Basic Logging", @"Logs important events to the (debugger) console",
                            DEBUG_OPTION_PERSISTENT)

NS_ASSUME_NONNULL_END
