//
//  PWDebugOptionGroup.m
//  DebugOptionsFoundation
//
//  Created by Kai Brüning on 26.1.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "PWDebugOptionMacros.h"

#import "PWDebugOptionGroup.h"
#import "PWDebugOptions.h"
//#import "NSArray-PWExtensions.h"
#import <objc/runtime.h>
#import <os/lock.h>

NS_ASSUME_NONNULL_BEGIN

NSString* const PWDebugOptionMenuIsEnabledKey = @"DebugOptionMenuIsEnabled";

/// Value object for registering KV-observations on group classes.
@interface PWDebugOptionGroupObservationInfo : NSObject

- (instancetype) initWithObserver:(NSObject*)observer
                              key:(NSString*)key
                          options:(NSKeyValueObservingOptions)options
                          context:(nullable void*)context
                    forGroupClass:(Class)groupClass;

@property (nonatomic, readonly, weak)       NSObject*                   observer;
@property (nonatomic, readonly, copy)       NSString*                   key;
@property (nonatomic, readonly)             NSKeyValueObservingOptions  options;
@property (nonatomic, readonly, nullable)   void*                       context;
@property (nonatomic, readonly)             Class                       groupClass;

@end

#pragma mark -

@implementation PWDebugOptionGroup
{
    NSMutableArray<PWDebugOption*>* _options;
}

@synthesize options = _options;

- (instancetype) initWithUserDefaultsSuiteName:(nullable NSString*)userDefaultsSuiteName
{
    self = [super init];
    _userDefaultsSuiteName = [userDefaultsSuiteName copy];
    _options = [[NSMutableArray alloc] init];

    // Call all methods which begin with 'createOption'.
    Method* methods = class_copyMethodList (self.class, /*outCount =*/NULL);
    if (methods) { // is nil if the class does not have any methods on this hierarchy level
        for (Method* iMethod = methods; *iMethod; ++iMethod) {
            // We’re only interested in methods which have no arguments beyond self and cmd.
            if (method_getNumberOfArguments (*iMethod) == 2) {
                SEL iSel = method_getName (*iMethod);
                NSString* iSelName = NSStringFromSelector (iSel);
                if ([iSelName hasPrefix:@"createOption"]) {
                    // Create the option.
                #pragma clang diagnostic push
                #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self performSelector:iSel];
                #pragma clang diagnostic pop
                }
            }
        }
        free (methods);
    }
    return self;
}

- (void) loadStateFromUserDefaults:(NSUserDefaults*)userDefaults
{
    NSParameterAssert (userDefaults);

    // Use a specific user defaults suite if requested by providing a userDefaultsSuiteName.
    // Used to share debug options inside an app group.
    if (_userDefaultsSuiteName)
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:_userDefaultsSuiteName];

    for (PWDebugOption* iOption in _options)
        [iOption loadStateFromUserDefaults:userDefaults];
}

- (void) addOption:(PWDebugOption*)option
{
    NSParameterAssert ([option isKindOfClass:PWDebugOption.class]);
    [_options addObject:option];
}

- (void) addOption:(PWDebugOption*)option withPropertyName:(NSString*)propertyName
{
    NSParameterAssert ([option isKindOfClass:PWDebugOption.class]);
    NSParameterAssert (propertyName);

    [_options addObject:option];
    option.groupClass = self.class;
    option.propertyName = propertyName;
}

- (nullable PWDebugOption*) optionWithTitle:(NSString*)title
{
    NSParameterAssert (title);
    NSUInteger index = [_options indexOfObjectPassingTest:^(PWDebugOption* iOption, NSUInteger idx, BOOL* stop) {
        return [iOption.title isEqualToString:title];
    }];
    return (index != NSNotFound) ? _options[index] : nil;
}

- (void) sortOptionsUsingComparator:(NSComparator)comparator
{
    NSParameterAssert (comparator);
    [_options sortUsingComparator:comparator];
}

#pragma mark - KV Observing

// Manual registration of observers on group classes (as opposed to instances).

// Protected by sObservationsLock.
static NSMutableArray<PWDebugOptionGroupObservationInfo*>* sObservations;

static os_unfair_lock sObservationsLock = OS_UNFAIR_LOCK_INIT;

