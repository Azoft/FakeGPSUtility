//
//  FGUMenuViewController.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import "FGUMenuViewController.h"
#import "FGUContainerViewController.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGUMenuViewController ()

@end

@implementation FGUMenuViewController

- (IBAction)dismissMenu:(id)sender {
    [self.window resignKeyWindow];
    [[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
    [self.window setHidden:YES];
    self.window = nil;
    if (self.willDismissMenu) {
        self.willDismissMenu(self);
    }
}

- (IBAction)locationSimulation:(id)sender {
#ifdef USE_TEST_UTILITIES_LOCATION
    FGUContainerViewController *container = [[FGUContainerViewController alloc] initWithNibName:@"FGUContainerViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:container animated:YES];
#endif
}

@end

#endif
