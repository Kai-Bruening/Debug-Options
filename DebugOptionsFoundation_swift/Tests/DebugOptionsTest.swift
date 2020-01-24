//
//  DebugOptionsTest.swift
//  DebugOptionsFoundation_swiftTests
//
//  Created by Kai Bruening on 24.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

import XCTest
@testable import DebugOptionsFoundation_swift

static let testSwitch1 = DebugSwitchOption("testSwitch1", RootDebugOptionGroup,
                                           defaultValue: false,
                                           title: "Switch 1", toolTip: "A switch for testing")

static let testSubGroup = DebugOptionGroup("testSubGroup", RootDebugOptionGroup,
                                           title: "Sub group 1", toolTip: "A sub group for testing")

static let testSwitch2 = DebugSwitchOption("testSwitch2", testSubGroup,
                                           defaultValue: false,
                                           title: "Switch 2", toolTip: "A test switch in a sub group")

class DebugOptionsFoundation_swiftTests: XCTestCase {
    
    func test1() {
        XCTAssertFalse(testSwitch1.value)
        XCTAssertEqual(RootDebugOptionGroup.options.count, 1)
        
        // Check option loading from user defaults.
        let savedValue = UserDefaults.standard.object(forKey:"DebugOption_testSwitch2")
        UserDefaults.standard.set(true, forKey:"DebugOption_testSwitch2")
        // First access of the switch loads the value from uer defaults.
        XCTAssertTrue(testSwitch2.value)
        
        // Restore user defaults
        UserDefaults.standard.set(savedValue, forKey:"DebugOption_testSwitch2")

        // The root group got the sub group as new element.
        XCTAssertEqual(RootDebugOptionGroup.options.count, 2)
        XCTAssertEqual(testSubGroup.options.count, 1)
    }
}
