//
//  CLLocationManager+TestUtility.h
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

/*
 * We will override allocation for replacing class(isa), since we need change whole behavior.
 */

#if defined(USE_TEST_UTILITIES_LOCATION) && USE_TEST_UTILITIES_LOCATION

@interface CLLocationManager (FakeGPSUtility)

+ (id)alloc;

@end

#endif
