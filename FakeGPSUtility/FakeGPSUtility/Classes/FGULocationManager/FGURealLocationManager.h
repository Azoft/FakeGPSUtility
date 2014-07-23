//
//  FGURealLocationManager.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import <CoreLocation/CoreLocation.h>
#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGURealLocationManager : CLLocationManager

+ (id)alloc;

@end

#endif