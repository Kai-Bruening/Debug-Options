//
//  ViewController.m
//  DebugOptionsTestApp_iOS
//
//  Created by Kai Bruening on 29.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <DebugOptionsMenu/DebugOptionsMenu.h>

@interface UIView (DebuggingMethod)
@property (nonatomic, readonly, copy)   NSString*   recursiveDescription;
@end

DEBUG_OPTION_ACTIONBLOCK (DumpViewHierachyAction, TestAppDebugSubGroup,
                          @"Dump View Hierachy",
                          @"Dumps the view hierachy of the key window to the (debugger) console",
                          ^{
                          NSLog (@"Key window view hierachy:\n%@",
                                 UIApplication.sharedApplication.keyWindow.recursiveDescription);
                          })


@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showDebugMenu:(UIButton*)sender
{
    AppDelegate* appDelegate = (AppDelegate*) UIApplication.sharedApplication.delegate;
    NSAssert (appDelegate, nil);
    PWDebugMenuController* debugMenuController = appDelegate.debugMenuController;
    if (debugMenuController)
        [debugMenuController presentDebugMenuCompletionHandler:nil];
}

@end
