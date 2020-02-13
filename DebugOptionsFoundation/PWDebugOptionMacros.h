/*
 *  PWDebugOptionMacros.h
 *  DebugOptionsFoundation
 *
 *  Created by Kai Brüning on 26.1.10.
 *  Copyright 2010 ProjectWizards. All rights reserved.
 *
 *  You may incorporate this code into your program(s) without restriction. This code has been
 *  provided “AS IS” and the responsibility for its operation is yours.
 */

/*
 
 Debug options are an easy way to add runtime switches and actions. Debug options are organized in debug option groups,
 which form a hierarchy.
 In AppKit applications the debug options are bound to a debug menu, with each debug group mapped to its own sub menu.
 For other programs binding of the debug options to command line parameters may be implemented.
 
 Debug options are created by placing macro invocations in the source code. Some of these macros are meant for use
 in headers, others for use in implementation files. All of them must be placed outside of any @interface or
 @implementation section.
 
 Debug option macros have the following common parameters:
 
 aName:         The internal name of the option. Must be unique per compilation unit for implementation file macros
                resp. globally for header file macros.
 targetGroup:   The option group to which an options is being added. The root group is provided with the name
                PWRootDebugOptionGroup.
 aTitle:        The title of the option as used in the debug menu.
 aToolTip:      Optional description of the option for display as menu tool tip or command line help.
 
 Invocation of the debug option macros must NOT be followed by a semicolon.

 
 Debug option groups ---------------------------------------------------------------------------------------------------
 
 The root group 'PWRootDebugOptionGroup' is predefined. Sub groups are declared with
 
    DEBUG_OPTION_DECLARE_GROUP (aName)
 
 aName is the name of the sub group and can be used as 'targetGroup' for further options. This macro is typically used
 in a header to make the sub group available to multiple implementation files.

 Each sub group must be defined in an implementation file with
 
    DEBUG_OPTION_DEFINE_GROUP (aName, targetGroup, aTitle, aToolTip)
 or
    DEBUG_OPTION_DEFINE_GROUP_WITHDEFAULTSSUITE (aName, targetGroup, aTitle, aToolTip, suiteName)

 This adds the new sub group as one option of a parent group, forming a hierarchy of option groups.
 The second variant provides a user defaults suite name which can be used to share debug options between the members
 of an app group. Pass the app group identifier as suiteName in this case.

 
 Debug option switches -------------------------------------------------------------------------------------------------
 
 A switch creates a global boolean variable, which is controlled by the option. This variable can be used to modify the
 code behaviors. If the option is disabled in release builds, the variable is replaced by a constant with value 0,
 allowing the optimizer to remove any code which is controlled by the switch.
 
 A switch for use in a single compilation unit is created with
 
    DEBUG_OPTION_SWITCH (aName, targetGroup, aTitle, aToolTip, aDefaultValue, isPersistent)
 
 This creates a static BOOL variable named 'aName'.

 'aDefaultValue' is the default state for the switch. For better readability one of DEBUG_OPTION_DEFAULT_ON or
 DEBUG_OPTION_DEFAULT_OFF should be passed.
 
 If 'isPersistent' is true, the state of the switch can be made persistent by pressing the option key while selecting
 the menu item. Use DEBUG_OPTION_PERSISTENT or DEBUG_OPTION_NON_PERSISTENT for readability.
 The value is saved under the key "DebugOption_<aName>" in user defaults.
 
 To use a switch in multiple compilation units, place 
 
    DEBUG_OPTION_DECLARE_SWITCH (aName, aDefaultValue)
 
 in a header file and 
 
    DEBUG_OPTION_DEFINE_SWITCH (aName, targetGroup, aTitle, aToolTip, isPersistent)
 
 in an implementation file.
 
 This creates the variable 'aName' as "extern" with default visibility.
 
 
 Debug option enumerations ---------------------------------------------------------------------------------------------
 
 An enumeration option is like a switch, but allows a list of integer values instead of just YES and NO.
 
 The differences to a debug option switch are:
 
 'aType' is the type of the variable which holds the option state. It must be compatible with being casted to
 NSInteger. Typical are NSInteger or an enumeration type.
 
 'aFlag' controls whether the menu items for the enumeration are created inline inside the menu of 'targetGroup'
 (pass DEBUG_OPTION_ENUM_INLINE) or as a separate sub menu (pass DEBUG_OPTION_ENUM_AS_SUBMENU).
 
 The variable parameters are a list of alternating title and value pairs, ended with nil. The titles must be of type
 NSString*, the values of NSInteger (or compatible).

    DEBUG_OPTION_ENUM (aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...)
    DEBUG_OPTION_DECLARE_ENUM (aName)
    DEBUG_OPTION_DEFINE_ENUM (aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...)

 
 Debug option actions --------------------------------------------------------------------------------------------------
 
 An action executes a block when the option is selected.

    DEBUG_OPTION_ACTIONBLOCK (aName, targetGroup, aTitle, aToolTip, block)

 
 Named observables -----------------------------------------------------------------------------------------------------

 Named observables are used to connect debug options in the model layer to objects known to the controller layer,
 e.g objects in the key window.

    DEBUG_NAMED_OBSERVABLE_REGISTRATION (aName, anObservable, aKeyPath)


 Debug action bound to a named observable ------------------------------------------------------------------------------

 Define a debug action which is bound to a target using a named observable. PWAppKit uses Cocoa bindings to bind the
 target to a menu item, but other mechanisms are possible, too.

    DEBUG_ACTION_WITH_NAMED_TARGET_BINDING (aName, targetGroup, aTitle, aToolTip,
                                            anObservableName, aKeyPath, aSelectorName)
 
 */

