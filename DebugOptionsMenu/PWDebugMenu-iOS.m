//
//  PWDebugMenu_iOS.m
//  PWAppKit
//
//  Created by Berbie on 15.08.16.
//  Copyright © 2016 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "PWDebugMenu-iOS.h"
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

NSString* const PWDebugMenuSaveStateKey = @"DebugMenuSaveState";

@class PWDebugMenuController;
@class PWDebugMenuTableViewController;

@interface PWDebugOption (PWDebugMenuController)

@property (nonatomic, readonly) BOOL                            isEnabled;

@property (nonatomic, readonly) BOOL                            isDetailing;
- (nullable PWDebugMenuTableViewController*)createDetailingTableViewControllerWithMenuController:(PWDebugMenuController*)menuController;

@property (nonatomic, readonly) BOOL                            isAction;
- (void)performAction:(id)sender;

@property (nonatomic, readonly) BOOL                            isControl;
- (UIControl*)controlView;

@end

@interface PWDebugMenuTableViewController : UITableViewController

@property (nonatomic, readonly, copy)           NSString*               optionTitle;
@property (nonatomic, readonly, copy, nullable) NSString*               optionDescription;
@property (nonatomic, readonly, weak, nullable) PWDebugMenuController*  menuController;

@end

@interface PWDebugMenuOptionsViewController : PWDebugMenuTableViewController

- (instancetype)initWithOptionGroup:(PWDebugOptionGroup*)optionGroup
                              title:(NSString*)title
                  detailDescription:(nullable NSString*)detailDescription
                     menuController:(PWDebugMenuController*)menuController;

@end

@interface PWDebugMenuEnumOptionsViewController : PWDebugMenuTableViewController

- (instancetype)initWithEnumOption:(PWDebugEnumOption*)enumOption
                             title:(NSString*)title
                 detailDescription:(nullable NSString*)detailDescription
                    menuController:(PWDebugMenuController*)menuController;

@end


#pragma mark -

@implementation PWDebugMenuController
{
    PWRootDebugOptionGroup*     _rootDebugOptionGroup;
    void (^_completionHandler) (void);
    UIWindow*                   _debugMenuWindow;
    UINavigationController*     _navigationController;
}

- (instancetype) initWithRootDebugOptionGroup:(PWRootDebugOptionGroup*)rootDebugOptionGroup
{
    NSParameterAssert (rootDebugOptionGroup);
    self = [super init];
    _rootDebugOptionGroup = rootDebugOptionGroup;
    return self;
}

#pragma mark interface

- (void) presentDebugMenuCompletionHandler:(void (^_Nullable) (void))completionHandler
{
    NSAssert (!_debugMenuWindow, @"this controller isn’t nestable");

    // Wrap passed in completion handler to ensure this object isn’t released before the debug menu is dismissed.
    _completionHandler = ^{
        if (completionHandler)
            completionHandler();

        // Break retain cycle and allow dealloc.
        self->_completionHandler = nil;
    };

    _debugMenuWindow = [[UIWindow.class alloc] initWithFrame:UIScreen.mainScreen.bounds];
    // Use alert level to make sure the debug menu sheet is at the top. But not above a possible keyboard.
    _debugMenuWindow.windowLevel = UIWindowLevelAlert;
    _debugMenuWindow.rootViewController = [[UIViewController alloc] init];

    [_debugMenuWindow makeKeyAndVisible];

    PWDebugMenuOptionsViewController* viewController
    = [[PWDebugMenuOptionsViewController alloc] initWithOptionGroup:_rootDebugOptionGroup
                                                              title:@"Debug"
                                                  detailDescription:nil
                                                     menuController:self];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    _navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [_debugMenuWindow.rootViewController presentViewController:_navigationController animated:YES completion:nil];
}

- (void)dismissDebugMenu
{
    [_debugMenuWindow.rootViewController dismissViewControllerAnimated:YES completion:^{
        self->_debugMenuWindow.hidden = YES;
        self->_debugMenuWindow = nil; // break retain cycle

        // Note: always the wrapper which is created in -presentDebugMenuFromResponder:…
        self->_completionHandler();
    }];
}

#pragma mark interface (state)

+ (BOOL)isSavingOptionStates
{
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    return [defaults boolForKey:PWDebugMenuSaveStateKey];
}

+ (void)toggleSavingOptionStates
{
    NSUserDefaults* defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:![defaults boolForKey:PWDebugMenuSaveStateKey] forKey:PWDebugMenuSaveStateKey];
}

@end

#pragma mark -

@implementation PWDebugMenuTableViewController