+ (void) addObserver:(NSObject*)observer
          forKeyPath:(NSString*)keyPath
             options:(NSKeyValueObservingOptions)options
             context:(nullable void*)context
{
    NSAssert ([keyPath rangeOfString:@"."].location == NSNotFound, @"key paths are not (yet) supported here");
    NSAssert (options == 0, @"options are not (yet) supported here");

    PWDebugOptionGroupObservationInfo* info = [[PWDebugOptionGroupObservationInfo alloc] initWithObserver:observer
                                                                                                      key:keyPath
                                                                                                  options:options
                                                                                                  context:context
                                                                                            forGroupClass:self];
    os_unfair_lock_lock (&sObservationsLock);
    if (!sObservations)
        sObservations = [[NSMutableArray alloc] init];
    [sObservations addObject:info];
    os_unfair_lock_unlock (&sObservationsLock);
}

+ (void) removeObserver:(NSObject*)observer
             forKeyPath:(NSString*)keyPath
                context:(nullable void*)context
{
    os_unfair_lock_lock (&sObservationsLock);
    for (NSUInteger i = 0; i < sObservations.count; ) {
        PWDebugOptionGroupObservationInfo* iInfo = sObservations[i];
        if (   iInfo.observer == observer
            && [iInfo.key isEqualToString:keyPath]
            && iInfo.context == context
            && iInfo.groupClass == self)
            [sObservations removeObjectAtIndex:i];
        else
            ++i;
    }
    os_unfair_lock_unlock (&sObservationsLock);
}

+ (void) willChangeValueForKey:(NSString*)key
{
    NSParameterAssert (key);
    [super willChangeValueForKey:key];
    // TODO: determine old value if we want to support observation options.
}

+ (void) didChangeValueForKey:(NSString*)key
{
    NSParameterAssert (key);

    NSMutableArray<PWDebugOptionGroupObservationInfo*>* matchingObservations = [[NSMutableArray alloc] init];
    os_unfair_lock_lock (&sObservationsLock);
    for (PWDebugOptionGroupObservationInfo* iInfo in sObservations) {
        if (   [iInfo.key isEqualToString:key]
            && iInfo.groupClass == self)
            [matchingObservations addObject:iInfo];
    }
    os_unfair_lock_unlock (&sObservationsLock);

    for (PWDebugOptionGroupObservationInfo* iInfo in matchingObservations)
        [iInfo.observer observeValueForKeyPath:iInfo.key
                                      ofObject:self
                                        change:@{ NSKeyValueChangeKindKey: @(NSKeyValueChangeSetting) }
                                       context:iInfo.context];
    [super didChangeValueForKey:key];
}

@end

#pragma mark -

@implementation PWRootDebugOptionGroup

+ (PWRootDebugOptionGroup*) createRootGroup
{
    PWRootDebugOptionGroup* rootGroup = [[self alloc] initWithUserDefaultsSuiteName:nil];
    [rootGroup loadStateFromUserDefaults:NSUserDefaults.standardUserDefaults];
    return rootGroup;
}

+ (PWRootDebugOptionGroup*) sharedRootGroup
{
    static PWRootDebugOptionGroup* sSharedRootGroup;
    static dispatch_once_t sSharedRootGroupPredicate = 0;
    dispatch_once (&sSharedRootGroupPredicate,^{
        sSharedRootGroup = [self createRootGroup];
    });
    return sSharedRootGroup;
}

+ (BOOL) isDebugMenuEnabled
{
#ifdef NDEBUG
    return [NSUserDefaults.standardUserDefaults boolForKey:PWDebugOptionMenuIsEnabledKey];
#else
    return YES;
#endif
}

+ (void) setIsDebugMenuEnabled:(BOOL)value
{
    [NSUserDefaults.standardUserDefaults setBool:value forKey:PWDebugOptionMenuIsEnabledKey];
}

@end

#pragma mark -

@implementation PWDebugOptionGroupObservationInfo

- (instancetype) initWithObserver:(NSObject*)observer
                              key:(NSString*)key
                          options:(NSKeyValueObservingOptions)options
                          context:(nullable void*)context
                    forGroupClass:(Class)groupClass
{
    NSParameterAssert (observer);
    NSParameterAssert (key);
    NSParameterAssert ([key rangeOfString:@"."].location == NSNotFound);
    NSParameterAssert (groupClass);

    self = [super init];
    _observer   = observer;
    _key        = [key copy];
    _options    = options;
    _context    = context;
    _groupClass = groupClass;
    return self;
}

@end

NS_ASSUME_NONNULL_END