#import <Foundation/Foundation.h>
#import <DebugOptionsFoundation/PWDebugOptions.h>
#import <DebugOptionsFoundation/PWDebugOptionGroup.h>


#define DEBUG_OPTION_DEFAULT_ON YES
#define DEBUG_OPTION_DEFAULT_OFF NO

#define DEBUG_OPTION_PERSISTENT YES
#define DEBUG_OPTION_NON_PERSISTENT NO

#define DEBUG_OPTION_ENUM_AS_SUBMENU YES
#define DEBUG_OPTION_ENUM_INLINE NO


#define DEBUG_OPTION_DECLARE_GROUP(aName) \
@interface aName : PWDebugOptionGroup @end

#define DEBUG_OPTION_DEFINE_GROUP(aName, targetGroup, aTitle, aToolTip) \
@implementation aName @end \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
     [[PWDebugOptionSubGroup alloc] initWithTitle:aTitle toolTip:aToolTip \
                                         subGroup:aName.class userDefaultsSuiteName:nil] \
        withPropertyName:@#aName]; \
} \
@end

#define DEBUG_OPTION_DEFINE_GROUP_WITHDEFAULTSSUITE(aName, targetGroup, aTitle, aToolTip, suiteName) \
@implementation aName @end \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
     [[PWDebugOptionSubGroup alloc] initWithTitle:aTitle toolTip:aToolTip \
                                         subGroup:aName.class userDefaultsSuiteName:suiteName] \
        withPropertyName:@#aName]; \
} \
@end

/**
 Define a debug menu item which toggles the BOOL static variable 'aName'.
 The global variable is declared by the macro, too. This makes it easy to change the variable to constant NO in
 release builds, thus telling the compiler to remove all code conditionalized by this switch.
 */

// Note: the enum declaration in _DECLARE and its use in _DEFINE detects missing _DECLAREs in debug builds, which else
// would make a build without debug options fail.

#define DEBUG_OPTION_DECLARE_SWITCH(aName, aDefaultValue) __attribute__((visibility("default"))) \
extern _Atomic (BOOL) aName; \
enum { aName ## _Default_Value = aDefaultValue };

#define DEBUG_OPTION_DEFINE_SWITCH(aName, targetGroup, aTitle, aToolTip, isPersistent) \
_Atomic (BOOL) aName = aName ## _Default_Value; \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
     [[PWDebugSwitchOption alloc] initWithTitle:aTitle toolTip:aToolTip \
                                  booleanTarget:&aName defaultValue:aName ## _Default_Value \
                              defaultsKeySuffix:isPersistent ? @#aName : nil] \
        withPropertyName:@#aName]; \
} \
@end

#define DEBUG_OPTION_SWITCH(aName, targetGroup, aTitle, aToolTip, aDefaultValue, isPersistent) \
static _Atomic (BOOL) aName; \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
     [[PWDebugSwitchOption alloc] initWithTitle:aTitle toolTip:aToolTip \
                                    booleanTarget:&aName defaultValue:aDefaultValue \
                                defaultsKeySuffix:isPersistent ? @#aName : nil] \
        withPropertyName:@#aName]; \
} \
@end


#define DEBUG_OPTION_DECLARE_ENUM(aName, aType) __attribute__((visibility("default"))) extern _Atomic (aType) aName;

#define DEBUG_OPTION_DEFINE_ENUM(aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...) \
_Atomic (aType) aName; \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
    [[PWDebugEnumOption alloc] initWithTitle:aTitle toolTip:aToolTip asSubMenu:aFlag \
                                           target:(_Atomic (NSInteger)*)&aName defaultValue:aDefaultValue \
                                defaultsKeySuffix:isPersistent ? @#aName : nil \
                                  titlesAndValues:__VA_ARGS__] \
        withPropertyName:@#aName]; \
} \
@end

