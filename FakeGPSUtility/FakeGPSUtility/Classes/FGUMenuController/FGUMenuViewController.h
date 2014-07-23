//
//  FGUMenuViewController.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import "FGUBaseViewController.h"
#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@class FGUMenuWindow;

@interface FGUMenuViewController : FGUBaseViewController

@property (nonatomic, retain) FGUMenuWindow *window;
@property (nonatomic, copy) void (^willDismissMenu)(FGUMenuViewController *sender);

@end


#endif