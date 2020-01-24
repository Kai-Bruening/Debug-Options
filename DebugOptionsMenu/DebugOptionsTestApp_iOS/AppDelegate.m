//
//  AppDelegate.m
//  DebugOptionsTestApp_iOS
//
//  Created by Kai Bruening on 29.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "AppDelegate.h"
#import <DebugOptionsMenu/DebugOptionsMenu.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    PWRootDebugOptionGroup* _rootDebugOptionGroup;
}

@synthesize window = _window;

- (void) setWindow:(nullable UIWindow*)window
{
    _window = window;
}

- (BOOL)                application:(UIApplication*)application
     willFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id>*)launchOptions
{
    // Create the debug option tree as early as possible.
    _rootDebugOptionGroup = [PWRootDebugOptionGroup createRootGroup];

    if (PWRootDebugOptionGroup.isDebugMenuEnabled)
        _debugMenuController = [[PWDebugMenuController alloc] initWithRootDebugOptionGroup:_rootDebugOptionGroup];
    
    if (TestAppEnableBasicLogging)
        NSLog (@"application:willFinishLaunchingWithOptions:%@", launchOptions);

    return YES;
}

- (BOOL)                application:(UIApplication*)application
      didFinishLaunchingWithOptions:(nullable NSDictionary<UIApplicationLaunchOptionsKey, id>*)launchOptions
{
    // Override point for customization after application launch.

    if (TestAppEnableBasicLogging)
        NSLog (@"application:didFinishLaunchingWithOptions:%@", launchOptions);

    return YES;
}

@end

DEBUG_OPTION_DEFINE_GROUP (TestAppDebugSubGroup, PWRootDebugOptionGroup,
                           @"Test App", @"Sub group for the Debug Menu Test App")

DEBUG_OPTION_DEFINE_SWITCH (TestAppEnableBasicLogging, TestAppDebugSubGroup,
                            @"Enable Basic Logging", @"Logs important events to the (debugger) console",
                            DEBUG_OPTION_PERSISTENT)

NS_ASSUME_NONNULL_END
