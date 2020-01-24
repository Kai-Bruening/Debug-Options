//
//  AppDelegate.h
//  DebugOptionsTestApp_iOS
//
//  Created by Kai Bruening on 29.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import <UIKit/UIKit.h>
#import <DebugOptionsFoundation/DebugOptionsFoundation.h>

NS_ASSUME_NONNULL_BEGIN

DEBUG_OPTION_DECLARE_GROUP (TestAppDebugSubGroup)
DEBUG_OPTION_DECLARE_SWITCH (TestAppEnableBasicLogging, DEBUG_OPTION_DEFAULT_OFF)

@class PWDebugMenuController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, readonly, strong, nullable)   PWDebugMenuController*  debugMenuController;

@end

NS_ASSUME_NONNULL_END
