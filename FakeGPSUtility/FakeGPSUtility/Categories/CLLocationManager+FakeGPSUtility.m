//
//  CLLocationManager+TestUtility.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import "CLLocationManager+FakeGPSUtility.h"

#import "FGULocationManager.h"

#if defined(USE_TEST_UTILITIES_LOCATION) && USE_TEST_UTILITIES_LOCATION

@implementation CLLocationManager (FakeGPSUtility)

+ (id)alloc {
    // we must create object with size of our test class
    id allocatedMemory = [FGULocationManager alloc];

    return allocatedMemory;
}


@end

#endif
