//
//  FGULocationManager.m
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

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "FGULocationManager.h"
#import "SynthesizeSingleton.h"

#import "FGUFakeLocationPool.h"
#import "FGULocationManagerInternal.h"
#import "FGUFakeLocationPool.h"
#import "FGURealLocationManager.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

@interface FGULocationManager () {
    FGULocationManagerInternal *_internal;
}

- (void)_locationWasChangedNotification:(NSNotification *)notification;
- (void)_locationPoolDidStopSimulationNotification:(NSNotification *)notification;
- (void)_locationPoolDidStartSimulationNotification:(NSNotification *)notification;

@end

@implementation FGULocationManager

@synthesize locationServicesEnabled;
@synthesize distanceFilter;
@synthesize desiredAccuracy;
@dynamic headingAvailable;
@dynamic headingFilter;
@dynamic headingOrientation;
@dynamic heading;
@dynamic maximumRegionMonitoringDistance;
@dynamic monitoredRegions;

#pragma mark - init/dealloc

-(id) init {
    LOG_CALL();
    self = [super init];
    if (self) {
        
#define ADD_OBSERVER(selectorName, notificationName) [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectorName) name:notificationName object:nil]

        ADD_OBSERVER(_locationWasChangedNotification:, TULocationPoolDidUpdateLocation);
        ADD_OBSERVER(_locationPoolDidStopSimulationNotification:, TULocationPoolDidStopSimulation);
        ADD_OBSERVER(_locationPoolDidStartSimulationNotification:, TULocationPoolDidStartSimulation);

        _internal = [[FGULocationManagerInternal alloc] init];
        _internal.fakeLocationManager = self;

    }
    return self;
}

- (void)dealloc {
    LOG_CALL();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setDelegate:(id<CLLocationManagerDelegate>)delegate {
    _delegate = delegate;
    [_internal setRealManagerDelegate:delegate];
}

- (void)startUpdatingLocation {
    _internal.locationUpdating = YES;
    if (SharedFakeLocationPool.isSimulating) {
        return;
    }
    
    [_internal.realLocationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    _internal.locationUpdating = NO;
    
    [_internal.realLocationManager stopUpdatingLocation];

}

+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

+ (BOOL)headingAvailable {
    return [CLLocationManager headingAvailable];
}

+ (CLAuthorizationStatus)authorizationStatus {
    LOG_CALL();
    return [CLLocationManager authorizationStatus];
}


#pragma mark - stubs (just to replicate clllocationmanager interface)

+ (BOOL)significantLocationChangeMonitoringAvailable {
    LOG_STUB();
	return [CLLocationManager significantLocationChangeMonitoringAvailable];
}

+ (BOOL)regionMonitoringAvailable {
    LOG_STUB();
	return [CLLocationManager regionMonitoringAvailable];
}

+ (BOOL)regionMonitoringEnabled {
    LOG_STUB();
	return [CLLocationManager regionMonitoringEnabled];
}

- (CLLocationAccuracy)desiredAccuracy {
    LOG_STUB();
	return kCLLocationAccuracyBest;
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy {
    LOG_UNUSED();
}

- (CLLocation *)location {
    return (CLLocation *)[SharedFakeLocationPool currentPathPoint];
}

#pragma mark hidden

- (void)_locationWasChangedNotification:(NSNotification *)notification {
    CLLocation *location = [[notification userInfo] objectForKey:TULocationKey];
    CLLocation *oldLocation = [[notification userInfo] objectForKey:TUOldLocationKey];
    if (self.delegate == nil) {
        return;
    }
    
    if (location == nil) {
        if ([self.delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [self.delegate locationManager:(CLLocationManager *)self didFailWithError:nil];
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        [self.delegate locationManager:(CLLocationManager *)self didUpdateLocations:[NSArray arrayWithObject:location]];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
        [self.delegate locationManager:(CLLocationManager *)self didUpdateToLocation:location fromLocation:oldLocation];
        return;
    }
}

- (void)_locationPoolDidStopSimulationNotification:(NSNotification *)notification {
    if (_internal.isLocationUpdates == NO) {
        return;
    }
    [[_internal realLocationManager] startUpdatingLocation];
    CLLocation *realLocation = [[_internal realLocationManager] location];
    if (realLocation == nil) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        [self.delegate locationManager:(CLLocationManager *)self didUpdateLocations:[NSArray arrayWithObject:realLocation]];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
        [self.delegate locationManager:(CLLocationManager *)self didUpdateToLocation:realLocation fromLocation:nil];
        return;
    }
}


- (void)_locationPoolDidStartSimulationNotification:(NSNotification *)notification {
    if (_internal.isLocationUpdates == NO) {
        return;
    }
    [[_internal realLocationManager] stopUpdatingLocation];
}

#pragma mark NSObject

- (BOOL)respondsToSelector:(SEL)aSelector {
    return class_respondsToSelector([self class], aSelector) ?: [_internal.realLocationManager respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return _internal.realLocationManager;
}

@end

#endif
