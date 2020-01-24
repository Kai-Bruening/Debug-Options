//
//  PWDebugOptions.m
//  DebugOptionsFoundation
//
//  Created by Kai Brüning on 26.1.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "PWDebugOptionMacros.h"

#import "PWDebugOptions.h"
#import "PWDebugOptionGroup.h"
#import <stdarg.h>

NS_ASSUME_NONNULL_BEGIN

@implementation PWDebugOption

@dynamic kvValue;   // must be implemented by subclass

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
{
    NSParameterAssert (title);
    self = [super init];
    _title   = [title copy];
    _toolTip = [toolTip copy];
    return self;
}

- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults
{
    NSParameterAssert (userDefaults);
}

+ (NSString*) defaultsKeyForDebugOptionName:(NSString*)name
{
    NSParameterAssert (name);
    return [@"DebugOption_" stringByAppendingString:name];
}

@end

#pragma mark -

@implementation PWDebugOptionSubGroup

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                      subGroup:(Class)subGroupClass
         userDefaultsSuiteName:(nullable NSString*)userDefaultsSuiteName
{
    NSParameterAssert (subGroupClass);
    
    self = [super initWithTitle:title toolTip:toolTip];
    _subGroup = [[subGroupClass alloc] initWithUserDefaultsSuiteName:userDefaultsSuiteName];
    return self;
}

- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults
{
    NSParameterAssert (userDefaults);
    [_subGroup loadStateFromUserDefaults:userDefaults];
}

@end

#pragma mark -

@implementation PWDebugSwitchOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                 booleanTarget:(_Atomic (BOOL)*)target defaultValue:(BOOL)value
             defaultsKeySuffix:(nullable NSString*)keySuffix
{
    NSParameterAssert (target);
    
    self = [super initWithTitle:title toolTip:toolTip];
    _target  = target;
    *_target = value;
    if (keySuffix)
        _defaultsKey = [self.class defaultsKeyForDebugOptionName:keySuffix];
    return self;
}

- (BOOL) currentValue
{
    return *_target;
}

- (void) setCurrentValue:(BOOL)value
{
    [self.groupClass willChangeValueForKey:self.propertyName];
    *_target = value;
    [self.groupClass didChangeValueForKey:self.propertyName];
}

- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults
{
    NSParameterAssert (userDefaults);

    if (_defaultsKey) {
        NSNumber* defaultValue = [userDefaults objectForKey:_defaultsKey];
        if (defaultValue)
            *_target = defaultValue.boolValue;
        _userDefaults = userDefaults;
    }
}

- (void) saveState
{
    if (_defaultsKey && _userDefaults) {
        [_userDefaults setBool:self.currentValue forKey:_defaultsKey];
        [_userDefaults synchronize]; // make it persistent even if the app is killed soon after
    }
}

- (nullable id) kvValue
{
    return @(self.currentValue);
}

- (void) setKvValue:(nullable id)kvValue
{
    NSParameterAssert (kvValue);
    self.currentValue = [kvValue boolValue];
}

@end

#pragma mark -

@implementation PWDebugEnumOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                     asSubMenu:(BOOL)flag
                        target:(_Atomic (NSInteger)*)target
                  defaultValue:(NSInteger)value
             defaultsKeySuffix:(nullable NSString*)keySuffix
               titlesAndValues:(NSString*)firstTitle, ...
{
    NSParameterAssert (target);
    NSParameterAssert (firstTitle);

    self = [super initWithTitle:title toolTip:toolTip];
    _asSubMenu = flag;
    _target    = target;
    *_target   = value;

    // Collect titles and values.
    NSMutableArray<NSString*>* theTitles = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber*>* theValues = [[NSMutableArray alloc] init];
    va_list ap;
    va_start (ap, firstTitle);

    NSString* iTitle = firstTitle;
    while (iTitle) {
        [theTitles addObject:iTitle];
        [theValues addObject:@(va_arg (ap, int))];

        iTitle = va_arg (ap, NSString*);
    }

    va_end (ap);

    _values = [theValues copy];
    _titles = [theTitles copy];

    if (keySuffix) {
        _defaultsKey = [self.class defaultsKeyForDebugOptionName:keySuffix];
//        id defaultValue = [NSUserDefaults.standardUserDefaults objectForKey:_defaultsKey];
//        if (defaultValue)
//            *_target = [defaultValue integerValue];
    }
    return self;
}