- (instancetype)initWithTitle:(NSString*)title
            detailDescription:(nullable NSString*)detailDescription
               menuController:(PWDebugMenuController*)menuController
{
    NSParameterAssert(menuController);
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        _optionTitle = title;
        _optionDescription = detailDescription;
        _menuController = menuController;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismiss:)];
    self.navigationItem.title = self.optionTitle;
}

#pragma mark actions

- (IBAction)dismiss:(id)sender
{
    [_menuController dismissDebugMenu];
}

- (IBAction)toggleSaveState:(id)sender
{
    [PWDebugMenuController toggleSavingOptionStates];
}

@end

#pragma mark -

@implementation PWDebugMenuOptionsViewController
{
    PWDebugOptionGroup*     _optionGroup;
}

- (instancetype)initWithOptionGroup:(PWDebugOptionGroup*)optionGroup
                              title:(NSString*)title
                  detailDescription:(nullable NSString*)detailDescription
                     menuController:(PWDebugMenuController*)menuController
{
    NSParameterAssert(optionGroup);
    
    self = [super initWithTitle:title detailDescription:detailDescription menuController:menuController];
    if (self)
    {
        _optionGroup = optionGroup;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Sort options by menu item title.
    // Note: may want to add another order criterium to debug options.
    [_optionGroup sortOptionsUsingComparator:^NSComparisonResult (PWDebugOption* option1, PWDebugOption* option2) {
        NSComparisonResult result;
        if (option1.isDetailing == option2.isDetailing)
            result = [option1.title compare:option2.title];
        else
            result = (option1.isDetailing < option2.isDetailing) ? NSOrderedAscending : NSOrderedDescending;
        return result;
    }];
}

#pragma mark protocol (UITableViewDataSource)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return _optionGroup.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.optionDescription;
}

#pragma mark protocol (UITableViewDelegate)

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    PWDebugOption* option = _optionGroup.options[indexPath.row];
    return option.isEnabled && !option.isControl;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PWDebugOption* option = _optionGroup.options[indexPath.row];
    
    if (option.isDetailing)
    {
        PWDebugMenuTableViewController* detailingViewController;
        detailingViewController = [option createDetailingTableViewControllerWithMenuController:self.menuController];
        NSAssert(detailingViewController, nil);
        [self.navigationController pushViewController:detailingViewController animated:YES];
    }
    else if (option.isAction)
    {
        [option performAction:self];
    }
    else if (option.isControl)
    {
        ;// NOP, has no action on tap
    }
    else
    {
        NSAssert(NO, nil);// not (yet) implemented
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark internal (UITableViewCell)

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0)
    {
        [self configureSafeOptionCell:cell];
    }
    else
    {
        [self configureOptionCell:cell atIndexPath:indexPath];
    }
}

