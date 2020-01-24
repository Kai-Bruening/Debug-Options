//
//  PWDebugMenu.m
//  PWAppKit
//
//  Created by Kai Brüning on 26.1.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "PWDebugMenu.h"

NS_ASSUME_NONNULL_BEGIN

@interface PWDebugNamedObservables (PWDebugMenu)

+ (void)     bind:(NSBindingName)binding
         ofObject:(id)boundObject
toObservableNamed:(NSString*)observableName
      withKeyPath:(NSString*)keyPath
          options:(nullable NSDictionary<NSBindingOption, id>*)options;

@end

#pragma mark -

@implementation PWDebugOptionGroup (PWDebugMenu)

- (NSMenu*) createMenu
{
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@"Debug"]; // TODO: title for sub menus?
    
    // Sort options by menu item title.
    // Note: may want to add another order criterium to debug options.
    [self sortOptionsUsingComparator:^NSComparisonResult (PWDebugOption* option1, PWDebugOption* option2) {
        NSComparisonResult result;
        if (option1.orderInMenu == option2.orderInMenu)
            result = [option1.menuItemTitle compare:option2.menuItemTitle];
        else
            result = (option1.orderInMenu < option2.orderInMenu) ? NSOrderedAscending : NSOrderedDescending;
        return result;
    }];

    for (PWDebugOption* iOptions in self.options) {
        [iOptions addMenuItemToMenu:menu];
    }

    return menu;
}

@end

#pragma mark -

@implementation PWRootDebugOptionGroup (PWDebugMenu)

- (void) insertDebugMenuInMainMenu:(NSMenu*)mainMenu beforeItemWithTag:(NSInteger)tag
{
    NSParameterAssert (mainMenu);

    NSInteger insertIndex = [mainMenu indexOfItemWithTag:tag];
    
    NSMenuItem* debugMenuItem = nil;
    if (insertIndex >= 0)
        debugMenuItem = [mainMenu insertItemWithTitle:@"Debug" action:NULL keyEquivalent:@"" atIndex:insertIndex];
    else
        debugMenuItem = [mainMenu addItemWithTitle:@"Debug" action:NULL keyEquivalent:@""];
    
    [self createDebugMenuInMenuItem:debugMenuItem];

#ifndef NDEBUG
    // Enable the debug menu if the release version is later run on the same machine.
    PWRootDebugOptionGroup.isDebugMenuEnabled = YES;
#endif
}

- (void) createDebugMenuInMenuItem:(NSMenuItem*)debugMenuItem
{
    NSParameterAssert (debugMenuItem);

    NSMenu* menu = [self createMenu];
    debugMenuItem.submenu = menu;
}

@end

#pragma mark -

@implementation PWDebugOption (PWDebugMenu)

- (NSInteger) orderInMenu
{
    return 0;
}

- (NSString*) menuItemTitle
{
    return self.title;
}

- (void) addMenuItemToMenu:(NSMenu*)menu
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSMenuItem*) createMenuItemWithAction:(nullable SEL)aSelector
{
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:self.menuItemTitle action:aSelector keyEquivalent:@""];
    if (self.toolTip)
        item.toolTip = self.toolTip;
    return item;
}

@end

#pragma mark -

@implementation PWDebugOptionSubGroup (PWDebugMenu)

- (NSInteger) orderInMenu
{
    return -100;    // sort at beginning by default
}

- (void) addMenuItemToMenu:(NSMenu*)menu
{
    NSParameterAssert (menu);
    
    // Create and attach the menu item.
    NSMenuItem* item = [self createMenuItemWithAction:NULL];
    NSMenu* subMenu = [self.subGroup createMenu];
    item.submenu = subMenu;
    [menu addItem:item];
}

@end

#pragma mark -

@implementation PWDebugSwitchOption (PWDebugMenu)

