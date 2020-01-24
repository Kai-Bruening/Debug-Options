//
//  ViewController.m
//  DebugOptionsTestApp_macOS
//
//  Created by Kai Bruening on 27.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <DebugOptionsFoundation/DebugOptionsFoundation.h>

@interface NSView (DebuggingMethod)
@property (nonatomic, readonly, copy)   NSString*   _subtreeDescription;
@end

DEBUG_OPTION_ACTIONBLOCK (DumpViewHierachyAction, TestAppDebugSubGroup,
                          @"Dump View Hierachy",
                          @"Dumps the view hierachy of the key window to the (debugger) console",
                          ^{
                          NSLog (@"Key window view hierachy:\n%@", [NSApp.keyWindow.contentView _subtreeDescription]);
                          })

@implementation ViewController

- (void)viewDidLoad
{
    if (TestAppEnableBasicLogging)
        NSLog (@"viewDidLoad");

    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

@end
