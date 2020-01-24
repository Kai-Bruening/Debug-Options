//
//  DebugOptionGroup.swift
//  DebugOptionsFoundation_swift
//
//  Created by Kai Bruening on 24.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

/*
 
 A very rough sketch of a possible implementation of Debug Options in Swift.
 
 */

import Foundation

public class DebugOptionGroup {
    
    /// Should be used directly for the root group only.
    init(userDefaults: UserDefaults? = nil) {
        self.options = []
        if userDefaults != nil {
            self.userDefaults = userDefaults!
        }
        else {
            self.userDefaults = UserDefaults.standard
        }
    }
    
    /// This initializer creates the group instance, wraps it in a DebugOptionSubGroup and adds the latter to 'superGroup'.
    /// Typically used to create a static or global variable holding the group:
    ///     let groupName = DebugOptionGroup("groupName", superGroup, …)
    convenience init(_ name: String, _ superGroup: DebugOptionGroup, title: String, toolTip: String? = nil) {
        self.init(userDefaults: superGroup.userDefaults)
        _ = DebugOptionSubGroup (name, superGroup, subGroup: self, title: title, toolTip: toolTip)
    }

    private(set) var options: [DebugOption]
    let userDefaults: UserDefaults

    func addOption (_ option: DebugOption) {
        self.options.append(option)
    }
}

/// The root of the tree of debug option groups and debug options.
public var RootDebugOptionGroup = DebugOptionGroup()
