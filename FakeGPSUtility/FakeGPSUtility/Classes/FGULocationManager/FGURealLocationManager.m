//
//  FGURealLocationManager.m
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Nikolay July
//  Responcible: Nikolay July
//

#import <objc/runtime.h>

#import "FGURealLocationManager.h"
#import "FGUPathPoint.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES


@implementation FGURealLocationManager

+ (id)alloc {
    // just in case - we create object with size of our test class
    id allocatedMemory = [CLLocationManager alloc];
    object_setClass(allocatedMemory, [CLLocationManager class]);
    
    return allocatedMemory;
}


@end

#endif
