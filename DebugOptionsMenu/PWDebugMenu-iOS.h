//
//  PWDebugMenu-iOS.h
//  PWAppKit
//
//  Created by Berbie on 15.08.16.
//  Copyright © 2016 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import <DebugOptionsFoundation/DebugOptionsFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A singleton instance of PWDebugMenuController typically lives in a property on the MainController. 
 From there, any viewController may pull up the debug menu by calling presentDebugMenu. 
 Available debug menu options are declared in code, see <PWFoundation/PWDebugOptionMacros.h>
 */
@interface PWDebugMenuController : NSObject

- (instancetype) initWithRootDebugOptionGroup:(PWRootDebugOptionGroup*)rootDebugOptionGroup NS_DESIGNATED_INITIALIZER;
- (instancetype) init NS_UNAVAILABLE;

- (void) presentDebugMenuCompletionHandler:(void (^_Nullable) (void))completionHandler;

@end

NS_ASSUME_NONNULL_END
