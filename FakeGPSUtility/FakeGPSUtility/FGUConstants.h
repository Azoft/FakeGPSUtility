//
//  FGUConstants.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//  Responcible: Nikolay July
//

#ifndef TestUtilities_FGUConstants_h
#define TestUtilities_FGUConstants_h

#pragma mark - Global constants definition

#define LONG_PRESS_DURATION 1.0

#if defined(DEBUG)

    #define USE_TEST_UTILITIES 1

#else

    #define USE_TEST_UTILITIES 0

#endif


/*
 * Sub menu items
 */

#if defined(DEBUG) && USE_TEST_UTILITIES

    #define USE_TEST_UTILITIES_LOCATION 1
    #define USE_MOTION_ON_UIWINDOW 1

#else

    #define USE_TEST_UTILITIES_LOCATION 0
    #define USE_MOTION_ON_UIWINDOW 0

#endif

/*
 * Define Appear macros
 */

#if USE_TEST_UTILITIES

    #import "FGUMenuWindow.h"
    #define ShowTestUtilitiesMenu [FGUMenuWindow presentUtlitiesMenu]

#else

    #define ShowTestUtilitiesMenu

#endif


/*
 * Log defines
 */


#define LOG_TU_LOCATION_MANAGER_CALLS 0

#pragma mark - conditionals depending on constants


#if LOG_TU_LOCATION_MANAGER_CALLS
    #define LOG_CALL() NSLog(@"-----[%@]<Call>: CALLED %s-----", [self class], __PRETTY_FUNCTION__);
    #define LOG_UNUSED() NSLog(@"[%@]<Unused>: CALLED %s-----", [self class], __PRETTY_FUNCTION__);
    #define LOG_STUB() NSLog(@"-----[%@]<Stub>: CALLED %s-----", [self class], __PRETTY_FUNCTION__);
    #define LOG_ERROR(__ERROR_MESSAGE_FORMAT__...) NSLog(__ERROR_MESSAGE_FORMAT__)
#else
    #define LOG_CALL()
    #define LOG_UNUSED()
    #define LOG_STUB()
    #define LOG_ERROR(__ERROR_MESSAGE_FORMAT__...)
#endif


#endif
