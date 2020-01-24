//
//  PWDebugOptionGroup.h
//  DebugOptionsFoundation
//
//  Created by Kai Brüning on 26.1.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PWDebugOption;


@interface PWDebugOptionGroup : NSObject

- (instancetype) initWithUserDefaultsSuiteName:(nullable NSString*)userDefaultsSuiteName NS_DESIGNATED_INITIALIZER;
- (instancetype) init NS_UNAVAILABLE;

@property (nonatomic, readonly, copy, nullable) NSString*                   userDefaultsSuiteName;

@property (nonatomic, readonly, copy)           NSArray<PWDebugOption*>*    options;

- (void) addOption:(PWDebugOption*)anOption;

/// Options added with this method can support KVO.
- (void) addOption:(PWDebugOption*)anOption withPropertyName:(NSString*)propertyName;

/// nil if no item with 'title' exists.
- (nullable __kindof PWDebugOption*) optionWithTitle:(NSString*)title;

- (void) sortOptionsUsingComparator:(NSComparator)comparator;

- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults;

@end

#pragma mark -

/// Value under this key in user defaults determines whether the debug menu is visible in release builds.
extern NSString* const PWDebugOptionMenuIsEnabledKey;

@interface PWRootDebugOptionGroup : PWDebugOptionGroup

/// Create the complete tree of groups and options and load the status from user defaults.
/// Creates a new tree each time this is called, which should be once only.
+ (PWRootDebugOptionGroup*) createRootGroup;

/// Ensure there’s a single shared instance of the debug option tree.
@property (readonly, strong, class) PWRootDebugOptionGroup* sharedRootGroup;

/// Always YES if NDEBUG is not defined, else the state of the user default value under PWDebugOptionMenuIsEnabledKey.
/// Setter sets user default value, independent of NDEBUG state.
/// Note: convenience for the UI layer, not used at this layer.
@property (nonatomic, readwrite, class) BOOL    isDebugMenuEnabled;

@end

NS_ASSUME_NONNULL_END
