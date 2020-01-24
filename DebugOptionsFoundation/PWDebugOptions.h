//
//  PWDebugOptions.h
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

@class PWDebugOptionGroup;

typedef void (^PWDebugActionBlock) (void);


#pragma mark -

@interface PWDebugOption : NSObject

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip NS_DESIGNATED_INITIALIZER;
- (instancetype) init NS_UNAVAILABLE;

@property (nonatomic, readonly, copy)               NSString*           title;
@property (nonatomic, readonly, copy, nullable)     NSString*           toolTip;

// Used for KVO support.
@property (nonatomic, readwrite, nullable)          Class               groupClass;
@property (nonatomic, readwrite, copy, nullable)    NSString*           propertyName;

/// currentValue from subclasses boxed as necessary.
/// Note: currently unused.
@property (nonatomic, readwrite, nullable)          id                  kvValue;

// Base implementation does nothing.
- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults;

+ (NSString*) defaultsKeyForDebugOptionName:(NSString*)name;

@end

#pragma mark -

@interface PWDebugOptionSubGroup : PWDebugOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                      subGroup:(Class)subGroupClass
         userDefaultsSuiteName:(nullable NSString*)userDefaultsSuiteName NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip NS_UNAVAILABLE;

@property (nonatomic, readonly)    PWDebugOptionGroup* subGroup;

@end

#pragma mark -

@interface PWDebugSwitchOption : PWDebugOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                 booleanTarget:(_Atomic (BOOL)*)target defaultValue:(BOOL)value
             defaultsKeySuffix:(nullable NSString*)keySuffix NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip NS_UNAVAILABLE;

@property (nonatomic, readonly)                     _Atomic (BOOL)* target;
@property (nonatomic, readwrite)                    BOOL            currentValue;

@property (nonatomic, readonly, copy,   nullable)   NSString*       defaultsKey;
@property (nonatomic, readonly, strong, nullable)   NSUserDefaults* userDefaults;

// Save current value in user defaults
- (void) saveState;

@end

#pragma mark -

@interface PWDebugEnumOption : PWDebugOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                     asSubMenu:(BOOL)flag
                        target:(_Atomic (NSInteger)*)target
                  defaultValue:(NSInteger)value
             defaultsKeySuffix:(nullable NSString*)keySuffix
               titlesAndValues:(NSString*)firstTitle, ... NS_REQUIRES_NIL_TERMINATION NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip NS_UNAVAILABLE;

@property (nonatomic, readonly)                     BOOL                    asSubMenu;
@property (nonatomic, readonly)                     _Atomic (NSInteger)*    target;
@property (nonatomic, readonly, copy)               NSArray<NSNumber*>*     values;
@property (nonatomic, readonly, copy)               NSArray<NSString*>*     titles;

@property (nonatomic, readwrite)                    NSInteger               currentValue;

@property (nonatomic, readonly, copy, nullable)     NSString*               defaultsKey;
@property (nonatomic, readonly, strong, nullable)   NSUserDefaults*         userDefaults;

// Save current value in user defaults
- (void) saveState;

@end

#pragma mark -

@interface PWDebugTextOption : PWDebugOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                  stringTarget:(__strong NSString*_Nullable *_Nonnull)target
             defaultsKeySuffix:(nullable NSString*)keySuffix NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip NS_UNAVAILABLE;

@property (nonatomic, readonly)                     __strong NSString*_Nullable *_Nonnull   target;

@property (nonatomic, readwrite, copy, nullable)    NSString*                               currentValue;

@property (nonatomic, readonly,  copy, nullable)    NSString*                               defaultsKey;
@property (nonatomic, readonly, strong, nullable)   NSUserDefaults*                         userDefaults;

// Save current value in user defaults
- (void) saveState;

@end

#pragma mark -

@interface PWDebugActionBlockOption : PWDebugOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                   actionBlock:(PWDebugActionBlock)block NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip NS_UNAVAILABLE;

@property (nonatomic, readonly, copy)    PWDebugActionBlock      block;

- (void) execute:(nullable id)sender;

@end

#pragma mark -

@interface PWDebugActionWithNamedTargetOption : PWDebugOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                observableName:(NSString*)name
                       keyPath:(nullable NSString*)keyPath
                  selectorName:(NSString*)selectorName
                       options:(nullable NSDictionary<NSString*, id>*)options NS_DESIGNATED_INITIALIZER;

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip NS_UNAVAILABLE;

@property (nonatomic, readonly, copy)           NSString*                       observableName;
@property (nonatomic, readonly, copy, nullable) NSString*                       keyPath;
@property (nonatomic, readonly, copy)           NSString*                       selectorName;
@property (nonatomic, readonly, copy, nullable) NSDictionary<NSString*, id>*    options;

@end

#pragma mark -

@interface PWDebugNamedObservables : NSObject
@end

NS_ASSUME_NONNULL_END
