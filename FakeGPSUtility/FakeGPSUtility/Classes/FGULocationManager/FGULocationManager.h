//
//  FGULocationManager.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author: Timur Kuchkarov
//          Nikolay July
//  Responcible: Nikolay July
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGULocationManager : NSObject

@property(nonatomic, readonly) CLLocation *location;
@property(nonatomic, assign) id<CLLocationManagerDelegate> delegate;


@property(readonly, nonatomic) BOOL locationServicesEnabled __attribute__((deprecated("deprecated in iOS4 and later")));
@property(assign, nonatomic) CLLocationDistance distanceFilter __attribute__((deprecated("isn't supported yet")));
@property(assign, nonatomic) CLLocationAccuracy desiredAccuracy __attribute__((deprecated("isn't supported yet")));
@property(readonly, nonatomic) BOOL headingAvailable __attribute__((deprecated("deprecated in iOS4 and later")));
@property(assign, nonatomic) CLLocationDegrees headingFilter;
@property(assign, nonatomic) CLDeviceOrientation headingOrientation;
@property(readonly, nonatomic) CLHeading *heading;
@property(readonly, nonatomic) CLLocationDistance maximumRegionMonitoringDistance;
@property(readonly, nonatomic) NSSet *monitoredRegions;


//similar to CLLocationManager
- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;

+ (BOOL)locationServicesEnabled;
+ (BOOL)headingAvailable;
+ (BOOL)significantLocationChangeMonitoringAvailable;
+ (BOOL)regionMonitoringAvailable;
+ (BOOL)regionMonitoringEnabled;
+ (CLAuthorizationStatus)authorizationStatus;



@end

@interface FGULocationManager(ForwardMessages)
- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;
- (void)dismissHeadingCalibrationDisplay;
- (void)startMonitoringSignificantLocationChanges;
- (void)stopMonitoringSignificantLocationChanges;
- (void)startMonitoringForRegion:(CLRegion*)region desiredAccuracy:(CLLocationAccuracy)accuracy;
- (void)stopMonitoringForRegion:(CLRegion*)region;
@end

#endif
