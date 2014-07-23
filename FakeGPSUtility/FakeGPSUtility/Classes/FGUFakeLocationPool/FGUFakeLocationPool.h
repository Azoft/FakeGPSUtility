//
//  FGUFakeLocationPool.h
//  TestUtilities
//
//  Azoft
//  Copyright 2013 TestUtilities
//  All Rights Reserved.
//
//  Author:         Timur Kuchkarov
//                  Nikolay July
//  Responcible:    Nikolay July
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "FGUConstants.h"

#if defined(USE_TEST_UTILITIES) && USE_TEST_UTILITIES

extern NSString *const TULocationKey;
extern NSString *const TUOldLocationKey;
extern NSString *const TULocationPoolDidUpdateLocation;
extern NSString *const TULocationPoolDidStopSimulation;
extern NSString *const TULocationPoolDidStartSimulation;

extern NSString *const TULocationPoolDidUpdatePathPointsNotification;

@class FGUPathPoint;

typedef NS_ENUM(NSInteger, FGULocationManagerSimMode) {
    FGULocationManagerSimModeSinglePointFromTouch = 0,
    FGULocationManagerSimModeRouteFromTouches,
    FGULocationManagerSimModeRouteFromFile,
    FGULocationManagerSimModeRouteFromMKRoute
};

#define SharedFakeLocationPool [FGUFakeLocationPool sharedFGUFakeLocationPool]

@interface FGUFakeLocationPool : NSObject <NSCoding>

@property(nonatomic, assign) FGULocationManagerSimMode currentSimulationMode;

/**
 *  Shows when it go to next location (time delay = 1. / timescale)
 */
@property(nonatomic, assign) NSTimeInterval timescale;

/*
 * We will send new location each time
 */
@property(nonatomic) BOOL loopSimulation;
@property(nonatomic, getter = isPaused, readonly) BOOL paused;
@property(nonatomic, getter = isSimulating, readonly) BOOL simulating;

@property(nonatomic, readonly) FGUPathPoint *currentPathPoint;

/**
 *  Singleton getter
 *
 *  @return FGUFakeLocationPool instance
 */
+ (instancetype)sharedFGUFakeLocationPool;

/**
 *  @return array of FGUPathPoint objects
 */
- (NSArray *)points;

/**
 *  Add location to exist locations array
 *
 *  @param location new location
 */
- (void)addLocationToPath:(CLLocation *)location;

/**
 *  Method canceled TULocationPoolDidUpdatePathPointsNotification & TULocationPoolDidUpdateLocation notifications
 */
- (void)beginUpdatePath;

/**
 *  Apply TULocationPoolDidUpdatePathPointsNotification & TULocationPoolDidUpdateLocation notifications,
 *  Send TULocationPoolDidUpdatePathPointsNotification notification
 */
- (void)finishUpdatePath;

- (void)pauseLocationSimulation;
- (void)resumeLocationSimulation;
- (void)startLocationSimulation;
- (void)stopLocationSimulation;

@end

#endif
