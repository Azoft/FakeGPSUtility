//
//  FGUMenuWindow.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import <UIKit/UIKit.h>
#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGUMenuWindow : UIWindow

+ (id)windowWithRootViewController:(UIViewController *)rootController;

+ (void)presentUtlitiesMenu;

@end

#endif