//
//  TestView.m
//  DebugOptionsTestApp_macOS
//
//  Created by Kai Bruening on 28.01.20.
//  Copyright © 2020 ProjectWizards GmbH. All rights reserved.
//
//  You may incorporate this code into your program(s) without restriction. This code has been
//  provided “AS IS” and the responsibility for its operation is yours.
//

#import "TestView.h"
#import <DebugOptionsFoundation/DebugOptionsFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ColorEnum) {
    ColorRed,
    ColorBlue,
    ColorGreen
};

DEBUG_OPTION_ENUM (TestViewColor, PWRootDebugOptionGroup,
                   @"View Color", nil, DEBUG_OPTION_ENUM_AS_SUBMENU,
                   ColorEnum, ColorBlue, DEBUG_OPTION_PERSISTENT,
                   @"Red", ColorRed,
                   @"Blue", ColorBlue,
                   @"Green", ColorGreen,
                   nil)


@implementation TestView
{
    BOOL    _isObservingColorOption;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSColor* color;
    switch ((ColorEnum)TestViewColor) {
        case ColorRed:
            color = NSColor.redColor;
            break;
        case ColorBlue:
            color = NSColor.blueColor;
            break;
        case ColorGreen:
            color = NSColor.greenColor;
            break;
    }
    [color set];
    [NSBezierPath fillRect:dirtyRect];
    
    // Without this changes of the debug option would not automatically redraw the view.
    [self ensureColorOptionObserver];
}

- (void) ensureColorOptionObserver
{
    if (_isObservingColorOption)
        return;
    
    _isObservingColorOption = YES;
    [PWRootDebugOptionGroup addObserver:self
                             forKeyPath:@"TestViewColor"
                                options:0
                                context:NULL];
}

- (void) observeValueForKeyPath:(nullable NSString*)keyPath
                       ofObject:(nullable id)object
                         change:(nullable NSDictionary<NSKeyValueChangeKey, id>*)change
                        context:(nullable void*)context
{
    if ([keyPath isEqualToString:@"TestViewColor"])
        self.needsDisplay = YES;
}

@end

NS_ASSUME_NONNULL_END