- (void) addMenuItemToMenu:(NSMenu*)menu
{
    NSParameterAssert (menu);

    // Create and attach the menu item.
    NSMenuItem* item = [self createMenuItemWithAction:@selector (toggle:)];
    item.target = self;
    item.state  = *self.target ? NSControlStateValueOn : NSControlStateValueOff;
    [menu addItem:item];
    
    // Create alternative item for saving the state in defaults.
    if (self.defaultsKey) {
        item = [[NSMenuItem alloc] initWithTitle:[self.menuItemTitle stringByAppendingString:@" (save state)"]
                                          action:@selector (toggleAndSaveState:) keyEquivalent:@""];
        if (self.toolTip)
            item.toolTip = self.toolTip;
        item.keyEquivalentModifierMask = NSEventModifierFlagOption;
        item.target = self;
        item.state  = *self.target ? NSControlStateValueOn : NSControlStateValueOff;
        [item setAlternate:YES];
        [menu addItem:item];
    }
}

- (BOOL) validateMenuItem:(NSMenuItem*)menuItem
{
    menuItem.state = *self.target ? NSControlStateValueOn : NSControlStateValueOff;
    return YES;
}

- (void) toggle:(id)sender
{
    self.currentValue = ! self.currentValue;
}

- (void) toggleAndSaveState:(id)sender
{
    [self toggle:sender];
    [self saveState];
}

@end

#pragma mark -

@implementation PWDebugEnumOption (PWDebugMenu)

- (void) addMenuItemToMenu:(NSMenu*)menu
{
    NSParameterAssert (menu);
    
    NSString* toolTip = self.toolTip;
    
    if (self.asSubMenu) {
        NSMenu* subMenu = [[NSMenu alloc] initWithTitle:self.menuItemTitle];
        NSMenuItem* item = [self createMenuItemWithAction:NULL];
        item.submenu = subMenu;
        [menu addItem:item];
        menu = subMenu;
        toolTip = nil;
    }
    
    NSUInteger count = self.values.count;
    for (NSUInteger i = 0; i < count; ++i) {
        NSString* iTitle = (self.titles)[i];
        NSInteger iValue = [(self.values)[i] integerValue];
        NSMenuItem* iItem = [[NSMenuItem alloc] initWithTitle:iTitle
                                                       action:@selector (select:) keyEquivalent:@""];
        iItem.tag = iValue;
        iItem.target = self;
        if (toolTip)
            iItem.toolTip = toolTip;

        iItem.state  = (*self.target == iValue) ? NSControlStateValueOn : NSControlStateValueOff;
        [menu addItem:iItem];

        // Create alternative item for saving the state in defaults.
        if (self.defaultsKey) {
            iItem = [[NSMenuItem alloc] initWithTitle:[iTitle stringByAppendingString:@" (save state)"]
                                               action:@selector (selectAndSaveState:) keyEquivalent:@""];
            iItem.tag = iValue;
            iItem.target = self;
            if (toolTip)
                iItem.toolTip = toolTip;
            iItem.state  = (*self.target == iValue) ? NSControlStateValueOn : NSControlStateValueOff;

            iItem.keyEquivalentModifierMask = NSEventModifierFlagOption;
            [iItem setAlternate:YES];

            [menu addItem:iItem];
        }
    }
}

- (BOOL) validateMenuItem:(NSMenuItem*)menuItem
{
    menuItem.state = (*self.target == menuItem.tag) ? NSControlStateValueOn : NSControlStateValueOff;
    return YES;
}

- (void) select:(id)sender
{
    NSAssert (sender, @"needs a sender for the tag");
    self.currentValue = [sender tag];
}

- (void) selectAndSaveState:(id)sender
{
    [self select:sender];
    [self saveState];
}

@end

#pragma mark -

@implementation PWDebugTextOption (PWDebugMenu)