- (void)configureSafeOptionCell:(UITableViewCell*)cell
{
    cell.textLabel.text = @"Save option states";
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    UISwitch* saveStateSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    {
        saveStateSwitch.on = [PWDebugMenuController isSavingOptionStates];
        [saveStateSwitch addTarget:self action:@selector(toggleSaveState:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.accessoryView = saveStateSwitch;
}

- (void)configureOptionCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PWDebugOption* option = _optionGroup.options[indexPath.row];
    NSAssert(option, nil);
    
    UIColor* textColor = option.isEnabled ? nil : [UIColor colorWithWhite:0.5 alpha:1.0]; // a nil default color makes sure that the system apperance text color is used
    UIColor* detailColor = [textColor colorWithAlphaComponent:0.5];
    
    cell.textLabel.text = option.title;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.textColor = textColor;
    cell.detailTextLabel.text = option.toolTip.length > 0 ? option.toolTip : nil;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.textColor = detailColor;
    cell.accessoryType  = option.isDetailing ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.accessoryView = option.isControl ? option.controlView : nil;
}

@end

#pragma mark -

@implementation PWDebugMenuEnumOptionsViewController
{
    PWDebugEnumOption*  _enumOption;
}

- (instancetype)initWithEnumOption:(PWDebugEnumOption*)enumOption
                             title:(NSString*)title
                 detailDescription:(nullable NSString*)detailDescription
                    menuController:(PWDebugMenuController*)menuController
{
    NSParameterAssert(enumOption);
    
    self = [super initWithTitle:title detailDescription:detailDescription menuController:menuController];
    if (self)
    {
        _enumOption = enumOption;
    }
    return self;
}

#pragma mark protocol (UITableViewDataSource)

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _enumOption.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.optionDescription;
}

#pragma mark protocol (UITableViewDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowValue = [_enumOption.values[indexPath.row] integerValue];
    if (rowValue != _enumOption.currentValue)
    {
        _enumOption.currentValue = rowValue;
        if ([PWDebugMenuController isSavingOptionStates])
            [_enumOption saveState];
        [self.tableView reloadData];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark internal (UITableViewCell)

- (void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    cell.textLabel.text = _enumOption.titles[indexPath.row];
    cell.detailTextLabel.text = nil;
    
    NSInteger rowValue = [_enumOption.values[indexPath.row] integerValue];
    cell.accessoryType  = (rowValue == _enumOption.currentValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end

#pragma mark -

@implementation PWDebugOption (PWDebugMenuController)

- (BOOL)isEnabled
{
    return NO;
}

- (BOOL)isDetailing
{
    return NO;
}

- (nullable PWDebugMenuTableViewController*)createDetailingTableViewControllerWithMenuController:(PWDebugMenuController*)menuController
{
    NSAssert(NO, nil); // abstract, subclasses need implementation
    return nil;
}

- (BOOL)isAction
{
    return NO;
}

- (void)performAction:(id)sender
{
    NSAssert(NO, nil); // abstract, subclasses need implementation
}

- (BOOL)isControl
{
    return NO;
}

- (UIControl*)controlView
{
    NSAssert(NO, nil); // abstract, subclasses need implementation
    return nil;
}

@end

@implementation PWDebugOptionSubGroup (PWDebugMenuController)

- (BOOL)isEnabled
{
    return YES;
}

- (BOOL)isDetailing
{
    return YES;
}

- (nullable PWDebugMenuTableViewController*)createDetailingTableViewControllerWithMenuController:(PWDebugMenuController*)menuController
{
    return [[PWDebugMenuOptionsViewController alloc] initWithOptionGroup:self.subGroup
                                                                   title:self.title
                                                       detailDescription:self.toolTip
                                                          menuController:menuController];
}

@end

@implementation PWDebugSwitchOption (PWDebugMenuController)

- (BOOL)isEnabled
{
    return YES;
}

- (BOOL)isControl
{
    return YES;
}

- (UIControl*)controlView
{
    static NSString* switchControlKey = @"_switchControl";
    
    UISwitch* switchControl = objc_getAssociatedObject(self, (__bridge const void*)switchControlKey);
    if (switchControl == nil)
    {
        switchControl = [[UISwitch alloc] initWithFrame:CGRectZero];
        objc_setAssociatedObject (self, (__bridge const void*)switchControlKey, switchControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [switchControl addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventTouchUpInside];
        switchControl.on = (*self.target);
    }
    return switchControl;
}

- (IBAction) toggle:(id)sender
{
    self.currentValue = ! self.currentValue;

    if ([PWDebugMenuController isSavingOptionStates])
        [self saveState];
}

@end

@implementation PWDebugEnumOption (PWDebugMenuController)

- (BOOL)isEnabled
{
    return YES;
}

- (BOOL)isDetailing
{
    return YES;
}

- (nullable PWDebugMenuTableViewController*)createDetailingTableViewControllerWithMenuController:(PWDebugMenuController*)menuController
{
    return [[PWDebugMenuEnumOptionsViewController alloc] initWithEnumOption:self
                                                                      title:self.title
                                                          detailDescription:self.toolTip
                                                             menuController:menuController];
}

@end

@implementation PWDebugTextOption (PWDebugMenuController)

@end

@implementation PWDebugActionBlockOption (PWDebugMenuController)

- (BOOL)isEnabled
{
    return YES;
}

- (BOOL)isAction
{
    return YES;
}

- (void)performAction:(id)sender
{
    [self execute:sender];
}

@end

@implementation PWDebugActionWithNamedTargetOption (PWDebugMenuController)

- (BOOL)isAction
{
    return YES;
}

- (BOOL)isEnabled
{
    return (self.targetObject != nil);
}

- (void)performAction:(id)sender
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.targetObject performSelector:NSSelectorFromString(self.selectorName)];
#pragma clang diagnostic pop
}

- (nullable id)targetObject
{
    NSDictionary* options = self.options;
#pragma unused (options)
    
    // Resolve the named observable
    SEL sel1 = NSSelectorFromString ([@"observableFor" stringByAppendingString:self.observableName]);
    if ([PWDebugNamedObservables respondsToSelector:sel1]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        
        id observable = [PWDebugNamedObservables performSelector:sel1];
        
        SEL sel2 = NSSelectorFromString ([@"keyPathFor" stringByAppendingString:self.observableName]);
        NSString* fullKeyPath = [PWDebugNamedObservables performSelector:sel2];
        
#pragma clang diagnostic pop
        if (self.keyPath)
            fullKeyPath = [fullKeyPath stringByAppendingFormat:@".%@", self.keyPath];
        
        id object = [observable valueForKeyPath:fullKeyPath];
        return object;
    }
    else
    {
        NSLog (@"PWDebugNamedObservables: Unknown observable name \"%@\".", self.observableName);
    }
    
    return nil;
}

@end

NS_ASSUME_NONNULL_END
