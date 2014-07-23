//
//  FGUAppDelegate.h
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

@class FGUTestMainViewController;

#define APP_DELEGATE (FGUAppDelegate *)[[UIApplication sharedApplication] delegate]

@interface FGUAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FGUTestMainViewController *viewController;

@end
