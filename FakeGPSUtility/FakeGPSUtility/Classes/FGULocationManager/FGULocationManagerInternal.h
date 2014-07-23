//
//  FGULocationManagerInternal.h
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
#import <Foundation/Foundation.h>
#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@class FGURealLocationManager;
@class FGULocationManager;
/*
 * Class will be used to keep infomation about locating and RealLocationManager
 */

@interface FGULocationManagerInternal : NSObject<CLLocationManagerDelegate>

@property(nonatomic, assign, getter = isLocationUpdates) BOOL locationUpdating;
@property(nonatomic, retain) FGURealLocationManager *realLocationManager;
@property(nonatomic, assign) id<CLLocationManagerDelegate> realManagerDelegate;
@property(nonatomic, assign) FGULocationManager *fakeLocationManager;

@end


#endif