- (void) addMenuItemToMenu:(NSMenu*)menu
{
    NSParameterAssert (menu);
    
    // Create and attach the menu item.
    NSMenuItem* item = [self createMenuItemWithAction:@selector (requestText:)];
    item.target = self;
    [menu addItem:item];
    
    // Create alternative item for saving the state in defaults.
    if (self.defaultsKey) {
        item = [[NSMenuItem alloc] initWithTitle:[self.menuItemTitle stringByAppendingString:@" (save state)"]
                                          action:@selector (requestTextAndSaveState:) keyEquivalent:@""];
        if (self.toolTip)
            item.toolTip = self.toolTip;
        item.keyEquivalentModifierMask = NSEventModifierFlagOption;
        item.target = self;
        [item setAlternate:YES];
        [menu addItem:item];
    }
}

- (void) requestText:(id)sender
{
    NSAlert* alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    alert.messageText = self.title;
    alert.alertStyle = NSAlertStyleInformational;
    
    NSTextField* textField = [[NSTextField alloc] initWithFrame:NSMakeRect (0, 0, 200, 20)];
    alert.accessoryView = textField;
    if (self.currentValue)
        textField.stringValue = self.currentValue;

    NSInteger result = [alert runModal];
    
    if (result == NSAlertFirstButtonReturn ) {
        // "OK" clicked
        NSString* newValue = textField.stringValue;
        if (newValue.length == 0)
            newValue = nil;
        self.currentValue = newValue;
    }
}

- (void) requestTextAndSaveState:(id)sender
{
    [self requestText:sender];
    [self saveState];
}

@end

#pragma mark -

@implementation PWDebugActionBlockOption (PWDebugMenu)

- (void) addMenuItemToMenu:(NSMenu*)menu
{
    NSParameterAssert (menu);
    
    // Create and attach the menu item.
    NSMenuItem* item = [self createMenuItemWithAction:@selector(execute:)];
    item.target = self;
    [menu addItem:item];
}

@end

#pragma mark -

@implementation PWDebugActionWithNamedTargetOption (PWDebugMenu)

- (void) addMenuItemToMenu:(NSMenu*)menu
{
    NSParameterAssert (menu);
    
    // Create and attach the menu item.
    NSMenuItem* item = [self createMenuItemWithAction:NULL];

    // Add the selector name to the options dictionary.
    NSDictionary* bindingOptions = nil;
    if (self.options) {
        NSMutableDictionary* mutableOptions = [self.options mutableCopy];
        mutableOptions[NSSelectorNameBindingOption] = self.selectorName;
        bindingOptions = mutableOptions;
    } else {
        bindingOptions = @{NSSelectorNameBindingOption: self.selectorName};
    }
    [PWDebugNamedObservables bind:@"target" ofObject:item toObservableNamed:self.observableName
                      withKeyPath:self.keyPath options:bindingOptions];
    [menu addItem:item];
}

@end

#pragma mark -

@implementation PWDebugNamedObservables (PWDebugMenu)

+ (void)     bind:(NSBindingName)binding
         ofObject:(id)boundObject
toObservableNamed:(NSString*)observableName
      withKeyPath:(NSString*)keyPath
          options:(nullable NSDictionary<NSBindingOption, id>*)options
{
    // Resolve the named observable
    SEL sel1 = NSSelectorFromString ([@"observableFor" stringByAppendingString:observableName]);
    if ([self respondsToSelector:sel1]) {

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id observable = [self performSelector:sel1];

        SEL sel2 = NSSelectorFromString ([@"keyPathFor" stringByAppendingString:observableName]);
        NSString* fullKeyPath = [self performSelector:sel2];
    #pragma clang diagnostic pop

        if (keyPath)
            fullKeyPath = [fullKeyPath stringByAppendingFormat:@".%@", keyPath];
        
        [boundObject bind:binding toObject:observable withKeyPath:fullKeyPath options:options];
    }
    else
        NSLog (@"PWDebugNamedObservables: Unknown observable name \"%@\".", observableName);
}

@end

NS_ASSUME_NONNULL_END
