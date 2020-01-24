//
//  PWDebugOptionsTest.m
//  DebugOptionsFoundation
//
//  Created by Kai Brüning on 26.1.10.
//  Copyright 2010 ProjectWizards. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import <XCTest/XCTest.h>
#import "PWDebugOptionMacros.h"

@interface PWDebugOptionsTest : XCTestCase
@end

DEBUG_OPTION_SWITCH (PWDebugOptionTestSwitch1, PWRootDebugOptionGroup,
                     @"Switch 1", @"A switch for testing",
                     DEBUG_OPTION_DEFAULT_OFF, DEBUG_OPTION_PERSISTENT)

static int sAction1Count = 0;
DEBUG_OPTION_ACTIONBLOCK (PWDebugOptionTestActionBlock, PWRootDebugOptionGroup, @"Action 1",
                          @"A block-based action for testing",
                          ^{ ++sAction1Count; })

DEBUG_OPTION_DECLARE_GROUP (TestDebugSubGroup)
DEBUG_OPTION_DEFINE_GROUP (TestDebugSubGroup, PWRootDebugOptionGroup,
                           @"Sub group 1", @"A sub group for testing")

DEBUG_OPTION_DECLARE_SWITCH (PWDebugOptionTestSwitch2, DEBUG_OPTION_DEFAULT_OFF)

DEBUG_OPTION_DEFINE_SWITCH (PWDebugOptionTestSwitch2, TestDebugSubGroup,
                            @"Switch 2", @"A test switch in a sub group",
                            DEBUG_OPTION_PERSISTENT)


typedef NS_ENUM(NSInteger, PWTestEnum) {
    PWTestValue1,
    PWTestValue2 = 10,
    PWTestValue3
};

DEBUG_OPTION_ENUM (PWDebugOptionTestEnum, PWRootDebugOptionGroup,
                   @"Test Enum", @"An enumeration option for testing", DEBUG_OPTION_ENUM_AS_SUBMENU,
                   PWTestEnum, PWTestValue2, DEBUG_OPTION_PERSISTENT,
                   @"Value 1", PWTestValue1,
                   @"Value 2", PWTestValue2,
                   @"Value 3", PWTestValue3,
                   nil)



DEBUG_OPTION_TEXT (PWDebugOptionTestText1, PWRootDebugOptionGroup,
                   @"Text 1", @"A text for testing",
                   DEBUG_OPTION_PERSISTENT)


DEBUG_OPTION_DECLARE_TEXT (PWDebugOptionTestText2)

DEBUG_OPTION_DEFINE_TEXT (PWDebugOptionTestText2, PWRootDebugOptionGroup,
                          @"Text 2", @"Another text for testing",
                          DEBUG_OPTION_PERSISTENT)



@implementation PWDebugOptionsTest
{
    NSString*                               _lastObservedKeyPath;
    id                                      _lastObservedObject;
    NSDictionary<NSKeyValueChangeKey, id>*  _lastObservedChange;
    void*                                   _lastObservedContext;
}

- (void) testBasicDebugOptions
{
    PWRootDebugOptionGroup* rootGroup = PWRootDebugOptionGroup.sharedRootGroup;

    // Removed the following check because it is too volatile when new options are added to DebugOptionsFoundation.
    //STAssertEquals (rootGroup.options.count, 7, nil);   // includes PWLogCalculationOfDerivedPropertyWithKey
                                                          
    PWDebugOptionSubGroup* subGroup = [rootGroup optionWithTitle:@"Sub group 1"];
    XCTAssertEqual (subGroup.subGroup.options.count, 1);
    
    PWDebugEnumOption* enumOption = [rootGroup optionWithTitle:@"Test Enum"];
    XCTAssertTrue (enumOption.asSubMenu);
    XCTAssertEqual (enumOption.values.count, 3);
    XCTAssertEqualObjects ((enumOption.titles)[1], @"Value 2");

    XCTAssertEqualObjects (PWDebugOptionTestText1, nil);
    PWDebugTextOption* textOption = [rootGroup optionWithTitle:@"Text 1"];
    textOption.currentValue = @"Test Text";
    XCTAssertEqualObjects (PWDebugOptionTestText1, @"Test Text");
}

- (void) testActionBlockOption
{
    PWRootDebugOptionGroup* rootGroup = PWRootDebugOptionGroup.sharedRootGroup;
    
    PWDebugActionBlockOption* actionOption = [rootGroup optionWithTitle:@"Action 1"];
    XCTAssertNotNil (actionOption);
    sAction1Count = 0;
    [actionOption execute:nil];
    XCTAssertEqual (sAction1Count, 1);
}

- (void) testDebugOptionKVObservation
{
    PWRootDebugOptionGroup* rootGroup = PWRootDebugOptionGroup.sharedRootGroup;

    [TestDebugSubGroup addObserver:self
                        forKeyPath:@"PWDebugOptionTestSwitch2"
                           options:0
                           context:NULL];
    _lastObservedObject = nil;
    
    PWDebugOptionSubGroup* subGroup = [rootGroup optionWithTitle:@"Sub group 1"];
    XCTAssertNotNil (subGroup);

    PWDebugSwitchOption* switchOption = [subGroup.subGroup optionWithTitle:@"Switch 2"];
    XCTAssertNotNil (switchOption);

    XCTAssertFalse (switchOption.currentValue);
    XCTAssertNil (_lastObservedObject);
    
    switchOption.currentValue = YES;
    XCTAssertEqual (_lastObservedObject, TestDebugSubGroup.class);
    XCTAssertEqualObjects (_lastObservedKeyPath, @"PWDebugOptionTestSwitch2");

    [TestDebugSubGroup removeObserver:self
                           forKeyPath:@"PWDebugOptionTestSwitch2"
                              context:NULL];
}

- (void) observeValueForKeyPath:(nullable NSString*)keyPath
                       ofObject:(nullable id)object
                         change:(nullable NSDictionary<NSKeyValueChangeKey, id>*)change
                        context:(nullable void*)context
{
    _lastObservedKeyPath = [keyPath copy];
    _lastObservedObject  = object;
    _lastObservedChange  = [change copy];
    _lastObservedContext = context;
}

@end

