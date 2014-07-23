//
//  TUTestMainWindow.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#import "UIWindow+FakeGPSUtility.h"
#import "FGUConstants.h"

#if defined(USE_MOTION_ON_UIWINDOW) && USE_MOTION_ON_UIWINDOW

@implementation UIWindow(FakeGPSUtility)

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	[super motionEnded:motion withEvent:event];
	if (motion == UIEventSubtypeMotionShake) {
		ShowTestUtilitiesMenu;
	}
}

@end

#endif