#define DEBUG_OPTION_ENUM(aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...) \
static _Atomic (aType) aName; \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
    [[PWDebugEnumOption alloc] initWithTitle:aTitle toolTip:aToolTip asSubMenu:aFlag \
                                           target:(_Atomic (NSInteger)*)&aName defaultValue:aDefaultValue \
                                defaultsKeySuffix:isPersistent ? @#aName : nil \
                                  titlesAndValues:__VA_ARGS__] \
        withPropertyName:@#aName]; \
} \
@end


#define DEBUG_OPTION_DECLARE_TEXT(aName) __attribute__((visibility("default"))) \
extern NSString* aName; \
enum { aName ## _DECLARE_Missing = 0 };

#define DEBUG_OPTION_DEFINE_TEXT(aName, targetGroup, aTitle, aToolTip, isPersistent) \
enum { aName ## Dummy = aName ## _DECLARE_Missing }; \
NSString* aName; \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
     [[PWDebugTextOption alloc] initWithTitle:aTitle toolTip:aToolTip \
                                 stringTarget:&aName \
                            defaultsKeySuffix:isPersistent ? @#aName : nil]]; \
} \
@end

#define DEBUG_OPTION_TEXT(aName, targetGroup, aTitle, aToolTip, isPersistent) \
static NSString* aName; \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
     [[PWDebugTextOption alloc] initWithTitle:aTitle toolTip:aToolTip \
                                 stringTarget:&aName \
                            defaultsKeySuffix:isPersistent ? @#aName : nil]]; \
} \
@end


#define DEBUG_OPTION_ACTIONBLOCK(aName, targetGroup, aTitle, aToolTip, block) \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
     [[PWDebugActionBlockOption alloc] initWithTitle:aTitle toolTip:aToolTip actionBlock:block]]; \
} \
@end


#define DEBUG_NAMED_OBSERVABLE_REGISTRATION(aName, anObservable, aKeyPath) \
@implementation PWDebugNamedObservables (aName) \
+ (id) observableFor##aName { return anObservable; } \
+ (NSString*) keyPathFor##aName { return aKeyPath; } \
@end


#define DEBUG_ACTION_WITH_NAMED_TARGET_BINDING(aName, targetGroup, aTitle, aToolTip, anObservableName, aKeyPath, aSelectorName) \
@implementation targetGroup (aName) \
- (void) createOption##aName { \
    [self addOption: \
        [[PWDebugActionWithNamedTargetOption alloc] initWithTitle:aTitle toolTip:aToolTip \
                                                   observableName:anObservableName keyPath:aKeyPath \
                                                     selectorName:aSelectorName options:nil]]; \
} \
@end

// Debug-only variants of the macros

#ifndef NDEBUG

#define DEBUG_OPTION_DECLARE_GROUP_D(aName) \
        DEBUG_OPTION_DECLARE_GROUP  (aName)

#define DEBUG_OPTION_DEFINE_GROUP_D(aName, targetGroup, aTitle, aToolTip) \
        DEBUG_OPTION_DEFINE_GROUP  (aName, targetGroup, aTitle, aToolTip)

#define DEBUG_OPTION_DEFINE_GROUP_WITHDEFAULTSSUITE_D(aName, targetGroup, aTitle, aToolTip, suiteName) \
        DEBUG_OPTION_DEFINE_GROUP_WITHDEFAULTSSUITE  (aName, targetGroup, aTitle, aToolTip, suiteName)

#define DEBUG_OPTION_DECLARE_SWITCH_D(aName, defaultValue) \
        DEBUG_OPTION_DECLARE_SWITCH  (aName, defaultValue)

#define DEBUG_OPTION_DEFINE_SWITCH_D(aName, targetGroup, aTitle, aToolTip, isPersistent) \
        DEBUG_OPTION_DEFINE_SWITCH  (aName, targetGroup, aTitle, aToolTip, isPersistent)

