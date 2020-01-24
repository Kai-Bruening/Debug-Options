//
//  DebugOptions.swift
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

/// Base class for all debug options.
public class DebugOption {
    
    init(name: String, group: DebugOptionGroup, title: String, toolTip: String?) {
        self.name    = name
        self.title   = title
        self.toolTip = toolTip
        group.addOption(self)
    }

    let name: String
    let title: String
    let toolTip: String?
    
    func defaultsKey(forDebugOptionName name:String) -> String
    {
        return "DebugOption_" + name;
    }
}

/// Debug option representing a binary switch.
public class DebugSwitchOption : DebugOption {

    /// The initializer creates the option instance, adds it to its 'group' and initializes it from user defaults.
    /// Typically used to create a static or global variable holding the open:
    ///     let optionName = DebugSwitchOption("optionName", optionGroup, …)
    init(_ name: String, _ group: DebugOptionGroup, defaultValue: Bool, title: String, toolTip: String? = nil) {
        self.value = defaultValue
        self.userDefaults = group.userDefaults
        super.init(name: name, group: group, title: title, toolTip: toolTip)
        self.loadState()
    }

    var value: Bool
    
    var defaultsKey: String {
        get {
            return self.defaultsKey(forDebugOptionName: self.name)
        }
    }
    let userDefaults: UserDefaults
    
    /// Load persisted state from user defaults, if any.
    func loadState()
    {
        let defaultValue = self.userDefaults.object(forKey:self.defaultsKey)
        if defaultValue != nil {
            self.value = (defaultValue as! NSNumber).boolValue;
        }
    }

    /// Save current value in user defaults.
    func saveState() {
        self.userDefaults.set(self.value, forKey:self.defaultsKey)
        self.userDefaults.synchronize(); // make it persistent even if the app is killed soon after
    }
}

/// Debug option containing a sub group. Equivalent to a sub menu item.
class DebugOptionSubGroup : DebugOption {
    
    /// DebugOptionSubGroup should only be created via creating a group. See DebugOptionGroup.
    init(_ name: String, _ superGroup: DebugOptionGroup, subGroup: DebugOptionGroup, title: String, toolTip: String? = nil) {
        self.subGroup = subGroup
        super.init(name: name, group: superGroup, title: title, toolTip: toolTip)
    }
    
    let subGroup: DebugOptionGroup
}
