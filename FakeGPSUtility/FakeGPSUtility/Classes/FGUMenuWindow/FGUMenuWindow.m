//
//  FGUMenuWindow.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import "FGUMenuWindow.h"
#import "FGUMenuViewController.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@implementation FGUMenuWindow

static BOOL _menuIsPresented = NO;

+ (id)windowWithRootViewController:(UIViewController *)rootController {
    id window = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:rootController];
    [navController setNavigationBarHidden:YES];
    [window setRootViewController:navController];
    return window;
}

+ (void)presentUtlitiesMenu {
    if (_menuIsPresented) {
        return;
    }
    
    FGUMenuViewController *viewController = [FGUMenuViewController new];
    
    viewController.window = [FGUMenuWindow windowWithRootViewController:viewController];
    
    [viewController.window setWindowLevel:viewController.window.windowLevel + 1];
    
    [viewController.window makeKeyAndVisible];
    
    viewController.willDismissMenu = ^ (FGUMenuViewController *sender) {
        _menuIsPresented = NO;
    };
    
    _menuIsPresented = YES;
}

@end

#endif