#define DEBUG_OPTION_SWITCH_D(aName, targetGroup, aTitle, aToolTip, aDefaultValue, isPersistent) \
        DEBUG_OPTION_SWITCH  (aName, targetGroup, aTitle, aToolTip, aDefaultValue, isPersistent)

#define DEBUG_OPTION_DECLARE_ENUM_D(aName, aType, releaseValue) \
        DEBUG_OPTION_DECLARE_ENUM  (aName, aType)

#define DEBUG_OPTION_DEFINE_ENUM_D(aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...) \
        DEBUG_OPTION_DEFINE_ENUM  (aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, __VA_ARGS__)

#define DEBUG_OPTION_ENUM_D(aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...) \
        DEBUG_OPTION_ENUM  (aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, __VA_ARGS__)

#define DEBUG_OPTION_DECLARE_TEXT_D(aName) \
        DEBUG_OPTION_DECLARE_TEXT  (aName)

#define DEBUG_OPTION_DEFINE_TEXT_D(aName, targetGroup, aTitle, aToolTip, isPersistent) \
        DEBUG_OPTION_DEFINE_TEXT  (aName, targetGroup, aTitle, aToolTip, isPersistent)

#define DEBUG_OPTION_TEXT_D(aName, targetGroup, aTitle, aToolTip, isPersistent) \
        DEBUG_OPTION_TEXT  (aName, targetGroup, aTitle, aToolTip, isPersistent)

#define DEBUG_OPTION_ACTIONBLOCK_D(aName, targetGroup, aTitle, aToolTip, block) \
        DEBUG_OPTION_ACTIONBLOCK  (aName, targetGroup, aTitle, aToolTip, block)

#define DEBUG_NAMED_OBSERVABLE_REGISTRATION_D(aName, anObservable, aKeyPath) \
        DEBUG_NAMED_OBSERVABLE_REGISTRATION  (aName, anObservable, aKeyPath)

#define DEBUG_ACTION_WITH_NAMED_TARGET_BINDING_D(aName, targetGroup, aTitle, aToolTip, anObservableName, aKeyPath, aSelectorName) \
        DEBUG_ACTION_WITH_NAMED_TARGET_BINDING  (aName, targetGroup, aTitle, aToolTip, anObservableName, aKeyPath, aSelectorName)

#else  /* NDEBUG */

#define DEBUG_OPTION_DECLARE_GROUP_D(aName)
#define DEBUG_OPTION_DEFINE_GROUP_D(aName, targetGroup, aTitle, aToolTip)
#define DEBUG_OPTION_DEFINE_GROUP_WITHDEFAULTSSUITE_D(aName, targetGroup, aTitle, aToolTip, suiteName)

#define DEBUG_OPTION_DECLARE_SWITCH_D(aName, defaultValue) enum { aName = defaultValue };
#define DEBUG_OPTION_DEFINE_SWITCH_D(aName, targetGroup, aTitle, aToolTip, isPersistent)
#define DEBUG_OPTION_SWITCH_D(aName, targetGroup, aTitle, aToolTip, aDefaultValue, isPersistent) enum { aName = aDefaultValue };

#define DEBUG_OPTION_DECLARE_ENUM_D(aName, aType, releaseValue) enum:NSInteger { aName = releaseValue };
#define DEBUG_OPTION_DEFINE_ENUM_D(aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...)
#define DEBUG_OPTION_ENUM_D(aName, targetGroup, aTitle, aToolTip, aFlag, aType, aDefaultValue, isPersistent, ...) enum:aType { aName = aDefaultValue };

#define DEBUG_OPTION_DECLARE_TEXT_D(aName) enum { aName = 0 };
#define DEBUG_OPTION_DEFINE_TEXT_D(aName, targetGroup, aTitle, aToolTip, isPersistent)
#define DEBUG_OPTION_TEXT_D(aName, targetGroup, aTitle, aToolTip, isPersistent) enum { aName = 0 };

#define DEBUG_OPTION_ACTIONBLOCK_D(aName, targetGroup, aTitle, aToolTip, block)

#define DEBUG_NAMED_OBSERVABLE_REGISTRATION_D(aName, anObservable, aKeyPath)

#define DEBUG_ACTION_WITH_NAMED_TARGET_BINDING_D(aName, targetGroup, aTitle, aToolTip, anObservableName, aKeyPath, aSelectorName)

#endif /* NDEBUG */