- (NSInteger) currentValue
{
    return *_target;
}

- (void) setCurrentValue:(NSInteger)value
{
    [self.groupClass willChangeValueForKey:self.propertyName];
    *_target = value;
    [self.groupClass didChangeValueForKey:self.propertyName];
}

- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults
{
    NSParameterAssert (userDefaults);

    if (_defaultsKey) {
        NSNumber* defaultValue = [userDefaults objectForKey:_defaultsKey];
        if (defaultValue)
            *_target = defaultValue.integerValue;
        _userDefaults = userDefaults;
    }
}

- (void) saveState
{
    if (_defaultsKey && _userDefaults) {
        [_userDefaults setInteger:self.currentValue forKey:_defaultsKey];
        [_userDefaults synchronize]; // make it persistent even if the app is killed soon after
    }
}

- (nullable id) kvValue
{
    return @(self.currentValue);
}

- (void) setKvValue:(nullable id)kvValue
{
    NSParameterAssert (kvValue);
    self.currentValue = [kvValue integerValue];
}

@end

#pragma mark -

@implementation PWDebugTextOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                  stringTarget:(__strong NSString*_Nullable *_Nonnull)target
             defaultsKeySuffix:(nullable NSString*)keySuffix;
{
    NSParameterAssert (target);
    
    self = [super initWithTitle:title toolTip:toolTip];
    _target  = target;
    *_target = nil;
    if (keySuffix) {
        _defaultsKey = [self.class defaultsKeyForDebugOptionName:keySuffix];
//        id defaultValue = [NSUserDefaults.standardUserDefaults objectForKey:_defaultsKey];
//        if ([defaultValue isKindOfClass:NSString.class])
//            *_target = defaultValue;
    }
    return self;
}

- (nullable NSString*) currentValue
{
    return *_target;
}

- (void) setCurrentValue:(nullable NSString*)value
{
    [self.groupClass willChangeValueForKey:self.propertyName];
    *_target = value;
    [self.groupClass didChangeValueForKey:self.propertyName];
}

- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults
{
    NSParameterAssert (userDefaults);

    if (_defaultsKey) {
        id defaultValue = [userDefaults objectForKey:_defaultsKey];
        if ([defaultValue isKindOfClass:NSString.class])
            *_target = defaultValue;
        _userDefaults = userDefaults;
    }
}

- (void) saveState
{
    if (_defaultsKey && _userDefaults) {
        [_userDefaults setObject:self.currentValue forKey:_defaultsKey];
        [_userDefaults synchronize]; // make it persistent even if the app is killed soon after
    }
}

- (nullable id) kvValue
{
    return self.currentValue;
}

- (void) setKvValue:(nullable id)kvValue
{
    NSParameterAssert (kvValue);
    self.currentValue = kvValue;
}

@end

#pragma mark -

@implementation PWDebugActionBlockOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                   actionBlock:(PWDebugActionBlock)block
{
    NSParameterAssert (block);
    
    self = [super initWithTitle:title toolTip:toolTip];
    _block = [block copy];
    return self;
}

- (void) execute:(nullable id)sender
{
    _block();
}

@end

#pragma mark -

@implementation PWDebugActionWithNamedTargetOption

- (instancetype) initWithTitle:(NSString*)title toolTip:(nullable NSString*)toolTip
                observableName:(NSString*)name
                       keyPath:(nullable NSString*)keyPath
                  selectorName:(NSString*)selectorName
                       options:(nullable NSDictionary*)dict
{
    NSParameterAssert (name);
    NSParameterAssert (selectorName);
    
    self = [super initWithTitle:title toolTip:toolTip];
    _observableName = [name copy];
    _keyPath        = [keyPath copy];
    _selectorName   = [selectorName copy];
    _options        = [dict copy];
    return self;
}

@end

#pragma mark -

@implementation PWDebugNamedObservables
@end

NS_ASSUME_NONNULL_END
